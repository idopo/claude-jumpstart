import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const hook = path.join(path.dirname(fileURLToPath(import.meta.url)), '..', 'hooks', 'protect-folders.js');

function runHook(payload, folders = ['data/raw']) {
  return spawnSync(process.execPath, [hook, ...folders], { input: JSON.stringify(payload), encoding: 'utf8' });
}

test('blocks Write inside a protected folder', () => {
  const r = runHook({ tool_name: 'Write', tool_input: { file_path: '/home/a/proj/data/raw/s1.csv' } });
  assert.equal(r.status, 2);
  assert.match(r.stderr, /data\/raw/);
});

test('blocks Edit with Windows backslash paths', () => {
  const r = runHook({ tool_name: 'Edit', tool_input: { file_path: 'C:\\Users\\a\\proj\\data\\raw\\s1.csv' } });
  assert.equal(r.status, 2);
});

test('allows Write outside the protected folder', () => {
  const r = runHook({ tool_name: 'Write', tool_input: { file_path: '/home/a/proj/data/processed/s1.csv' } });
  assert.equal(r.status, 0);
});

test('does not match a folder that only shares a prefix', () => {
  const r = runHook({ tool_name: 'Write', tool_input: { file_path: '/home/a/proj/data/raw_backup/s1.csv' } });
  assert.equal(r.status, 0);
});

test('blocks a Bash command that deletes inside the protected folder', () => {
  const r = runHook({ tool_name: 'Bash', tool_input: { command: 'rm -rf data/raw/old' } });
  assert.equal(r.status, 2);
});

test('allows a Bash command that only reads the protected folder', () => {
  const r = runHook({ tool_name: 'Bash', tool_input: { command: 'ls data/raw && head data/raw/s1.csv' } });
  assert.equal(r.status, 0);
});

test('allows everything when stdin is not JSON', () => {
  const r = spawnSync(process.execPath, [hook, 'data/raw'], { input: 'garbage', encoding: 'utf8' });
  assert.equal(r.status, 0);
});
