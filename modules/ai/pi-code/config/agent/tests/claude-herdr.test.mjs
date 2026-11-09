import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { stripTypeScriptTypes } from 'node:module';

const base = new URL('../extensions/', import.meta.url);
async function load(name, mocks) {
  let source = await readFile(new URL(name, base), 'utf8');
  source = stripTypeScriptTypes(source, { mode: 'strip' });
  source = source.replace(/^import (.*?) from ["']([^"']+)["'];?$/gm, (line, rawBinding, module) => {
    const binding = rawBinding.replace(/,?\s*type \w+/g, '');
    return binding.startsWith('{') ? `const ${binding} = globalThis.__mocks[${JSON.stringify(module)}];` : `const ${binding} = globalThis.__mocks[${JSON.stringify(module)}];`;
  });
  globalThis.__mocks = mocks;
  return (await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}#${Math.random()}`)).default;
}
const type = new Proxy({}, { get: () => (...args) => args });
const transcript = JSON.stringify({ type: 'message', message: { role: 'assistant', stopReason: 'stop', content: [{ type: 'text', text: 'Completed test work.' }] } });
const mocks = {
  typebox: { Type: type },
  'node:fs/promises': { mkdir: async () => {}, readFile: async () => transcript },
  'node:os': { homedir: () => '/test-home' },
  'node:path': { join: (...parts) => parts.join('/') },
  'node:crypto': { randomUUID: () => '12345678-aaaa-bbbb-cccc-123456789abc' },
};
function harness(exec) {
  let tool;
  const hooks = {};
  return {
    pi: { on: (name, fn) => { hooks[name] = fn; }, registerTool: (value) => { tool = value; }, exec, getThinkingLevel: () => 'medium' },
    get tool() { return tool; }, hooks,
  };
}
const ctx = { cwd: '/project with spaces', model: { provider: 'openai', id: 'test-model' } };
const originalEnv = { HERDR_ENV: process.env.HERDR_ENV, HERDR_PANE_ID: process.env.HERDR_PANE_ID };
function inside() { process.env.HERDR_ENV = '1'; process.env.HERDR_PANE_ID = 'w9:p7'; }
function reply(result) { return { code: 0, stdout: JSON.stringify({ result }), stderr: '' }; }
try {
  await test('refuses invisible workers outside Herdr', async () => {
    delete process.env.HERDR_ENV;
    const h = harness(() => { throw Error('must not execute'); });
    (await load('herdr-subagents.ts', mocks))(h.pi);
    await assert.rejects(h.tool.execute('id', { agent: 'worker', task: 'test' }, undefined, undefined, ctx), /No invisible worker/);
  });
  await test('starts an interactive worker with correct cwd, pane, model, integration and transcript result', async () => {
    inside();
    const calls = [];
    const h = harness(async (cmd, args, opts) => {
      calls.push({ cmd, args, opts });
      if (args[1] === 'layout') return reply({ cols: 160, rows: 40 });
      if (args[1] === 'split') return reply({ pane: { pane_id: 'w9:p8' } });
      return reply({ state: 'idle' });
    });
    (await load('herdr-subagents.ts', mocks))(h.pi);
    const result = await h.tool.execute('id', { agent: 'worker', task: 'check this' }, undefined, undefined, ctx);
    assert.match(result.content[0].text, /Completed test work/);
    assert.equal(result.details.pane, 'w9:p8');
    const split = calls.find(c => c.args[1] === 'split').args;
    assert.ok(split.includes('--no-focus'));
    assert.equal(split[split.indexOf('--pane') + 1], 'w9:p7');
    assert.equal(split[split.indexOf('--direction') + 1], 'right');
    const args = calls.find(c => c.args[1] === 'start').args;
    assert.ok(args.includes('--no-extensions'));
    assert.ok(args.includes('/test-home/.pi/agent/extensions/herdr-agent-state.ts'));
    assert.ok(args.includes('/test-home/.pi/agent/extensions/claude-style.ts'));
    assert.ok(args.includes('test-model'));
    assert.ok(!args.includes('--print') && !args.includes('--mode'));
    assert.equal(calls.filter(c => c.args[1] === 'prompt').length, 1);
  });
  await test('blocked worker is retained and not auto-approved', async () => {
    inside();
    const calls = [];
    const h = harness(async (_cmd, args) => {
      calls.push(args);
      if (args[1] === 'split') return reply({ pane: { pane_id: 'w9:p8' } });
      return reply({ state: args[1] === 'get' ? 'blocked' : 'idle' });
    });
    (await load('herdr-subagents.ts', mocks))(h.pi);
    await assert.rejects(h.tool.execute('id', { agent: 'reviewer', task: 'test' }, undefined, undefined, ctx), /blocked.*\nWorker pane retained/s);
    assert.ok(!calls.some(c => c[1] === 'close' || c[1] === 'send-keys'));
  });
  await test('prompt failure is never retried; cancellation sends escape', async () => {
    inside();
    const calls = [];
    const controller = new AbortController();
    const h = harness(async (_cmd, args) => {
      calls.push(args);
      if (args[1] === 'split') return reply({ pane: { pane_id: 'w9:p8' } });
      if (args[1] === 'prompt') { controller.abort(); return { code: 1, stderr: 'cancelled', stdout: '' }; }
      return reply({});
    });
    (await load('herdr-subagents.ts', mocks))(h.pi);
    await assert.rejects(h.tool.execute('id', { agent: 'worker', task: 'test' }, controller.signal, undefined, ctx), /cancelled/);
    assert.equal(calls.filter(c => c[1] === 'prompt').length, 1);
    assert.deepEqual(calls.at(-1), ['agent', 'send-keys', 'pi-worker-12345678', 'esc']);
  });
  await test('UI is TUI-only and preserves the base editor body at narrow widths', async () => {
    const uiMocks = {
      '@earendil-works/pi-coding-agent': { CustomEditor: class { render() { return ['top', 'original editor cursor and body', 'bottom']; } } },
      '@earendil-works/pi-tui': { truncateToWidth: (text, width) => Array.from(text).slice(0, width).join('') },
      'node:os': { homedir: () => '/test-home' },
    };
    const h = harness();
    (await load('claude-style.ts', uiMocks))(h.pi);
    h.hooks.session_start({}, { mode: 'json' });
    let editorFactory, footerFactory;
    const theme = { fg: (_token, text) => text };
    const ui = { theme, setHeader() {}, setEditorComponent: fn => { editorFactory = fn; }, setFooter: fn => { footerFactory = fn; } };
    h.hooks.session_start({}, { ...ctx, mode: 'tui', isIdle: () => true, ui, getContextUsage: () => ({ percent: 12 }) });
    const editor = editorFactory({ requestRender() {} }, {}, {});
    for (const width of [1, 5, 20, 80, 160]) {
      const lines = editor.render(width);
      assert.equal(lines[1], 'original editor cursor and body');
      assert.ok(Array.from(lines[0]).length <= width);
      assert.ok(Array.from(lines.at(-1)).length <= width);
    }
    const footer = footerFactory({ requestRender() {} }, theme, { onBranchChange: () => () => {}, getGitBranch: () => 'main', getExtensionStatuses: () => new Map([['test', 'status']]) });
    assert.match(footer.render(160).join('\n'), /ready.*test-model.*12%.*status/);
    h.hooks.agent_start();
    assert.match(footer.render(160).join('\n'), /working/);
  });
} finally {
  for (const [key, value] of Object.entries(originalEnv)) {
    if (value === undefined) delete process.env[key]; else process.env[key] = value;
  }
  delete globalThis.__mocks;
}
