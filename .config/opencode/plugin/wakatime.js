var __require = /* @__PURE__ */ ((x) => typeof require !== "undefined" ? require : typeof Proxy !== "undefined" ? new Proxy(x, {
  get: (a, b) => (typeof require !== "undefined" ? require : a)[b]
}) : x)(function(x) {
  if (typeof require !== "undefined") return require.apply(this, arguments);
  throw Error('Dynamic require of "' + x + '" is not supported');
});

// src/v1.ts
import * as fs5 from "node:fs";
import * as path6 from "node:path";

// src/file-changes.ts
function record(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value) ? value : void 0;
}
function count(value) {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}
function fileChange(file, additions = 0, deletions = 0, isWrite = false) {
  return typeof file === "string" && file.length > 0 ? [{ file, info: { additions, deletions, isWrite } }] : [];
}
function diffChange(value) {
  const diff = record(value);
  return diff ? fileChange(
    diff.file,
    count(diff.additions),
    count(diff.deletions),
    diff.status === "added"
  ) : [];
}
function extractFileChanges(tool, metadata, output, title) {
  if (!metadata) return [];
  switch (tool) {
    case "edit": {
      const diff = diffChange(metadata.filediff);
      return diff.length > 0 ? diff : fileChange(metadata.filePath);
    }
    case "write":
      return fileChange(metadata.filepath, 0, 0, !metadata.exists);
    case "patch": {
      const files = output.split("\n").filter((line) => line.startsWith("  ") && !line.startsWith("   ")).map((line) => line.trim()).filter((file) => file && !file.includes(" "));
      const diff = files.length > 0 ? Math.round(count(metadata.diff) / files.length) : 0;
      return files.flatMap(
        (file) => fileChange(file, Math.max(diff, 0), Math.max(-diff, 0))
      );
    }
    case "multiedit":
      return Array.isArray(metadata.results) ? metadata.results.flatMap(
        (result) => diffChange(record(result)?.filediff)
      ) : [];
    case "read":
      return fileChange(title);
    default:
      return [];
  }
}
function extractV2FileChanges(tool, input, result) {
  const value = record(result);
  const output = record(value?.output);
  switch (tool) {
    case "edit":
    case "patch": {
      const files = output?.files ?? record(value?.metadata)?.files;
      return Array.isArray(files) ? files.flatMap(diffChange) : [];
    }
    case "write":
      return fileChange(
        output?.target ?? output?.resource,
        0,
        0,
        output?.existed === false
      );
    case "read":
      return output?.type === "list-page" ? [] : fileChange(record(input)?.path);
    default:
      return [];
  }
}

// src/logger.ts
import * as fs from "node:fs";
import * as path2 from "node:path";

// src/wakatime-paths.ts
import * as os from "node:os";
import * as path from "node:path";
function getWakatimeHomeFromEnv() {
  const value = process.env.WAKATIME_HOME?.trim();
  if (!value) {
    return void 0;
  }
  if (value === "~") {
    return os.homedir();
  }
  if (value.startsWith("~/") || value.startsWith("~\\")) {
    return path.join(os.homedir(), value.slice(2));
  }
  return value;
}
function getWakatimeHomeDir() {
  return getWakatimeHomeFromEnv() ?? os.homedir();
}
function getWakatimeResourcesDir() {
  const wakatimeHome = getWakatimeHomeFromEnv();
  if (wakatimeHome) {
    return wakatimeHome;
  }
  return path.join(os.homedir(), ".wakatime");
}
function getWakatimeConfigFilePath() {
  return path.join(getWakatimeHomeDir(), ".wakatime.cfg");
}

