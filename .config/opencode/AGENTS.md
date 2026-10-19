# Global Agent Instructions

Personal defaults that apply to every session, across all projects.

## Writing style

Never use em dashes or en dashes in any output: not in chat replies, not in
code comments, not in docs, not in commit messages, not in GitHub issues or PR
descriptions. This is a hard rule, not a preference to weigh against clarity.

The full banned set is the following code points:

| Name | Code point |
| --- | --- |
| em dash | `U+2014` |
| en dash | `U+2013` |
| figure dash | `U+2012` |
| horizontal bar | `U+2015` |
| minus sign | `U+2212` |
| hyphen | `U+2010` |
| non-breaking hyphen | `U+2011` |

They are listed by code point on purpose. Writing them literally, which an
earlier draft of this file did, would put the banned characters inside the file
that bans them.

Rewrite the sentence instead. These constructions are all acceptable:

- A comma, or two commas for a parenthetical aside: "The connector is fast, and
  it retries on 429."
- A full stop: "Run the sync. Then ask the question."
- A colon: "Three requirements: token auth, pagination, and a README."
- A single ASCII hyphen inside a compound word, which is not a dash:
  "full-snapshot", "read-only", "forget-on-delete", "document-vs-relational".

Before writing any file that will be committed, published, or quoted under the
user's name, check it:

```bash
python3 -c "
b=open('FILE',encoding='utf-8').read()
bad=[hex(ord(c)) for c in b if hex(ord(c)) in
     ('0x2014','0x2013','0x2012','0x2015','0x2212','0x2010','0x2011')]
print('FOUND:', bad) if bad else print('clean')
"
```

This matters most for anything published under the user's name: blog posts,
GitHub issues, PR descriptions, commit messages, and documentation. A reader
notices em dashes in prose, and the user has asked for their writing to be free
of them.
