-- Headless one-line code explanations via `opencode run`.
-- Visual-select lines (or current line in normal mode), get one short phrase
-- per line back, inserted as comments: trailing beside the code when it fits,
-- otherwise a line above. Reuses one dedicated opencode session per project.
local M = {}

local STATE_FILE = vim.fn.stdpath("data") .. "/opencode-comment/sessions.json"
local TIMEOUT_MS = 120000
local FALLBACK_WIDTH = 100
local MAX_WORDS = 24

---@return string left, right parts of &commentstring (right may be "")
function M.comment_parts(bufnr)
  local cs = vim.bo[bufnr].commentstring
  local left, right = cs:match("^(.-)%%s(.*)$")
  left = left and vim.trim(left) or ""
  right = right and vim.trim(right) or ""
  if left == "" then
    left = "#"
    right = ""
  end
  return left, right
end

---Strip model wrapper noise; cap length. Pure (unit-testable).
---@param raw string concatenated reply text
---@return string
function M.sanitize(raw)
  local line = ""
  for l in (raw or ""):gmatch("[^\r\n]+") do
    l = vim.trim(l)
    if l ~= "" and not l:match("^```") then
      line = l
      break
    end
  end
  -- strip fences/quotes/bullets the model may add despite instructions
  line = line:gsub("^```%w*", ""):gsub("```$", "")
  line = vim.trim(line)
  line = line:gsub('^["\']', ""):gsub('["\']$', "")
  line = line:gsub("^[-*%d%.%s]+%s+", "")
  line = vim.trim(line):gsub("%s+", " ")
  line = line:gsub("%.$", "")
  local words = vim.split(line, "%s+")
  if #words > MAX_WORDS then
    line = table.concat(words, " ", 1, MAX_WORDS) .. " …"
  end
  return vim.trim(line)
end

---Strip an existing trailing line-comment so re-runs replace, not stack. Pure.
---Conservative: only matches `<2+ spaces><leader><space>` (trailing-comment
---convention). Caveat: a string literal containing that pattern (rare) would
---be trimmed too. Block-style leaders (trailer ~= "") are left untouched.
---@param line string
---@param leader string e.g. "//", "#", "--"
---@return string
function M.strip_trailing_comment(line, leader)
  local esc = leader:gsub("(%W)", "%%%1")
  return (line:gsub("%s%s+" .. esc .. "%s.*$", ""))
end

---@return integer width budget for a trailing comment
function M.width_budget(bufnr)
  local tw = vim.bo[bufnr].textwidth
  return (tw and tw > 0) and tw or FALLBACK_WIDTH
end

---Decide trailing vs above. Pure (unit-testable).
---@return "trailing"|"above"
function M.decide_placement(last_line_width, leader, trailer, text, budget)
  local need = last_line_width + 2 + #leader + 1 + vim.fn.strdisplaywidth(text) + #trailer
  if need <= budget then
    return "trailing"
  end
  return "above"
end

local function load_state()
  local fd = vim.uv.fs_open(STATE_FILE, "r", 438)
  if not fd then
    return {}
  end
  local stat = vim.uv.fs_fstat(fd)
  local data = stat and vim.uv.fs_read(fd, stat.size, 0) or ""
  vim.uv.fs_close(fd)
  local ok, decoded = pcall(vim.json.decode, data or "")
  return (ok and type(decoded) == "table") and decoded or {}
end

local function save_state(state)
  vim.fn.mkdir(vim.fn.fnamemodify(STATE_FILE, ":h"), "p")
  local fd = vim.uv.fs_open(STATE_FILE, "w", 384) -- 0600: session ids
  if not fd then
    return
  end
  vim.uv.fs_write(fd, vim.json.encode(state), -1)
  vim.uv.fs_close(fd)
end

local function project_dir(bufnr)
  local ok, root = pcall(function()
    return LazyVim.root()
  end)
  if ok and root and root ~= "" then
    return root
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name ~= "" then
    return vim.fn.fnamemodify(name, ":p:h")
  end
  return vim.fn.getcwd()
end