// src/logger.ts
var LogLevel = /* @__PURE__ */ ((LogLevel2) => {
  LogLevel2[LogLevel2["DEBUG"] = 0] = "DEBUG";
  LogLevel2[LogLevel2["INFO"] = 1] = "INFO";
  LogLevel2[LogLevel2["WARN"] = 2] = "WARN";
  LogLevel2[LogLevel2["ERROR"] = 3] = "ERROR";
  return LogLevel2;
})(LogLevel || {});
function getLogFilePath() {
  return path2.join(getWakatimeResourcesDir(), "opencode.log");
}
var Logger = class {
  level = 1 /* INFO */;
  setLevel(level) {
    this.level = level;
  }
  debug(msg) {
    this.log(0 /* DEBUG */, msg);
  }
  info(msg) {
    this.log(1 /* INFO */, msg);
  }
  warn(msg) {
    this.log(2 /* WARN */, msg);
  }
  error(msg) {
    this.log(3 /* ERROR */, msg);
  }
  warnException(err) {
    const message = err instanceof Error ? err.message : String(err);
    this.warn(message);
  }
  errorException(err) {
    const message = err instanceof Error ? err.message : String(err);
    this.error(message);
  }
  log(level, msg) {
    if (level < this.level) return;
    const levelName = LogLevel[level];
    const timestamp2 = (/* @__PURE__ */ new Date()).toISOString();
    const line = `[${timestamp2}][${levelName}] ${msg}
`;
    try {
      const logFile = getLogFilePath();
      const dir = path2.dirname(logFile);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
      fs.appendFileSync(logFile, line);
    } catch {
    }
  }
};
var logger = new Logger();

// src/tracker.ts
import * as fs4 from "node:fs";
import * as path5 from "node:path";

// src/state.ts
import * as crypto from "node:crypto";
import * as fs2 from "node:fs";
import * as path3 from "node:path";
function timestamp() {
  return Math.floor(Date.now() / 1e3);
}
function createState(projectFolder) {
  const hash = crypto.createHash("md5").update(projectFolder).digest("hex").slice(0, 8);
  const stateFile = path3.join(
    getWakatimeResourcesDir(),
    `opencode-${hash}.json`
  );
  function readState() {
    try {
      const value = JSON.parse(fs2.readFileSync(stateFile, "utf-8"));
      return value && typeof value.lastHeartbeatAt === "number" && Number.isFinite(value.lastHeartbeatAt) ? { lastHeartbeatAt: value.lastHeartbeatAt } : {};
    } catch {
      return {};
    }
  }
  function writeState(state) {
    try {
      fs2.mkdirSync(path3.dirname(stateFile), { recursive: true });
      fs2.writeFileSync(stateFile, JSON.stringify(state, null, 2));
    } catch {
    }
  }
  return {
    readState,
    writeState,
    shouldSendHeartbeat(force = false) {
      return force || timestamp() - (readState().lastHeartbeatAt ?? 0) >= 60;
    },
    updateLastHeartbeat() {
      writeState({ lastHeartbeatAt: timestamp() });
    }
  };
}

// src/wakatime.ts
import {
  spawn
} from "node:child_process";
import * as os3 from "node:os";

