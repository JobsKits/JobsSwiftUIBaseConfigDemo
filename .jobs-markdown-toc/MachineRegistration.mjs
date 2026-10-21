// Created by Jobs on 2026年10月21日，星期三.
// Register a trusted converter before the first checkout of this experiment.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const SELF = fileURLToPath(import.meta.url);
const ROOT = path.resolve(path.dirname(SELF), '..');
const DRIVER = 'jobs-markdown-toc';
const REPOSITORY = 'JobsSwiftUIBaseConfigDemo';
const RUNTIME = path.join(os.homedir(), '.local/share/jobs-markdown-toc/swiftui-experiment');
const CONFIG = path.join(RUNTIME, 'driver.gitconfig');
const STATE = path.join(RUNTIME, 'state.json');
const CONVERTER = path.join(RUNTIME, 'MarkdownToc.mjs');
const quote = value => "'" + value.replaceAll("'", "'\\''") + "'";
const hash = value => crypto.createHash('sha256').update(value).digest('hex');

function git(args, allowed = [0]) {
  const result = spawnSync('git', args, { cwd: ROOT, encoding: 'utf8' });
  if (result.error) throw result.error;
  if (!allowed.includes(result.status)) throw new Error(result.stderr.trim() || `git 退出码 ${result.status}`);
  return result;
}

function globalValues(key) {
  return git(['config', '--global', '--no-includes', '--null', '--get-all', key], [0, 1]).stdout.split('\0').filter(Boolean);
}

function atomicWrite(file, value, mode = 0o644) {
  const temporary = `${file}.new-${process.pid}`;
  fs.writeFileSync(temporary, value, { flag: 'wx', mode });
  fs.renameSync(temporary, file);
}

function saveState(state) {
  atomicWrite(STATE, JSON.stringify(state, null, 2) + '\n', 0o600);
}

function readState() {
  if (!fs.existsSync(STATE)) return null;
  const state = JSON.parse(fs.readFileSync(STATE, 'utf8'));
  if (state.version !== 1 || state.runtime !== RUNTIME || !Array.isArray(state.keys)) throw new Error('机器注册记录异常，保留原配置。');
  return state;
}

