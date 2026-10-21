// Created by Jobs on 2026年10月21日，星期三.
// Every Git repository and config used here is disposable; the real HOME is unchanged.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath, pathToFileURL } from 'node:url';

const tool = path.resolve(process.argv[2] ?? fileURLToPath(new URL('../MarkdownToc.mjs', import.meta.url)));
const workspace = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), 'jobs-toc-fresh-clone-fixture-')));
const globalConfig = path.join(workspace, 'isolated.gitconfig');
const trustedDirectory = path.join(workspace, 'trusted-driver');
const includeConfig = path.join(trustedDirectory, 'driver.gitconfig');
const stableConverter = path.join(trustedDirectory, 'MarkdownToc.mjs');
const bare = path.join(workspace, 'fixture.git');
const producer = path.join(workspace, 'producer');
const consumer = path.join(workspace, 'consumer');
const unmatched = path.join(workspace, 'unmatched');
const uninstalled = path.join(workspace, 'uninstalled');
const hooks = path.join(workspace, 'empty-hooks');
const exactRemote = 'https://github.com/JobsTocFixture/ConditionalClone.git';
const otherRemote = 'https://github.com/JobsTocFixture/AnotherRepository.git';
const driver = 'jobs-markdown-toc';
const conditionalKey = `includeIf.hasconfig:remote.*.url:${exactRemote}.path`;
const env = Object.fromEntries(Object.entries(process.env).filter(([key]) => !key.startsWith('GIT_')));
Object.assign(env, {
  GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: globalConfig, GIT_CONFIG_SYSTEM: '/dev/null',
  GIT_TERMINAL_PROMPT: '0', GIT_AUTHOR_NAME: 'Jobs TOC fixture', GIT_AUTHOR_EMAIL: 'toc-fixture@example.invalid',
  GIT_COMMITTER_NAME: 'Jobs TOC fixture', GIT_COMMITTER_EMAIL: 'toc-fixture@example.invalid',
});
for (const directory of [trustedDirectory, hooks, producer]) fs.mkdirSync(directory);
fs.writeFileSync(globalConfig, '');
fs.copyFileSync(tool, stableConverter);
const { cleanMarkdown, smudgeMarkdown } = await import(pathToFileURL(stableConverter).href);
const files = [
  'README.md', '.jobs-markdown-toc/README.md', 'JobsByPods/JobsSwiftUIDebugPanel@Pods/README.md',
  'ScriptsByPods/README.md', 'ScriptsByPods/codegraph_export_md.command/README.md',
  'ScriptsByPods/codegraph_init.command/README.md', 'ScriptsByPods/【MacOS】🌐CocoaPods源自动选择.command/README.md',
  'ScriptsByPods/【MacOS】🌐CocoaPods网络适配.command/README.md',
  'SwiftUIDoc.md/SwiftUI工程项目框架配置方案@Jobs.md/SwiftUI工程项目框架配置方案@Jobs.md',
  'SwiftUI相关经验.md/SwiftUI相关经验.md',
];
const sources = new Map(files.map((file, index) => [file, `# 文档 ${index + 1}\n\n[toc]\n\n## 第一章\n\n正文 ${file}。\n\n### 子章节\n\n末尾。\n`]));
const passed = [];
const shellQuote = value => `'${value.replaceAll("'", "'\\''")}'`;

function execute(command, args, directory = workspace, expected = 0) {
  const result = spawnSync(command, args, { cwd: directory, env, encoding: 'utf8', maxBuffer: 16 * 1024 * 1024 });
  assert.equal(result.status, expected, `${command} ${args.join(' ')}\n${result.stdout}\n${result.stderr}`);
  return result.stdout;
}
function git(directory, args, expected = 0) {
  return execute('git', ['-c', `core.hooksPath=${hooks}`, '-c', 'commit.gpgsign=false',
    '-c', 'protocol.file.allow=always', '-c', 'core.autocrlf=false', '-c', 'checkout.workers=4', ...args], directory, expected);
}
function check(name, callback) {
  callback();
  passed.push(name);
  console.log(`PASS ${name}`);
}
function document(directory, file) { return fs.readFileSync(path.join(directory, file), 'utf8'); }
function assertSource(directory) {
  for (const [file, source] of sources) {
    assert.equal(document(directory, file), source, file);
    assert.equal(document(directory, file).includes('<!-- jobs-toc:start -->'), false, file);
    const index = git(directory, ['show', `:${file}`]);
    assert.equal(index, cleanMarkdown(source), `${file}: index remains generated`);
    assert.equal(git(directory, ['show', `HEAD:${file}`]), index, `${file}: HEAD remains generated`);
  }
  assert.equal(git(directory, ['status', '--porcelain']), '');
}
function assertGenerated(directory) {
  for (const [file, source] of sources) {
    assert.equal(document(directory, file), cleanMarkdown(source), file);
    assert.equal(smudgeMarkdown(document(directory, file)), source);
  }
  assert.equal(git(directory, ['status', '--porcelain']), '');
}