// src/dependencies.ts
import { execSync } from "node:child_process";
import * as fs3 from "node:fs";
import { createWriteStream } from "node:fs";
import * as https from "node:https";
import * as os2 from "node:os";
import * as path4 from "node:path";
function whichSync(cmd) {
  try {
    const isWindows2 = os2.platform() === "win32";
    const result = execSync(isWindows2 ? `where ${cmd}` : `which ${cmd}`, {
      encoding: "utf-8",
      stdio: ["pipe", "pipe", "pipe"]
    });
    const firstLine = result.trim().split("\n")[0];
    return firstLine || null;
  } catch {
    return null;
  }
}
var GITHUB_RELEASES_URL = "https://api.github.com/repos/wakatime/wakatime-cli/releases/latest";
var GITHUB_DOWNLOAD_URL = "https://github.com/wakatime/wakatime-cli/releases/latest/download";
var UPDATE_CHECK_INTERVAL = 4 * 60 * 60 * 1e3;
var Dependencies = class {
  resourcesLocation;
  cliLocation;
  stateFile;
  constructor() {
    this.resourcesLocation = getWakatimeResourcesDir();
    this.stateFile = path4.join(
      this.resourcesLocation,
      "opencode-cli-state.json"
    );
  }
  isWindows() {
    return os2.platform() === "win32";
  }
  getOsName() {
    const platform3 = os2.platform();
    if (platform3 === "win32") return "windows";
    return platform3;
  }
  getArchitecture() {
    const arch2 = os2.arch();
    if (arch2 === "x64") return "amd64";
    if (arch2 === "ia32" || arch2.includes("32")) return "386";
    if (arch2 === "arm64") return "arm64";
    if (arch2 === "arm") return "arm";
    return arch2;
  }
  getCliBinaryName() {
    const osname = this.getOsName();
    const arch2 = this.getArchitecture();
    const ext = this.isWindows() ? ".exe" : "";
    return `wakatime-cli-${osname}-${arch2}${ext}`;
  }
  getCliDownloadUrl() {
    const osname = this.getOsName();
    const arch2 = this.getArchitecture();
    return `${GITHUB_DOWNLOAD_URL}/wakatime-cli-${osname}-${arch2}.zip`;
  }
  readState() {
    try {
      if (fs3.existsSync(this.stateFile)) {
        return JSON.parse(fs3.readFileSync(this.stateFile, "utf-8"));
      }
    } catch {
    }
    return {};
  }
  writeState(state) {
    try {
      fs3.mkdirSync(path4.dirname(this.stateFile), { recursive: true });
      fs3.writeFileSync(this.stateFile, JSON.stringify(state, null, 2));
    } catch {
    }
  }
  getCliLocationGlobal() {
    const binaryName = `wakatime-cli${this.isWindows() ? ".exe" : ""}`;
    try {
      const globalPath = whichSync(binaryName);
      if (globalPath) {
        logger.debug(`Found global wakatime-cli: ${globalPath}`);
        return globalPath;
      }
    } catch {
    }
    return void 0;
  }
  getCliLocation() {
    if (this.cliLocation) return this.cliLocation;
    const globalCli = this.getCliLocationGlobal();
    if (globalCli) {
      this.cliLocation = globalCli;
      return this.cliLocation;
    }
    const binary = this.getCliBinaryName();
    this.cliLocation = path4.join(this.resourcesLocation, binary);
    return this.cliLocation;
  }
  isCliInstalled() {
    const location = this.getCliLocation();
    return fs3.existsSync(location);
  }
  shouldCheckForUpdates() {
    if (this.getCliLocationGlobal()) {
      return false;
    }
    const state = this.readState();
    if (!state.lastChecked) return true;
    return Date.now() - state.lastChecked > UPDATE_CHECK_INTERVAL;
  }
  async checkAndInstallCli() {
    if (this.getCliLocationGlobal()) {
      logger.debug("Using global wakatime-cli, skipping installation check");
      return;
    }
    if (!this.isCliInstalled()) {
      logger.info("wakatime-cli not found, downloading...");
      await this.installCli();
      return;
    }
    if (this.shouldCheckForUpdates()) {
      logger.debug("Checking for wakatime-cli updates...");
      const latestVersion = await this.getLatestVersion();
      const state = this.readState();
      if (latestVersion && latestVersion !== state.version) {
        logger.info(`Updating wakatime-cli to ${latestVersion}...`);
        await this.installCli();
        this.writeState({ lastChecked: Date.now(), version: latestVersion });
      } else {
        this.writeState({ ...state, lastChecked: Date.now() });
      }
    }
  }
  async getLatestVersion() {
    return new Promise((resolve3) => {
      const options = {
        headers: {
          "User-Agent": "opencode-wakatime"
        }
      };
      https.get(GITHUB_RELEASES_URL, options, (res) => {
        let data = "";
        res.on("data", (chunk) => {
          data += chunk;
        });
        res.on("end", () => {
          try {
            const json = JSON.parse(data);
            resolve3(json.tag_name);
          } catch {
            resolve3(void 0);
          }
        });
      }).on("error", () => {
        resolve3(void 0);
      });
    });
  }
  async installCli() {
    const zipUrl = this.getCliDownloadUrl();
    const zipFile = path4.join(
      this.resourcesLocation,
      `wakatime-cli-${Date.now()}.zip`
    );
    try {
      fs3.mkdirSync(this.resourcesLocation, { recursive: true });
      logger.debug(`Downloading wakatime-cli from ${zipUrl}`);
      await this.downloadFile(zipUrl, zipFile);
      logger.debug(`Extracting wakatime-cli to ${this.resourcesLocation}`);
      await this.extractZip(zipFile, this.resourcesLocation);
      if (!this.isWindows()) {
        const cliPath = this.getCliLocation();
        if (fs3.existsSync(cliPath)) {
          fs3.chmodSync(cliPath, 493);
          logger.debug(`Set executable permission on ${cliPath}`);
        }
      }
      logger.info("wakatime-cli installed successfully");
    } catch (err) {
      logger.errorException(err);
      throw err;
    } finally {
      try {
        if (fs3.existsSync(zipFile)) {
          fs3.unlinkSync(zipFile);
        }
      } catch {
      }
    }
  }
  downloadFile(url, dest) {
    return new Promise((resolve3, reject) => {
      const followRedirect = (url2, redirectCount = 0) => {
        if (redirectCount > 5) {
          reject(new Error("Too many redirects"));
          return;
        }
        https.get(url2, (res) => {
          if (res.statusCode === 301 || res.statusCode === 302) {
            const location = res.headers.location;
            if (location) {
              followRedirect(location, redirectCount + 1);
              return;
            }
          }
          if (res.statusCode !== 200) {
            reject(new Error(`HTTP ${res.statusCode}`));
            return;
          }
          const file = createWriteStream(dest);
          res.pipe(file);
          file.on("finish", () => {
            file.close();
            resolve3();
          });
          file.on("error", (err) => {
            fs3.unlinkSync(dest);
            reject(err);
          });
        }).on("error", reject);
      };
      followRedirect(url);
    });
  }
  async extractZip(zipFile, destDir) {
    const { execSync: execSync2 } = await import("node:child_process");
    try {
      if (this.isWindows()) {
        execSync2(
          `powershell -command "Expand-Archive -Force '${zipFile}' '${destDir}'"`,
          {
            windowsHide: true
          }
        );
      } else {
        execSync2(`unzip -o "${zipFile}" -d "${destDir}"`, {
          stdio: "ignore"
        });
      }
    } catch (_err) {
      logger.warn("Native unzip failed, attempting manual extraction");
      await this.extractZipManual(zipFile, destDir);
    }
  }
  async extractZipManual(zipFile, destDir) {
    const data = fs3.readFileSync(zipFile);
    let offset = 0;
    while (offset < data.length - 4) {
      if (data[offset] === 80 && data[offset + 1] === 75 && data[offset + 2] === 3 && data[offset + 3] === 4) {
        const compressedSize = data.readUInt32LE(offset + 18);
        const uncompressedSize = data.readUInt32LE(offset + 22);
        const fileNameLength = data.readUInt16LE(offset + 26);
        const extraFieldLength = data.readUInt16LE(offset + 28);
        const fileName = data.slice(offset + 30, offset + 30 + fileNameLength).toString();
        const dataStart = offset + 30 + fileNameLength + extraFieldLength;
        const compressionMethod = data.readUInt16LE(offset + 8);
        if (fileName.includes("wakatime-cli")) {
          const destPath = path4.join(destDir, path4.basename(fileName));
          if (compressionMethod === 0) {
            const fileData = data.slice(
              dataStart,
              dataStart + uncompressedSize
            );
            fs3.writeFileSync(destPath, fileData);
          } else if (compressionMethod === 8) {
            const { inflateRawSync } = await import("node:zlib");
            const compressedData = data.slice(
              dataStart,
              dataStart + compressedSize
            );
            const decompressed = inflateRawSync(compressedData);
            fs3.writeFileSync(destPath, decompressed);
          }
          logger.debug(`Extracted ${fileName} to ${destPath}`);
          return;
        }
        offset = dataStart + compressedSize;
      } else {
        offset++;
      }
    }
    throw new Error("Could not find wakatime-cli in zip file");
  }
};
var dependencies = new Dependencies();