local function prompt_instructions(n)
  return table.concat({
    string.format("Explain EACH of the following %d code lines (numbered 1-%d below).", n, n),
    "For every line, write one very short phrase (max 10 words) suitable as an",
    "end-of-line code comment.",
    "Rules: output EXACTLY the numbered lines, in order, format `i. phrase`",
    "(e.g. `3. opens the config file`). No quotes, no code fences, no trailing",
    "periods, no tools, no other text, no blank lines between them.",
    "",
    "",
  }, "\n")
end

---@param text string
local function notify(text, level)
  vim.notify(text, level or vim.log.levels.INFO, { title = "opencode comment" })
end

local function run_explain(opts)
  local argv = { "opencode", "run", "--format", "json", "--dir", opts.dir, "--title", "inline-comment" }
  if opts.session_id then
    table.insert(argv, "--session")
    table.insert(argv, opts.session_id)
  end
  if vim.g.opencode_comment_model and vim.g.opencode_comment_model ~= "" then
    table.insert(argv, "--model")
    table.insert(argv, vim.g.opencode_comment_model)
  end
  table.insert(argv, prompt_instructions(opts.n) .. opts.snippet)

  vim.system(argv, { text = true, timeout = TIMEOUT_MS }, function(res)
    vim.schedule(function()
      opts.on_done(res)
    end)
  end)
end

