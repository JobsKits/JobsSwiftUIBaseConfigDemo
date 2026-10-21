// Created by Jobs on 2026年10月21日，星期三.
// Run against a copied tool in disposable repositories; no real remotes are used.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import crypto from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { fileURLToPath, pathToFileURL } from 'node:url';

const tool = path.resolve(process.argv[2] ?? path.join(path.dirname(fileURLToPath(import.meta.url)), '..', 'MarkdownToc.mjs'));
const root = fs.mkdtempSync(path.join(os.tmpdir(), 'jobs-toc-git-regression-'));
const producer = path.join(root, 'producer');
const consumer = path.join(root, 'consumer');
const unconfigured = path.join(root, 'unconfigured');
const manual = path.join(root, 'manual-config');
const remote = path.join(root, 'remote.git');
const hooks = path.join(root, 'hooks');
fs.mkdirSync(hooks);
const env = Object.fromEntries(Object.entries(process.env).filter(([key]) => !key.startsWith('GIT_')));
Object.assign(env, {
  GIT_CONFIG_NOSYSTEM: '1',
  GIT_CONFIG_GLOBAL: '/dev/null',
  GIT_CONFIG_SYSTEM: '/dev/null',
  GIT_TERMINAL_PROMPT: '0',
  GIT_AUTHOR_NAME: 'Jobs TOC fixture',
  GIT_AUTHOR_EMAIL: 'toc-fixture@example.invalid',
  GIT_COMMITTER_NAME: 'Jobs TOC fixture',
  GIT_COMMITTER_EMAIL: 'toc-fixture@example.invalid',
});
const script = '.jobs-markdown-toc/MarkdownToc.mjs';
const keys = ['clean', 'smudge', 'required'].map(key => `filter.jobs-markdown-toc.${key}`);
const passed = [];
const evidence = [];
const bytes = file => fs.readFileSync(file);
const text = (directory, file) => fs.readFileSync(path.join(directory, file), 'utf8');
const write = (directory, file, value) => fs.writeFileSync(path.join(directory, file), value);
const hash = value => crypto.createHash('sha256').update(value).digest('hex');

function execute(command, args, directory = root, expected = 0) {
  const result = spawnSync(command, args, { cwd: directory, env, encoding: 'utf8', maxBuffer: 16 * 1024 * 1024 });
  assert.equal(result.status, expected, `${command} ${args.join(' ')}\n${result.stdout}\n${result.stderr}`);
  return result;
}

function git(directory, args, expected = 0) {
  return execute('git', ['-c', `core.hooksPath=${hooks}`, '-c', 'commit.gpgsign=false', '-c', 'protocol.file.allow=always',
    '-c', 'core.autocrlf=false', ...args], directory, expected).stdout;
}

function run(directory, mode, expected = 0) {
  return execute(process.execPath, [script, mode], directory, expected);
}

function indexState(directory) {
  return { entries: git(directory, ['ls-files', '--stage', '-z']), flags: git(directory, ['ls-files', '-v', '-z']) };
}

function check(name, callback) {
  callback();
  passed.push(name);
  console.log(`PASS ${name}`);
}

function assertSource(actual, expected) {
  assert.equal(actual, expected);
  assert.equal(actual.includes('<!-- jobs-toc:start -->'), false);
}

function assertGenerated(actual, source) {
  assert.ok(actual.includes('<!-- jobs-toc:start -->'));
  assert.ok(actual.includes('<details>'));
  assert.equal(smudgeMarkdown(actual), source);
  assert.equal(cleanMarkdown(actual), actual);
}

const originalTool = bytes(tool);
const { cleanMarkdown, smudgeMarkdown, START } = await import(pathToFileURL(tool).href);
const base = '# 临时实验\n\n[toc]\n\n## 一级\n\n正文。\n\n### 子节\n\n更多正文。\n';
const guide = '# 指南\n\n[toc]\n\n## 独立章节\n\n指南正文。\n';
let current = base;