// src/wakatime.ts
function getVersion() {
  if (true) {
    return "1.4.0";
  }
  try {
    const fs6 = __require("node:fs");
    const path8 = __require("node:path");
    const { fileURLToPath } = __require("node:url");
    const __dirname = path8.dirname(fileURLToPath(import.meta.url));
    const pkg = JSON.parse(
      fs6.readFileSync(path8.join(__dirname, "..", "package.json"), "utf-8")
    );
    return pkg.version;
  } catch {
    return "unknown";
  }
}
var VERSION = getVersion();
var DEFAULT_HEARTBEAT_TIMEOUT_MS = 3e4;
var HEARTBEAT_KILL_GRACE_MS = 2e3;
var pendingHeartbeatBatches = /* @__PURE__ */ new Set();
var activeHeartbeatProcesses = /* @__PURE__ */ new Set();
function killActiveHeartbeats() {
  for (const child of activeHeartbeatProcesses) {
    if (child.exitCode !== null || child.signalCode !== null) continue;
    try {
      child.kill("SIGKILL");
    } catch {
    }
  }
}
process.once("exit", killActiveHeartbeats);
function isWindows() {
  return os3.platform() === "win32";
}
function buildExecOptions() {
  const options = {
    stdio: ["pipe", "ignore", "ignore"],
    windowsHide: true
  };
  if (!isWindows() && !process.env.WAKATIME_HOME && !process.env.HOME) {
    options.env = { ...process.env, WAKATIME_HOME: os3.homedir() };
  }
  return options;
}
function formatArgs(args) {
  return args.map((arg) => {
    if (arg.includes(" ")) {
      return `"${arg.replace(/"/g, '\\"')}"`;
    }
    return arg;
  }).join(" ");
}
async function ensureCliInstalled() {
  try {
    await dependencies.checkAndInstallCli();
    return dependencies.isCliInstalled();
  } catch (err) {
    logger.errorException(err);
    return false;
  }
}
function sendHeartbeats(params, timeoutMs = DEFAULT_HEARTBEAT_TIMEOUT_MS) {
  const heartbeatBatch = new Promise((resolve3) => {
    if (params.length === 0) {
      resolve3(void 0);
      return;
    }
    const cliLocation = dependencies.getCliLocation();
    if (!dependencies.isCliInstalled()) {
      logger.warn("wakatime-cli not installed, skipping heartbeat");
      resolve3(void 0);
      return;
    }
    const [primary, ...extra] = params;
    const client = primary.opencodeClient || "cli";
    const opencodeVersion = primary.opencodeVersion || "unknown";
    const args = [
      "--entity",
      primary.entity,
      "--entity-type",
      "file",
      "--category",
      primary.category ?? "ai coding",
      "--plugin",
      `opencode-${client}/${opencodeVersion} opencode-wakatime/${VERSION}`
    ];
    if (primary.projectFolder) {
      args.push("--project-folder", primary.projectFolder);
    }
    if (primary.lineChanges !== void 0 && primary.lineChanges !== 0) {
      args.push("--ai-line-changes", primary.lineChanges.toString());
    }
    if (primary.isWrite) {
      args.push("--write");
    }
    if (extra.length > 0) {
      args.push("--extra-heartbeats");
    }
    logger.debug(
      `Sending ${params.length} heartbeat(s): wakatime-cli ${formatArgs(args)}`
    );
    const execOptions = buildExecOptions();
    const child = spawn(cliLocation, args, execOptions);
    activeHeartbeatProcesses.add(child);
    let resolved = false;
    let forceKillId;
    const resolveOnce = (result) => {
      if (!resolved) {
        resolved = true;
        activeHeartbeatProcesses.delete(child);
        clearTimeout(timeoutId);
        if (forceKillId) clearTimeout(forceKillId);
        resolve3(result);
      }
    };
    const timeoutId = setTimeout(() => {
      logger.warn(
        `Heartbeat batch timed out after ${timeoutMs}ms, terminating wakatime-cli`
      );
      try {
        child.kill("SIGTERM");
      } catch (error) {
        logger.error(`Failed to terminate wakatime-cli: ${error}`);
      }
      forceKillId = setTimeout(() => {
        if (child.exitCode !== null || child.signalCode !== null) return;
        logger.warn("wakatime-cli did not exit after SIGTERM, sending SIGKILL");
        try {
          child.kill("SIGKILL");
        } catch (error) {
          logger.error(`Failed to kill wakatime-cli: ${error}`);
        }
      }, HEARTBEAT_KILL_GRACE_MS);
    }, timeoutMs);
    child.once("error", (error) => {
      logger.error(`wakatime-cli spawn error: ${error.message}`);
      resolveOnce();
    });
    child.once("close", (code, signal) => {
      if (code !== null && code !== 0) {
        logger.warn(`wakatime-cli exited with code ${code}`);
      } else if (signal) {
        logger.debug(`wakatime-cli terminated by signal ${signal}`);
      }
      resolveOnce(signal ? "interrupted" : void 0);
    });
    const timestamp2 = Date.now() / 1e3;
    const extraHeartbeats = extra.map((heartbeat) => ({
      ai_line_changes: heartbeat.lineChanges !== void 0 && heartbeat.lineChanges !== 0 ? heartbeat.lineChanges : void 0,
      category: heartbeat.category ?? "ai coding",
      entity: heartbeat.entity,
      entity_type: "file",
      is_write: heartbeat.isWrite || void 0,
      time: timestamp2
    }));
    child.stdin?.on("error", (error) => {
      logger.error(`wakatime-cli stdin error: ${error.message}`);
    });
    child.stdin?.end(
      extraHeartbeats.length > 0 ? `${JSON.stringify(extraHeartbeats)}
` : void 0
    );
  });
  if (params.length > 0) {
    pendingHeartbeatBatches.add(heartbeatBatch);
    void heartbeatBatch.then(
      () => pendingHeartbeatBatches.delete(heartbeatBatch),
      () => pendingHeartbeatBatches.delete(heartbeatBatch)
    );
  }
  return heartbeatBatch;
}
async function flushHeartbeats() {
  while (pendingHeartbeatBatches.size > 0) {
    await Promise.all(pendingHeartbeatBatches);
  }
}