try {
  git(workspace, ['config', '--file', includeConfig, `filter.${driver}.clean`, `${shellQuote(process.execPath)} ${shellQuote(stableConverter)} clean`]);
  git(workspace, ['config', '--file', includeConfig, `filter.${driver}.smudge`, `${shellQuote(process.execPath)} ${shellQuote(stableConverter)} smudge`]);
  git(workspace, ['config', '--file', includeConfig, `filter.${driver}.required`, 'true']);
  git(workspace, ['config', '--global', conditionalKey, includeConfig]);
  git(workspace, ['init', '--bare', '--initial-branch=main', bare]);
  git(producer, ['init', '--initial-branch=main']);
  for (const [file, source] of sources) {
    fs.mkdirSync(path.dirname(path.join(producer, file)), { recursive: true });
    fs.writeFileSync(path.join(producer, file), cleanMarkdown(source));
  }
  fs.writeFileSync(path.join(producer, '.gitattributes'), files.map(file => `${JSON.stringify('/' + file)} filter=${driver}`).join('\n') + '\n');
  // A repository-provided program must never be executed by the trusted global driver.
  fs.writeFileSync(path.join(producer, '.jobs-markdown-toc/MarkdownToc.mjs'), "throw new Error('Untrusted repository script executed');\n");
  git(producer, ['add', '.']);
  git(producer, ['commit', '-m', 'fixture generated documents']);
  git(producer, ['remote', 'add', 'origin', bare]);
  git(producer, ['push', '--set-upstream', 'origin', 'main']);

  check('fresh clone activates matching hasconfig include before first checkout, without install', () => {
    git(workspace, ['-c', `url.${bare}.insteadOf=${exactRemote}`, 'clone', exactRemote, consumer]);
    assert.equal(git(consumer, ['remote', 'get-url', 'origin']).trim(), exactRemote);
    assert.equal(git(consumer, ['config', '--local', '--get', `filter.${driver}.clean`], 1), '');
    assert.equal(git(consumer, ['config', '--local', '--get', `filter.${driver}.smudge`], 1), '');
    assert.equal(git(consumer, ['config', '--get', `filter.${driver}.required`]).trim(), 'true');
    assertSource(consumer);
  });

  check('matching driver comes from trusted stable file, not repository script or checkout ordering', () => {
    const loaded = git(consumer, ['config', '--show-origin', '--get', `filter.${driver}.smudge`]);
    assert.ok(loaded.includes(includeConfig));
    assert.ok(loaded.includes(stableConverter));
    assert.equal(document(consumer, '.jobs-markdown-toc/MarkdownToc.mjs'), "throw new Error('Untrusted repository script executed');\n");
    assertSource(consumer);
  });

  check('plain local edits stage generated form and keep source worktree clean', () => {
    const changed = sources.get('README.md').replace('## 第一章', '## 本机编辑后的第一章');
    sources.set('README.md', changed);
    fs.writeFileSync(path.join(consumer, 'README.md'), changed);
    git(consumer, ['add', 'README.md']);
    assert.equal(git(consumer, ['show', ':README.md']), cleanMarkdown(changed));
    assert.equal(document(consumer, 'README.md'), changed);
    git(consumer, ['commit', '-m', 'fixture local source edit']);
    git(consumer, ['push', bare, 'main']);
    assertSource(consumer);
    git(producer, ['pull', '--ff-only', bare, 'main']);
  });

  check('git pull applies smudge to updated documents while preserving generated HEAD/index', () => {
    for (const [file, source] of sources) {
      const changed = source.replace('### 子章节', '### 拉取更新后的子章节');
      sources.set(file, changed);
      fs.writeFileSync(path.join(producer, file), cleanMarkdown(changed));
    }
    git(producer, ['add', '.']);
    git(producer, ['commit', '-m', 'fixture remote heading changes']);
    git(producer, ['push', bare, 'main']);
    // The stored origin still matches the conditional include. Pull from the local bare avoids any network.
    git(consumer, ['pull', '--ff-only', bare, 'main']);
    assert.equal(git(consumer, ['remote', 'get-url', 'origin']).trim(), exactRemote);
    assertSource(consumer);
  });

  check('unmatched remote clone does not activate this filter', () => {
    git(workspace, ['-c', `url.${bare}.insteadOf=${otherRemote}`, 'clone', otherRemote, unmatched]);
    assert.equal(git(unmatched, ['remote', 'get-url', 'origin']).trim(), otherRemote);
    assert.equal(git(unmatched, ['config', '--get', `filter.${driver}.smudge`], 1), '');
    assertGenerated(unmatched);
  });

  check('removing conditional include returns a new matching clone to generated form', () => {
    git(workspace, ['config', '--global', '--unset-all', conditionalKey]);
    git(workspace, ['-c', `url.${bare}.insteadOf=${exactRemote}`, 'clone', exactRemote, uninstalled]);
    assert.equal(git(uninstalled, ['config', '--get', `filter.${driver}.smudge`], 1), '');
    assertGenerated(uninstalled);
  });
  console.log(JSON.stringify({ passed: passed.length, documents: files.length, workspace,
    origin: exactRemote, cloneCheckoutWorkers: 4, networkUsed: false, globalConfig,
    trustedConverter: stableConverter, hostHomeChanged: false }, null, 2));
} catch (error) {
  console.error(`Fixture retained at ${workspace}`);
  throw error;
}