---@param stdout string
---@return string session_id, string reply_text
function M.parse_run_output(stdout)
  local session_id = ""
  local chunks = {}
  for line in (stdout or ""):gmatch("[^\r\n]+") do
    local ok, ev = pcall(vim.json.decode, line)
    if ok and type(ev) == "table" then
      if session_id == "" and type(ev.sessionID) == "string" then
        session_id = ev.sessionID
      end
      if ev.type == "text" and type(ev.part) == "table" and type(ev.part.text) == "string" then
        chunks[#chunks + 1] = ev.part.text
      end
    end
  end
  return session_id, table.concat(chunks)
end

---Parse `i. phrase` reply lines into a number->phrase map. Pure.
---Numbers outside 1..n are ignored; later duplicates win.
---@param reply string concatenated model text
---@param n integer number of code lines sent
---@return table<integer,string> phrases, integer matched
function M.parse_numbered(reply, n)
  local phrases = {}
  local matched = 0
  for line in (reply or ""):gmatch("[^\r\n]+") do
    local num, rest = line:match("^%s*(%d+)%s*[:.%)%-%s]+%s*(.*)$")
    num = tonumber(num)
    if num and num >= 1 and num <= n then
      local phrase = M.sanitize(rest or "")
      if phrase ~= "" and phrases[num] == nil then
        matched = matched + 1
      end
      if phrase ~= "" then
        phrases[num] = phrase
      end
    end
  end
  return phrases, matched
end

---Insert one comment per line; single buf_set_lines call == single undo step.
---Lines with no phrase (blank code or missing reply) are left untouched.
---@param bufnr integer
---@param first integer 0-based start of range
---@param lines string[] original range lines
---@param phrases table<integer,string> 1-based per-line phrases
---@return integer applied count of inserted comments
local function apply_comments(bufnr, first, lines, phrases)
  local leader, trailer = M.comment_parts(bufnr)
  local trailer_suffix = trailer ~= "" and (" " .. trailer) or ""
  local budget = M.width_budget(bufnr)
  local out = {}
  local applied = 0
  for k, line in ipairs(lines) do
    local phrase = phrases[k]
    if phrase == nil or phrase == "" or vim.trim(line) == "" then
      out[#out + 1] = line
    else
      local code = line
      if trailer_suffix == "" then
        code = M.strip_trailing_comment(code, leader)
      end
      local comment = leader .. " " .. phrase .. trailer_suffix
      if M.decide_placement(vim.fn.strdisplaywidth(code), leader, trailer_suffix, phrase, budget) == "trailing" then
        out[#out + 1] = code .. "  " .. comment
      else
        local indent = line:match("^(%s*)") or ""
        out[#out + 1] = indent .. comment
        out[#out + 1] = line
      end
      applied = applied + 1
    end
  end
  if applied > 0 then
    vim.api.nvim_buf_set_lines(bufnr, first, first + #lines, false, out)
  end
  return applied
end

---Core: explain explicit 0-based [first, last] range, one comment per line.
---@param bufnr integer
---@param first integer 0-based
---@param last integer 0-based inclusive
local function explain_range(bufnr, first, last)
  local lines = vim.api.nvim_buf_get_lines(bufnr, first, last + 1, false)
  if #lines == 0 then
    return
  end
  local nonempty = 0
  local numbered = {}
  for k, line in ipairs(lines) do
    numbered[#numbered + 1] = k .. ": " .. line
    if vim.trim(line) ~= "" then
      nonempty = nonempty + 1
    end
  end
  if nonempty == 0 then
    notify("empty selection", vim.log.levels.WARN)
    return
  end
  local n = #lines
  local snippet = table.concat(numbered, "\n")

  local dir = project_dir(bufnr)
  local state = load_state()
  local session_id = state[dir]
  local tried_fresh = session_id == nil or session_id == ""

  notify(session_id and "Explaining lines (reusing session)…" or "Explaining lines…")

  local function attempt(sid)
    run_explain({
      dir = dir,
      session_id = sid,
      n = n,
      snippet = snippet,
      on_done = function(res)
        local new_sid, reply = M.parse_run_output(res.stdout or "")
        if res.code == 0 and reply:match("%S") then
          if new_sid ~= "" then
            state[dir] = new_sid
            save_state(state)
          end
          if not vim.api.nvim_buf_is_valid(bufnr) then
            notify("buffer closed, discarding explanations", vim.log.levels.WARN)
            return
          end
          -- async run: abort rather than misplace comments if buffer changed
          local cur = vim.api.nvim_buf_get_lines(bufnr, first, first + #lines, false)
          if table.concat(cur, "\n") ~= table.concat(lines, "\n") then
            notify("buffer changed while explaining, discarding", vim.log.levels.WARN)
            return
          end
          local phrases, matched = M.parse_numbered(reply, n)
          local applied = apply_comments(bufnr, first, lines, phrases)
          if applied == 0 then
            notify("could not parse model reply, nothing inserted", vim.log.levels.WARN)
          elseif matched < nonempty then
            notify(
              string.format("explained %d of %d lines", applied, nonempty),
              vim.log.levels.WARN
            )
          end
          return
        end
        -- stored session may be pruned/foreign: retry once with a fresh session
        if not tried_fresh then
          tried_fresh = true
          state[dir] = nil
          save_state(state)
          notify("stored session failed, retrying with a fresh one…", vim.log.levels.WARN)
          attempt(nil)
          return
        end
        local err = vim.trim(res.stderr or "")
        if err == "" then
          err = "exit " .. tostring(res.code)
        end
        notify("opencode run failed: " .. err, vim.log.levels.ERROR)
      end,
    })
  end

  attempt(session_id)
end

---Explain current visual selection, one comment per line. Visual-mode entry.
function M.explain_visual()
  if vim.fn.executable("opencode") ~= 1 then
    notify("`opencode` CLI not found in PATH", vim.log.levels.ERROR)
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local s = vim.fn.getpos("'<")
  local e = vim.fn.getpos("'>")
  if s[2] == 0 or e[2] == 0 then
    notify("no visual selection", vim.log.levels.WARN)
    return
  end
  explain_range(bufnr, math.min(s[2], e[2]) - 1, math.max(s[2], e[2]) - 1)
end

---Explain current line. Normal-mode entry.
function M.explain_line()
  if vim.fn.executable("opencode") ~= 1 then
    notify("`opencode` CLI not found in PATH", vim.log.levels.ERROR)
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  explain_range(bufnr, row, row)
end

---Legacy entry: visual selection. Kept for compatibility.
function M.explain()
  return M.explain_visual()
end

---Forget the stored session for the current project (next run starts fresh).
function M.new_session()
  local dir = project_dir(vim.api.nvim_get_current_buf())
  local state = load_state()
  state[dir] = nil
  save_state(state)
  notify("session reset for " .. dir)
end

return M