// src/tracker.ts
function resolveProjectFolder(worktree, projectWorktree, cwd = process.cwd()) {
  return worktree || projectWorktree || cwd;
}
async function createTracker(options) {
  try {
    const cfg = fs4.readFileSync(getWakatimeConfigFilePath(), "utf-8");
    if (/^\s*debug\s*=\s*true\s*$/m.test(cfg)) logger.setLevel(0 /* DEBUG */);
  } catch {
  }
  const state = createState(options.projectFolder);
  const sessions = /* @__PURE__ */ new Map();
  const processedCalls = /* @__PURE__ */ new Set();
  const interruptedBatches = /* @__PURE__ */ new Set();
  if (!await ensureCliInstalled()) {
    logger.warn(
      "WakaTime CLI could not be installed. Please install it manually: https://wakatime.com/terminal"
    );
  } else {
    logger.info(
      `OpenCode WakaTime plugin initialized for project: ${path5.basename(options.projectFolder)}`
    );
  }
  async function processHeartbeat(force = false, sessionID) {
    if (!state.shouldSendHeartbeat(force)) return;
    const files = /* @__PURE__ */ new Map();
    for (const [id, changes] of sessions) {
      if (sessionID !== void 0 && id !== sessionID) continue;
      for (const [file, info] of changes) {
        const previous = files.get(file);
        files.set(file, {
          additions: (previous?.additions ?? 0) + info.additions,
          deletions: (previous?.deletions ?? 0) + info.deletions,
          isWrite: !!previous?.isWrite || info.isWrite
        });
      }
      sessions.delete(id);
    }
    if (files.size > 0) {
      const heartbeats = Array.from(
        files,
        ([entity, info]) => ({
          entity,
          projectFolder: options.projectFolder,
          lineChanges: info.additions - info.deletions,
          category: "ai coding",
          isWrite: info.isWrite,
          opencodeVersion: options.opencodeVersion,
          opencodeClient: options.opencodeClient
        })
      );
      state.updateLastHeartbeat();
      const delivery = sendHeartbeats(heartbeats).then((result) => {
        if (result === "interrupted") interruptedBatches.add(heartbeats);
      });
      if (options.waitForDelivery) await delivery;
    }
    if (force) await flushHeartbeats();
  }
  return {
    processHeartbeat,
    async flush() {
      await processHeartbeat(true);
      const retry = Array.from(interruptedBatches);
      interruptedBatches.clear();
      for (const batch of retry) await sendHeartbeats(batch);
    },
    async track(sessionID, callID, changes) {
      if (changes.length === 0) return;
      const key = JSON.stringify([sessionID, callID]);
      if (processedCalls.has(key)) return;
      processedCalls.add(key);
      if (processedCalls.size > 1e3) {
        for (const old of Array.from(processedCalls).slice(0, 500))
          processedCalls.delete(old);
      }
      const files = sessions.get(sessionID) ?? /* @__PURE__ */ new Map();
      for (const change of changes) {
        const file = path5.resolve(options.directory, change.file);
        try {
          if (fs4.statSync(file).isDirectory()) continue;
        } catch {
        }
        const previous = files.get(file);
        files.set(file, {
          additions: (previous?.additions ?? 0) + (change.info.additions ?? 0),
          deletions: (previous?.deletions ?? 0) + (change.info.deletions ?? 0),
          isWrite: !!previous?.isWrite || !!change.info.isWrite
        });
      }
      if (files.size > 0) sessions.set(sessionID, files);
      await processHeartbeat();
    }
  };
}
function getClientName() {
  const client = process.env.OPENCODE_CLIENT || "cli";
  return client === "app" ? "web" : client;
}