try {
  check('token case / CRLF / BOM / no final newline round-trip', () => {
    for (const source of [base, base.replace('[toc]', '  [TOC]\t'), '\uFEFF' + base.replaceAll('\n', '\r\n'),
      '\uFEFF[ToC]\r\n\r\n## 标题\r\n内容', base.trimEnd(), base.replace('[toc]', '[TOC]\n\n[toc]')]) {
      const generated = cleanMarkdown(source);
      assertGenerated(generated, source);
      assert.equal(smudgeMarkdown(smudgeMarkdown(generated)), source);
    }
    const withExamples = base + '\n```md\n[toc]\n## 示例标题\n```\n\n<details>\n<summary>手写折叠</summary>\n\n保留我。\n\n</details>\n';
    assert.equal(smudgeMarkdown(cleanMarkdown(withExamples)), withExamples);
    assert.ok(!cleanMarkdown(withExamples).includes('- [示例标题]'));
  });

  git(root, ['init', '--bare', '--initial-branch=main', remote]);
  fs.mkdirSync(producer);
  git(producer, ['init', '--initial-branch=main']);
  fs.mkdirSync(path.join(producer, '.jobs-markdown-toc'));
  write(producer, script, originalTool);
  write(producer, '.jobs-markdown-toc/manifest.json', JSON.stringify({ version: 1, files: ['README.md', 'guide.md'] }, null, 2) + '\n');
  write(producer, '.gitattributes', '/README.md filter=jobs-markdown-toc\n/guide.md filter=jobs-markdown-toc\n');
  write(producer, 'README.md', base);
  write(producer, 'guide.md', guide);
  run(producer, 'install');

  check('full-file add stores collapsible indented TOC; disk keeps [toc]', () => {
    git(producer, ['add', '.gitattributes', '.jobs-markdown-toc', 'README.md', 'guide.md']);
    const raw = git(producer, ['show', ':README.md']);
    assertGenerated(raw, base);
    assert.ok(raw.includes('\n  - [子节]'));
    assertSource(text(producer, 'README.md'), base);
    run(producer, 'check');
    git(producer, ['commit', '-m', 'fixture initial source']);
    assertGenerated(git(producer, ['show', 'HEAD:README.md']), base);
    assert.equal(git(producer, ['status', '--porcelain']), '');
    git(producer, ['remote', 'add', 'origin', remote]);
    git(producer, ['push', '--set-upstream', 'origin', 'main']);
  });

  git(root, ['clone', remote, consumer]);
  git(root, ['clone', remote, unconfigured]);
  git(root, ['clone', remote, manual]);
  check('clone has no local filter; install restores existing generated files', () => {
    git(consumer, ['config', '--local', '--get', keys[0]], 1);
    assertGenerated(text(consumer, 'README.md'), base);
    const failed = run(consumer, 'verify', 1);
    assert.match(failed.stderr, /restore/);
    const indexBefore = git(consumer, ['ls-files', '--stage', '-z']);
    run(consumer, 'install');
    assertSource(text(consumer, 'README.md'), base);
    assertSource(text(consumer, 'guide.md'), guide);
    assert.equal(git(consumer, ['ls-files', '--stage', '-z']), indexBefore);
    run(consumer, 'verify');
    const status = git(consumer, ['status', '--porcelain']);
    assert.equal(git(consumer, ['diff', '--exit-code', '--', 'README.md', 'guide.md']), '');
    evidence.push({ case: 'install-index-stat-cache', status: status.trim(), rawIndexEntriesUnchanged: true, contentDiffEmpty: true });
    assert.equal(status, '', 'install must refresh equivalent clean stat entries before subsequent pull');
  });

  check('config plus unchanged pull does not rewrite existing generated file', () => {
    for (const key of keys) git(unconfigured, ['config', '--local', key, git(producer, ['config', '--local', '--get', key]).trim()]);
    const before = text(unconfigured, 'README.md');
    const output = git(unconfigured, ['pull', '--ff-only']);
    assert.equal(text(unconfigured, 'README.md'), before);
    assertGenerated(before, base);
    const failed = run(unconfigured, 'verify', 1);
    assert.match(failed.stderr, /restore/);
    evidence.push({ case: 'unchanged-pull', output: output.trim(), diskRemainsGenerated: true });
  });

  check('unchanged checkout may skip writes; checkout of missing fixture invokes smudge', () => {
    git(unconfigured, ['checkout', '--', 'README.md', 'guide.md']);
    const skipped = text(unconfigured, 'README.md') !== base;
    evidence.push({ case: 'unchanged-checkout', skippedRewrite: skipped });
    fs.unlinkSync(path.join(unconfigured, 'README.md'));
    fs.unlinkSync(path.join(unconfigured, 'guide.md'));
    git(unconfigured, ['checkout', '--', 'README.md', 'guide.md']);
    assertSource(text(unconfigured, 'README.md'), base);
    assertSource(text(unconfigured, 'guide.md'), guide);
  });

  const first = git(producer, ['rev-parse', 'HEAD']).trim();
  current = base.replace('## 一级', '## 同步后的一级').replace('### 子节', '### 同步后的子节');
  write(producer, 'README.md', current);
  git(producer, ['add', 'README.md']);
  git(producer, ['commit', '-m', 'fixture heading update']);
  git(producer, ['push']);

  check('real git pull --ff-only automatically restores new README to [toc]', () => {
    const output = git(consumer, ['pull', '--ff-only']);
    assertSource(text(consumer, 'README.md'), current);
    assertGenerated(git(consumer, ['show', 'HEAD:README.md']), current);
    assert.equal(git(consumer, ['status', '--porcelain']), '');
    evidence.push({ case: 'changed-pull', output: output.trim(), worktreeHash: hash(current), rawCommitHash: hash(git(consumer, ['show', 'HEAD:README.md'])) });
  });

  check('manual filter configuration plus restore permits real pull without changing staged content', () => {
    for (const key of keys) git(manual, ['config', '--local', key, git(producer, ['config', '--local', '--get', key]).trim()]);
    assertGenerated(text(manual, 'README.md'), base);
    const indexBefore = indexState(manual);
    const configBefore = bytes(path.join(manual, '.git/config'));
    run(manual, 'restore');
    assertSource(text(manual, 'README.md'), base);
    assert.deepEqual(indexState(manual), indexBefore);
    assert.deepEqual(bytes(path.join(manual, '.git/config')), configBefore);
    assert.equal(git(manual, ['status', '--porcelain']), '');
    git(manual, ['pull', '--ff-only']);
    assertSource(text(manual, 'README.md'), current);
    assertGenerated(git(manual, ['show', 'HEAD:README.md']), current);
  });

  check('switch between different README blobs also runs smudge', () => {
    git(consumer, ['switch', '--detach', first]);
    assertSource(text(consumer, 'README.md'), base);
    git(consumer, ['switch', 'main']);
    assertSource(text(consumer, 'README.md'), current);
  });

  let stagedGuide;
  let localGuide;
  check('pull preserves unrelated staged plus unstaged edits', () => {
    write(consumer, 'guide.md', guide + '\n已暂存正文。\n');
    git(consumer, ['add', 'guide.md']);
    stagedGuide = git(consumer, ['show', ':guide.md']);
    localGuide = guide + '\n已暂存正文。\n\n未暂存正文。\n';
    write(consumer, 'guide.md', localGuide);
    current += '\n## 后续同步\n\n远端新增正文。\n';
    write(producer, 'README.md', current);
    git(producer, ['add', 'README.md']);
    git(producer, ['commit', '-m', 'fixture second update']);
    git(producer, ['push']);
    git(consumer, ['pull', '--ff-only']);
    assertSource(text(consumer, 'README.md'), current);
    assert.equal(git(consumer, ['show', ':guide.md']), stagedGuide);
    assertSource(text(consumer, 'guide.md'), localGuide);
    assert.match(git(consumer, ['status', '--porcelain']), /MM guide\.md/);
  });

  check('restore keeps current body, staged index and local Git config; repeated restore is idempotent', () => {
    const withLocalBody = current + '\n本地新增且未暂存正文。\n';
    write(consumer, 'README.md', cleanMarkdown(withLocalBody));
    const indexBefore = indexState(consumer);
    const configBefore = bytes(path.join(consumer, '.git/config'));
    run(consumer, 'verify', 1);
    run(consumer, 'restore');
    assertSource(text(consumer, 'README.md'), withLocalBody);
    assertSource(text(consumer, 'guide.md'), localGuide);
    assert.deepEqual(indexState(consumer), indexBefore);
    assert.deepEqual(bytes(path.join(consumer, '.git/config')), configBefore);
    assert.equal(git(consumer, ['show', ':guide.md']), stagedGuide);
    const statBefore = fs.statSync(path.join(consumer, 'README.md'));
    run(consumer, 'restore');
    assert.equal(fs.statSync(path.join(consumer, 'README.md')).mtimeMs, statBefore.mtimeMs);
    assert.deepEqual(indexState(consumer), indexBefore);
    run(consumer, 'verify');
  });

  check('a later malformed file stops restore and install before any file/config write', () => {
    const generated = cleanMarkdown(current + '\n保留的本地正文。\n');
    const malformed = `${START}\n<details>\n损坏的目录块。\n`;
    write(consumer, 'README.md', generated);
    write(consumer, 'guide.md', malformed);
    const indexBefore = bytes(path.join(consumer, '.git/index'));
    const configBefore = bytes(path.join(consumer, '.git/config'));
    const stateBefore = bytes(path.join(consumer, '.git/jobs-markdown-toc.json'));
    for (const mode of ['restore', 'install']) {
      run(consumer, mode, 1);
      assert.equal(text(consumer, 'README.md'), generated);
      assert.equal(text(consumer, 'guide.md'), malformed);
      assert.deepEqual(bytes(path.join(consumer, '.git/index')), indexBefore);
      assert.deepEqual(bytes(path.join(consumer, '.git/config')), configBefore);
      assert.deepEqual(bytes(path.join(consumer, '.git/jobs-markdown-toc.json')), stateBefore);
    }
    write(consumer, 'guide.md', localGuide);
    run(consumer, 'restore');
  });

  check('restore preserves mixed-case tokens, CRLF, BOM, end-of-file bytes', () => {
    const indexBefore = indexState(consumer);
    for (const source of ['\uFEFF[ToC]\r\n\r\n## 一级\r\n\r\n### 子节\r\n正文', '\uFEFF' + base.replace('[toc]', ' [TOC]\t').replaceAll('\n', '\r\n')]) {
      write(consumer, 'README.md', cleanMarkdown(source));
      run(consumer, 'verify', 1);
      run(consumer, 'restore');
      assert.deepEqual(bytes(path.join(consumer, 'README.md')), Buffer.from(source));
      run(consumer, 'verify');
    }
    assert.deepEqual(indexState(consumer), indexBefore);
  });

  check('install preserves current uncommitted body and staged blob', () => {
    const source = current + '\n安装时保留的未暂存正文。\n';
    write(consumer, 'README.md', cleanMarkdown(source));
    const indexBefore = git(consumer, ['ls-files', '--stage', '-z']);
    run(consumer, 'install');
    assertSource(text(consumer, 'README.md'), source);
    assertSource(text(consumer, 'guide.md'), localGuide);
    assert.equal(git(consumer, ['ls-files', '--stage', '-z']), indexBefore);
    assert.equal(git(consumer, ['show', ':guide.md']), stagedGuide);
  });

  check('split index retains staged content and flags through install and restore', () => {
    const source = smudgeMarkdown(git(consumer, ['show', ':README.md']));
    write(consumer, 'README.md', cleanMarkdown(source));
    git(consumer, ['update-index', '--', 'README.md']);
    git(consumer, ['update-index', '--split-index']);
    const before = indexState(consumer);
    run(consumer, 'install');
    assert.deepEqual(indexState(consumer), before);
    assertSource(text(consumer, 'README.md'), source);
    assertSource(text(consumer, 'guide.md'), localGuide);
    assert.equal(git(consumer, ['status', '--porcelain', '--', 'README.md']), '');
    write(consumer, 'README.md', cleanMarkdown(source));
    git(consumer, ['update-index', '--', 'README.md']);
    assert.deepEqual(indexState(consumer), before);
    run(consumer, 'restore');
    assert.deepEqual(indexState(consumer), before);
    assertSource(text(consumer, 'README.md'), source);
    assert.equal(git(consumer, ['status', '--porcelain', '--', 'README.md']), '');
    assert.equal(git(consumer, ['show', ':guide.md']), stagedGuide);
  });

  check('existing index.lock is preserved; restored body survives and retry succeeds', () => {
    const source = text(consumer, 'README.md');
    write(consumer, 'README.md', cleanMarkdown(source));
    const before = indexState(consumer);
    const rawIndex = bytes(path.join(consumer, '.git/index'));
    const lock = path.join(consumer, '.git/index.lock');
    const lockBody = 'owned by another fixture Git operation\n';
    fs.writeFileSync(lock, lockBody, { flag: 'wx' });
    const failed = run(consumer, 'restore', 1);
    assert.match(failed.stderr, /文档已恢复.*缓存未刷新/);
    assert.equal(fs.readFileSync(lock, 'utf8'), lockBody);
    assert.deepEqual(bytes(path.join(consumer, '.git/index')), rawIndex);
    assert.deepEqual(indexState(consumer), before);
    assertSource(text(consumer, 'README.md'), source);
    assertSource(text(consumer, 'guide.md'), localGuide);
    fs.unlinkSync(lock);
    run(consumer, 'restore');
    assert.equal(fs.existsSync(lock), false);
    assert.deepEqual(indexState(consumer), before);
    assertSource(text(consumer, 'README.md'), source);
    assert.equal(git(consumer, ['show', ':guide.md']), stagedGuide);
  });

  fs.writeFileSync(path.join(root, 'report.json'), JSON.stringify({ tool, toolHash: hash(originalTool), passed, evidence }, null, 2) + '\n');
  console.log(`\n${passed.length} groups passed. Temporary evidence retained: ${root}`);
} catch (error) {
  fs.writeFileSync(path.join(root, 'report.json'), JSON.stringify({ tool, toolHash: hash(originalTool), passed, evidence, error: error.stack }, null, 2) + '\n');
  console.error(`Temporary evidence retained: ${root}`);
  throw error;
}
