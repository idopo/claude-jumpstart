#!/usr/bin/env node
// PreToolUse hook: stops Claude from changing files inside protected folders (e.g. raw data).
// Usage in settings.json:  node "C:/Users/<you>/.claude/hooks/protect-folders.js" data/raw recordings
// Exit 2 blocks the tool call and shows stderr to Claude; exit 0 lets the normal flow continue.
// A guard against accidents, not a security boundary: reads are always allowed.

const FILE_TOOLS = new Set(['Write', 'Edit', 'MultiEdit', 'NotebookEdit']);
// Shell words that change or remove files; a command that only reads (ls, cat, head) passes.
const WRITE_WORDS = /\b(rm|mv|cp|del|rmdir|truncate|sed\s+-i|Remove-Item|Move-Item|Set-Content|Out-File)\b|>/;

function normalise(p) {
  return String(p).replace(/\\/g, '/').toLowerCase();
}

function insideFolder(filePath, folder) {
  const f = '/' + normalise(folder).replace(/^\/+|\/+$/g, '') + '/';
  return ('/' + normalise(filePath)).includes(f);
}

function blockedReason(event, folders) {
  const input = event.tool_input || {};
  if (FILE_TOOLS.has(event.tool_name)) {
    const target = input.file_path || input.notebook_path || '';
    const hit = folders.find((folder) => insideFolder(target, folder));
    return hit && `${target} is inside the protected folder "${hit}".`;
  }
  if (event.tool_name === 'Bash' || event.tool_name === 'PowerShell') {
    const command = input.command || '';
    const hit = folders.find((folder) => normalise(command).includes(normalise(folder).replace(/\/+$/, '')));
    return hit && WRITE_WORDS.test(command) && `the command may change files in the protected folder "${hit}".`;
  }
  return null;
}

let raw = '';
process.stdin.on('data', (chunk) => { raw += chunk; });
process.stdin.on('end', () => {
  let event;
  try { event = JSON.parse(raw); } catch { process.exit(0); }
  const reason = blockedReason(event, process.argv.slice(2));
  if (reason) {
    process.stderr.write(`Blocked by protect-folders hook: ${reason} Raw data is read-only. Write results to a different folder, or ask the user.\n`);
    process.exit(2);
  }
  process.exit(0);
});