// src/v1.ts
async function getVersion2(client) {
  const cacheFile = path6.join(
    getWakatimeResourcesDir(),
    "opencode-version-cache.json"
  );
  try {
    const cached = JSON.parse(fs5.readFileSync(cacheFile, "utf-8"));
    if (typeof cached.version === "string" && Date.now() - cached.timestamp < 6e4)
      return cached.version;
  } catch {
  }
  try {
    const sdk = client;
    const httpClient = sdk.global?._client ?? sdk._client;
    const response = await httpClient?.get({ url: "/global/health" });
    const version = response?.data?.version;
    if (version) {
      try {
        fs5.writeFileSync(
          cacheFile,
          JSON.stringify({ version, timestamp: Date.now() })
        );
      } catch {
      }
      return version;
    }
  } catch (error) {
    logger.warn(`Could not fetch OpenCode version: ${error}`);
  }
  return "unknown";
}
var v1Plugin = async (ctx) => {
  const projectFolder = resolveProjectFolder(
    ctx.worktree,
    ctx.project.worktree
  );
  const tracker = await createTracker({
    projectFolder,
    directory: ctx.directory || projectFolder,
    opencodeVersion: await getVersion2(ctx.client),
    opencodeClient: getClientName()
  });
  const hooks = {
    "chat.message": async () => tracker.processHeartbeat(),
    event: async ({ event }) => {
      if (event.type === "message.part.updated") {
        const part = event.properties.part;
        if (part.type !== "tool" || part.state.status !== "completed") return;
        await tracker.track(
          part.sessionID,
          part.callID,
          extractFileChanges(
            part.tool,
            part.state.metadata,
            part.state.output ?? "",
            part.state.title
          )
        );
      }
      if (event.type === "session.idle") {
        await tracker.processHeartbeat(true, event.properties.sessionID);
      }
      if (event.type === "session.deleted") {
        await tracker.processHeartbeat(true, event.properties.info.id);
      }
    },
    dispose: async () => tracker.flush()
  };
  return hooks;
};