function remotePatterns() {
  const root = git(['rev-parse', '--show-toplevel']).stdout.trim();
  if (fs.realpathSync(root) !== fs.realpathSync(ROOT)) throw new Error('请从实验仓的工具目录运行安装。');
  const values = git(['config', '--local', '--get-regexp', '^remote\\..*\\.url$']).stdout.trim().split('\n');
  const patterns = new Set();
  for (const value of values) {
    const remote = value.slice(value.indexOf(' ') + 1);
    const scp = remote.match(/^git@([^:]+):(.+)$/);
    const url = scp ? new URL(`ssh://git@${scp[1]}/${scp[2]}`) : new URL(remote);
    if (url.password || url.search || url.hash || url.port || !['https:', 'ssh:'].includes(url.protocol)) throw new Error('实验注册仅支持无凭据、无自定义端口的 HTTPS / SSH 来源。');
    const repository = url.pathname.replace(/^\//, '').replace(/\.git$/, '');
    if (repository.split('/').at(-1) !== REPOSITORY) throw new Error('远端不属于指定实验仓，未扩大注册范围。');
    for (const suffix of ['', '.git']) {
      patterns.add(`https://${url.hostname}/${repository}${suffix}`);
      patterns.add(`git@${url.hostname}:${repository}${suffix}`);
      patterns.add(`ssh://git@${url.hostname}/${repository}${suffix}`);
    }
  }
  return [...patterns].sort();
}

function unregister(state) {
  for (const key of state.ownedKeys) {
    git(['config', '--global', '--fixed-value', '--unset-all', key, CONFIG], [0, 5]);
  }
  saveState({ ...state, active: false });
}

function install() {
  const patterns = remotePatterns();
  const keys = patterns.map(pattern => `includeIf.hasconfig:remote.*.url:${pattern}.path`);
  const state = readState();
  if (fs.existsSync(RUNTIME) && !state) throw new Error('运行目录已存在但无本工具记录，保留现场。');
  if (state) {
    if (JSON.stringify(state.keys) !== JSON.stringify(keys)) throw new Error('实验来源已变化，先核实旧注册范围。');
    for (const [file, digest] of Object.entries(state.files)) {
      if (!fs.existsSync(path.join(RUNTIME, file)) || hash(fs.readFileSync(path.join(RUNTIME, file))) !== digest) throw new Error(`机器副本被外部修改：${file}`);
    }
  }
  const source = fs.readFileSync(path.join(path.dirname(SELF), 'MarkdownToc.mjs'));
  const installer = fs.readFileSync(SELF);
  if (state?.active && (state.files['MarkdownToc.mjs'] !== hash(source) || state.files['MachineRegistration.mjs'] !== hash(installer) || state.node !== process.execPath)) {
    throw new Error('现行机器注册仍在使用旧副本；先运行 uninstall 撤回，再安装新版本，避免原地混合升级。');
  }
  const node = quote(process.execPath);
  fs.mkdirSync(RUNTIME, { recursive: true });
  const backup = path.join(RUNTIME, `backup-${Date.now()}`);
  fs.mkdirSync(backup, { mode: 0o700 });
  for (const file of ['MarkdownToc.mjs', 'MachineRegistration.mjs', 'driver.gitconfig', 'state.json']) {
    if (fs.existsSync(path.join(RUNTIME, file))) fs.copyFileSync(path.join(RUNTIME, file), path.join(backup, file));
  }
  const previous = Object.fromEntries(keys.map(key => [key, globalValues(key)]));
  fs.writeFileSync(path.join(backup, 'include-values.json'), JSON.stringify(previous, null, 2) + '\n', { mode: 0o600 });
  atomicWrite(CONVERTER, source);
  atomicWrite(path.join(RUNTIME, 'MachineRegistration.mjs'), installer);
  const command = `${node} ${quote(fs.realpathSync(CONVERTER))}`;
  const temporary = `${CONFIG}.new`;
  fs.writeFileSync(temporary, '');
  for (const [key, value] of Object.entries({ clean: `${command} clean`, smudge: `${command} smudge`, required: 'true' })) {
    git(['config', '--file', temporary, `filter.${DRIVER}.${key}`, value]);
  }
  fs.renameSync(temporary, CONFIG);
  const files = Object.fromEntries(['MarkdownToc.mjs', 'MachineRegistration.mjs', 'driver.gitconfig'].map(file => [file, hash(fs.readFileSync(path.join(RUNTIME, file)))]));
  const ownedKeys = [...new Set([...(state?.ownedKeys ?? []), ...keys.filter(key => !previous[key].includes(CONFIG))])];
  const next = { version: 1, runtime: RUNTIME, keys, ownedKeys, patterns, files, node: process.execPath, active: true, backup };
  saveState(next);
  atomicWrite(path.join(RUNTIME, 'README.md'), `# Markdown 目录本机实验驱动\n\n本目录是 ${REPOSITORY} 的可信机器副本，依赖 Node.js 与 Git。全局配置只按 state.json 中的精确 remote 地址条件加载 driver.gitconfig；不运行被克隆仓库的脚本、不增加 hooks。\n\n安装入口在原实验仓 .jobs-markdown-toc/MachineRegistration.mjs；MarkdownToc.mjs 仅负责 stdin clean / smudge。backup-* 保存更新前的运行文件及受影响的 include 值，state.json 记录范围与副本哈希。\n\n状态：node ${quote(path.join(RUNTIME, 'MachineRegistration.mjs'))} status\n\n撤回：node ${quote(path.join(RUNTIME, 'MachineRegistration.mjs'))} uninstall\n\n撤回只移除本工具添加的精确 include 值，保留其它配置、各仓 local 驱动及本目录备份；不改提交或远端。\n`);
  const added = [];
  try {
    for (const key of keys) {
      if (!globalValues(key).includes(CONFIG)) {
        git(['config', '--global', '--add', key, CONFIG]);
        added.push(key);
      }
    }
  } catch (error) {
    for (const key of added.reverse()) git(['config', '--global', '--fixed-value', '--unset-all', key, CONFIG], [0, 5]);
    saveState({ ...next, active: state?.active ?? false });
    throw error;
  }
  console.log(`已为 ${REPOSITORY} 的 ${patterns.length} 个精确来源注册本机条件驱动；全新克隆无需仓内 install。`);
  console.log(`可信副本：${CONVERTER}\n备份：${backup}\n撤回：node ${quote(path.join(RUNTIME, 'MachineRegistration.mjs'))} uninstall`);
}

function withRegistrationLock(action) {
  fs.mkdirSync(path.dirname(RUNTIME), { recursive: true });
  const lock = `${RUNTIME}.lock`;
  const descriptor = fs.openSync(lock, 'wx', 0o600);
  try { action(); }
  finally { fs.closeSync(descriptor); fs.unlinkSync(lock); }
}

function main() {
  if (['GIT_DIR', 'GIT_WORK_TREE', 'GIT_COMMON_DIR', 'GIT_CONFIG_GLOBAL', 'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS'].some(key => process.env[key])) throw new Error('机器注册不接受 Git 定位或配置环境覆盖。');
  const [mode, ...extra] = process.argv.slice(2);
  if (extra.length) throw new Error('不接受额外参数。');
  if (mode === 'install') withRegistrationLock(install);
  else if (mode === 'status') {
    const state = readState();
    console.log(state ? JSON.stringify({ active: state.active, patterns: state.patterns, includesPresent: state.keys.filter(key => globalValues(key).includes(CONFIG)).length, runtime: RUNTIME }, null, 2) : '尚未注册。');
  } else if (mode === 'uninstall') {
    withRegistrationLock(() => {
      const state = readState();
      if (!state) throw new Error('无本工具注册记录，未修改全局配置。');
      unregister(state);
    });
    console.log('已精确移除本实验的条件 include；其它配置及各仓 local 驱动保留，运行副本与备份留存。');
  } else console.log('用法：node MachineRegistration.mjs install | status | uninstall\n仅为指定实验仓注册本机条件驱动；不提交、不推送、不安装 hooks。');
}

try { main(); }
catch (error) { console.error(`MachineRegistration：${error.message}`); process.exitCode = 1; }