// src/v2.ts
import * as path7 from "node:path";
import { setTimeout as setTimeout2 } from "node:timers/promises";
async function setupV2(ctx) {
  const tracker = await createTracker({
    projectFolder: ctx.location.project.directory,
    directory: ctx.location.directory,
    opencodeVersion: ctx.app.version,
    opencodeClient: getClientName(),
    // V2 can terminate child processes when the runtime scope shuts down.
    // Finish the rate-limited send before returning control to the host.
    waitForDelivery: true
  });
  const controller = new AbortController();
  const registrations = [];
  const trackedSessions = /* @__PURE__ */ new Set();
  const matchesLocation = (directory) => path7.resolve(directory) === path7.resolve(ctx.location.directory);
  try {
    registrations.push(
      await ctx.tool.hook("execute.after", async (event) => {
        if (controller.signal.aborted || event.status !== "completed") return;
        const changes = extractV2FileChanges(
          event.tool,
          event.input,
          event.result
        );
        if (changes.length === 0) return;
        try {
          const session = await ctx.session.get({ sessionID: event.sessionID });
          if (controller.signal.aborted || !matchesLocation(session.location.directory))
            return;
          trackedSessions.add(event.sessionID);
          await tracker.track(event.sessionID, event.id, changes);
        } catch (error) {
          logger.warn(`Could not track OpenCode tool activity: ${error}`);
        }
      })
    );
    registrations.push(
      await ctx.session.hook("prompt", async (event) => {
        if (!controller.signal.aborted)
          await tracker.processHeartbeat(false, event.sessionID);
      })
    );
  } catch (error) {
    controller.abort();
    await Promise.all(
      registrations.map((registration) => registration.dispose())
    );
    throw error;
  }
  const events = (async () => {
    while (!controller.signal.aborted) {
      try {
        for await (const event of ctx.event.subscribe({
          signal: controller.signal
        })) {
          if (controller.signal.aborted) break;
          const sessionID = event.data.sessionID;
          if (!sessionID || !trackedSessions.has(sessionID)) continue;
          if (event.location && !matchesLocation(event.location.directory))
            continue;
          if (event.type === "session.deleted" || event.type === "session.execution.succeeded" || event.type === "session.execution.failed" || event.type === "session.execution.interrupted" || event.type === "session.idle" || event.type === "session.status" && event.data.status?.type === "idle") {
            trackedSessions.delete(sessionID);
            await tracker.processHeartbeat(true, sessionID);
          }
        }
      } catch (error) {
        if (!controller.signal.aborted)
          logger.warn(`OpenCode event stream disconnected: ${error}`);
      }
      if (!controller.signal.aborted) {
        await setTimeout2(1e3, void 0, { signal: controller.signal }).catch(
          () => {
          }
        );
      }
    }
  })();
  return async () => {
    controller.abort();
    await events;
    await tracker.flush();
  };
}

// src/server.ts
var server_default = {
  id: "opencode.wakatime",
  server: v1Plugin,
  setup: setupV2
};
export {
  server_default as default
};
