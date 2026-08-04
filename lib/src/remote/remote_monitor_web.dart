/// Static HTML/CSS/JS served by [RemoteMonitorServer].
abstract final class RemoteMonitorWeb {
  RemoteMonitorWeb._();

  static const indexHtml = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Network Monitor</title>
  <link rel="stylesheet" href="/app.css" />
</head>
<body>
  <div id="app">
    <header class="topbar">
      <div class="topbar-row">
        <button id="backBtn" class="icon-btn hidden" title="Back" aria-label="Back">←</button>
        <h1 id="pageTitle">Network Monitor</h1>
        <div class="topbar-actions">
          <button id="detailSearchToggle" class="icon-btn hidden" title="Search in details">⌕</button>
          <button id="clearBtn" class="icon-btn" title="Clear all">🗑</button>
        </div>
      </div>
      <div id="statusLine" class="status-line">Connecting…</div>
    </header>

    <section id="listView" class="view">
      <div class="search-panel">
        <div class="search-row">
          <input id="searchInput" type="search" placeholder="Search requests..." />
          <button id="scopesToggle" class="icon-btn" title="Search scopes">⚙</button>
        </div>
        <div id="scopesPanel" class="scopes-panel hidden"></div>
        <div id="methodFilters" class="chips"></div>
      </div>
      <div id="recordList" class="record-list"></div>
      <div id="emptyState" class="empty hidden">
        <div class="empty-icon">⇄</div>
        <p>No HTTP requests recorded</p>
        <p class="muted">Requests will appear here when monitoring is active</p>
      </div>
    </section>

    <section id="detailView" class="view hidden">
      <div id="detailSearchBar" class="detail-search hidden">
        <input id="detailSearchInput" type="search" placeholder="Search in request / response..." />
        <div class="detail-search-nav">
          <span id="detailMatchLabel" class="muted">No matches</span>
          <button id="prevMatch" class="icon-btn" title="Previous">↑</button>
          <button id="nextMatch" class="icon-btn" title="Next">↓</button>
          <button id="detailScopesToggle" class="icon-btn" title="Tab scopes">⚙</button>
          <button id="closeDetailSearch" class="icon-btn" title="Close">×</button>
        </div>
        <div id="detailScopesPanel" class="scopes-panel hidden"></div>
      </div>
      <div class="tabs" id="detailTabs">
        <button data-tab="0" class="tab active">Overview</button>
        <button data-tab="1" class="tab">Request</button>
        <button data-tab="2" class="tab">Response</button>
        <button data-tab="3" class="tab">Headers</button>
      </div>
      <div id="detailBody" class="detail-body"></div>
    </section>
  </div>
  <div id="toast" class="toast hidden"></div>
  <script src="/app.js"></script>
</body>
</html>
''';

  static const appCss = r'''
:root {
  --bg: #f5f5f7;
  --surface: #ffffff;
  --field: #f0f0f2;
  --border: #e2e2e6;
  --text: #1c1c1e;
  --muted: #6b6b70;
  --primary: #2563eb;
  --get: #2563eb;
  --post: #16a34a;
  --put: #ea580c;
  --patch: #9333ea;
  --delete: #dc2626;
  --ok: #16a34a;
  --err: #dc2626;
  --pending: #ea580c;
  --radius: 12px;
  --shadow: 0 1px 2px rgba(0,0,0,.06);
  font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif;
}
* { box-sizing: border-box; }
body {
  margin: 0;
  background: var(--bg);
  color: var(--text);
}
#app { max-width: 960px; margin: 0 auto; min-height: 100vh; background: var(--surface); }
.topbar {
  position: sticky; top: 0; z-index: 20;
  background: var(--surface);
  border-bottom: 1px solid var(--border);
  padding: 12px 16px 8px;
}
.topbar-row { display: flex; align-items: center; gap: 8px; }
.topbar h1 { font-size: 18px; margin: 0; flex: 1; }
.topbar-actions { display: flex; gap: 4px; }
.status-line { font-size: 12px; color: var(--muted); margin-top: 4px; }
.icon-btn {
  border: 1px solid var(--border);
  background: var(--field);
  border-radius: 8px;
  width: 36px; height: 36px;
  cursor: pointer; color: var(--text);
  font-size: 16px;
}
.icon-btn:hover { border-color: var(--primary); color: var(--primary); }
.hidden { display: none !important; }
.view { padding-bottom: 24px; }
.search-panel { padding: 12px 16px; border-bottom: 1px solid var(--border); }
.search-row { display: flex; gap: 8px; }
.search-row input, #detailSearchInput {
  flex: 1;
  border: none;
  background: var(--field);
  border-radius: var(--radius);
  padding: 12px 14px;
  font-size: 14px;
  outline: none;
}
.scopes-panel {
  margin-top: 8px;
  display: flex; flex-wrap: wrap; gap: 8px;
}
.chips { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 8px; }
.chip {
  border: 1px solid var(--border);
  background: var(--field);
  border-radius: 999px;
  padding: 6px 12px;
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;
  color: var(--muted);
}
.chip.active {
  border-color: var(--primary);
  background: color-mix(in srgb, var(--primary) 15%, white);
  color: var(--primary);
}
.chip.get.active { border-color: var(--get); color: var(--get); background: color-mix(in srgb, var(--get) 15%, white); }
.chip.post.active { border-color: var(--post); color: var(--post); background: color-mix(in srgb, var(--post) 15%, white); }
.chip.put.active { border-color: var(--put); color: var(--put); background: color-mix(in srgb, var(--put) 15%, white); }
.chip.patch.active { border-color: var(--patch); color: var(--patch); background: color-mix(in srgb, var(--patch) 15%, white); }
.chip.delete.active { border-color: var(--delete); color: var(--delete); background: color-mix(in srgb, var(--delete) 15%, white); }
.record-list { padding: 8px 16px; display: flex; flex-direction: column; gap: 8px; }
.card {
  border: 1px solid var(--border);
  background: var(--field);
  border-radius: var(--radius);
  padding: 12px;
  cursor: pointer;
  box-shadow: var(--shadow);
}
.card:hover { border-color: var(--primary); }
.card-row { display: flex; align-items: center; gap: 8px; }
.path { flex: 1; font-size: 12px; font-weight: 500; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.url-line { display: flex; gap: 8px; margin-top: 6px; }
.url-line .url { flex: 1; font-size: 10px; color: var(--muted); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.url-line .dur { font-size: 10px; color: var(--muted); }
.badge {
  font-size: 10px; font-weight: 700;
  padding: 2px 6px; border-radius: 4px;
}
.badge.method.get { color: var(--get); background: color-mix(in srgb, var(--get) 15%, white); }
.badge.method.post { color: var(--post); background: color-mix(in srgb, var(--post) 15%, white); }
.badge.method.put { color: var(--put); background: color-mix(in srgb, var(--put) 15%, white); }
.badge.method.patch { color: var(--patch); background: color-mix(in srgb, var(--patch) 15%, white); }
.badge.method.delete { color: var(--delete); background: color-mix(in srgb, var(--delete) 15%, white); }
.badge.status.ok { color: var(--ok); background: color-mix(in srgb, var(--ok) 15%, white); }
.badge.status.err { color: var(--err); background: color-mix(in srgb, var(--err) 15%, white); }
.badge.status.pending { color: var(--pending); background: color-mix(in srgb, var(--pending) 15%, white); }
.empty { text-align: center; padding: 64px 24px; color: var(--muted); }
.empty-icon { font-size: 48px; opacity: .5; margin-bottom: 12px; }
.muted { color: var(--muted); font-size: 12px; }
.tabs {
  display: flex; gap: 0;
  border-bottom: 1px solid var(--border);
  padding: 0 8px;
  overflow-x: auto;
}
.tab {
  border: none; background: transparent;
  padding: 12px 14px;
  font-weight: 600; font-size: 13px;
  color: var(--muted); cursor: pointer;
  border-bottom: 2px solid transparent;
}
.tab.active { color: var(--primary); border-bottom-color: var(--primary); }
.detail-body { padding: 16px; }
.detail-search { padding: 12px 16px; border-bottom: 1px solid var(--border); }
.detail-search-nav { display: flex; align-items: center; gap: 6px; margin-top: 8px; }
.block {
  background: var(--field);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 12px;
  margin-bottom: 12px;
}
.block-head {
  display: flex; align-items: center; justify-content: space-between;
  gap: 8px; margin-bottom: 8px;
}
.block-title { font-size: 14px; font-weight: 700; }
.block-actions { display: flex; gap: 6px; align-items: center; }
.mini-btn {
  border: 1px solid var(--border);
  background: var(--surface);
  border-radius: 6px;
  padding: 4px 8px;
  font-size: 11px; font-weight: 600;
  cursor: pointer; color: var(--muted);
}
.mini-btn.active { color: var(--primary); border-color: var(--primary); }
.kv { display: grid; grid-template-columns: 120px 1fr; gap: 8px; font-size: 13px; margin-bottom: 8px; }
.kv .label { color: var(--muted); }
.kv .value { word-break: break-word; font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 12px; }
.pre {
  margin: 0;
  white-space: pre-wrap;
  word-break: break-word;
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-size: 12px;
  line-height: 1.45;
}
table.json-table {
  width: 100%; border-collapse: collapse; font-size: 12px;
}
table.json-table th, table.json-table td {
  border: 1px solid var(--border);
  padding: 6px 8px;
  text-align: left;
  vertical-align: top;
  word-break: break-word;
}
table.json-table th { background: var(--surface); color: var(--muted); width: 30%; }
mark.hl {
  background: #fde68a;
  color: inherit;
  padding: 0 1px;
  border-radius: 2px;
}
mark.hl.active {
  background: #f59e0b;
  color: #111;
}
.copyable { cursor: pointer; }
.copyable:hover { color: var(--primary); }
.toast {
  position: fixed; left: 50%; bottom: 24px; transform: translateX(-50%);
  background: #111; color: #fff; padding: 10px 16px;
  border-radius: 8px; font-size: 13px; z-index: 50;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #0f0f10;
    --surface: #171718;
    --field: #222226;
    --border: #2e2e33;
    --text: #f2f2f4;
    --muted: #a0a0a8;
  }
}
''';

  static const appJs = r'''
(() => {
  const DEFAULT_SCOPES = new Set(['url', 'status']);
  const ALL_SCOPES = ['url', 'status', 'headers', 'query', 'requestBody', 'responseBody'];
  const SCOPE_LABELS = {
    url: 'URL', status: 'Status', headers: 'Headers', query: 'Query',
    requestBody: 'Request', responseBody: 'Response',
  };
  const METHODS = ['ALL', 'GET', 'POST', 'PUT', 'PATCH', 'DELETE'];
  const TAB_LABELS = ['Overview', 'Request', 'Response', 'Headers'];

  const state = {
    records: [],
    query: '',
    method: null,
    scopes: new Set(DEFAULT_SCOPES),
    showScopes: false,
    selectedId: null,
    record: null,
    tab: 0,
    detailQuery: '',
    detailSearchVisible: false,
    showDetailScopes: false,
    followCurrentTab: true,
    detailTabScopes: new Set([0, 1, 2, 3]),
    matchCursor: 0,
    matches: [],
  };

  const $ = (id) => document.getElementById(id);
  const toastEl = $('toast');

  function toast(msg) {
    toastEl.textContent = msg;
    toastEl.classList.remove('hidden');
    clearTimeout(toastEl._t);
    toastEl._t = setTimeout(() => toastEl.classList.add('hidden'), 1400);
  }

  async function copyText(text, msg) {
    try {
      await navigator.clipboard.writeText(text);
      toast(msg || 'Copied to clipboard');
    } catch {
      toast('Copy failed');
    }
  }

  function methodClass(m) {
    return (m || '').toLowerCase();
  }

  function statusBadge(record) {
    if (record.status === 'pending') return { text: '...', cls: 'pending' };
    if (record.status === 'cancelled') return { text: 'CANCELLED', cls: 'err' };
    const code = record.statusCode;
    if (code == null) return { text: 'ERR', cls: 'err' };
    if (code >= 200 && code < 300) return { text: String(code), cls: 'ok' };
    return { text: String(code), cls: 'err' };
  }

  function highlight(text, query, globalOffset, activeGlobal) {
    if (!query) return escapeHtml(text);
    const q = query.toLowerCase();
    const src = String(text);
    const lower = src.toLowerCase();
    let out = '';
    let i = 0;
    let local = 0;
    while (i < src.length) {
      const idx = lower.indexOf(q, i);
      if (idx < 0) {
        out += escapeHtml(src.slice(i));
        break;
      }
      out += escapeHtml(src.slice(i, idx));
      const globalIndex = globalOffset + local;
      const cls = globalIndex === activeGlobal ? 'hl active' : 'hl';
      const idAttr = globalIndex === activeGlobal ? ' id="active-match"' : '';
      out += `<mark class="${cls}"${idAttr}>${escapeHtml(src.slice(idx, idx + q.length))}</mark>`;
      i = idx + q.length;
      local += 1;
    }
    return out;
  }

  function escapeHtml(s) {
    return String(s)
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
  }

  function countMatches(text, query) {
    if (!query) return 0;
    const q = query.toLowerCase();
    const hay = String(text).toLowerCase();
    let count = 0, start = 0;
    while (true) {
      const i = hay.indexOf(q, start);
      if (i < 0) break;
      count += 1;
      start = i + q.length;
    }
    return count;
  }

  function collectMatches(record, query, tabIndexes) {
    const q = (query || '').trim();
    const matches = [];
    if (!q || !record) return matches;

    const blocks = [
      { tab: 0, id: 'overviewUrl', text: record.url || '' },
      { tab: 0, id: 'overviewMethod', text: record.method || '' },
      { tab: 0, id: 'overviewStatus', text: `${record.statusCode ?? ''} ${record.statusMessage ?? ''}`.trim() },
      { tab: 0, id: 'overviewError', text: record.errorMessage || '' },
      { tab: 0, id: 'overviewToken', text: record.authToken || '' },
      { tab: 1, id: 'requestQuery', text: record.queryParametersFormatted || '' },
      { tab: 1, id: 'requestBody', text: record.requestBodyFormatted || '' },
      { tab: 2, id: 'responseBody', text: record.responseBodyFormatted || '' },
      { tab: 3, id: 'requestHeaders', text: record.requestHeadersFormatted || '' },
      { tab: 3, id: 'responseHeaders', text: record.responseHeadersFormatted || '' },
    ];

    let global = 0;
    for (const block of blocks) {
      if (!tabIndexes.has(block.tab)) continue;
      const n = countMatches(block.text, q);
      for (let i = 0; i < n; i++) {
        matches.push({ tab: block.tab, blockId: block.id, localIndex: i, globalIndex: global });
        global += 1;
      }
    }
    return matches;
  }

  function matchOffset(blockId) {
    let offset = 0;
    for (const m of state.matches) {
      if (m.blockId === blockId) return offset;
      // count only first occurrence tracking: better compute from all matches before this block
    }
    // compute properly
    offset = 0;
    const seen = new Set();
    for (const m of state.matches) {
      if (m.blockId === blockId) return offset;
      if (!seen.has(m.blockId)) {
        // add all matches of previous blocks
      }
    }
    let count = 0;
    const blocksOrder = [];
    for (const m of state.matches) {
      if (!blocksOrder.includes(m.blockId)) blocksOrder.push(m.blockId);
    }
    for (const id of blocksOrder) {
      if (id === blockId) return count;
      count += state.matches.filter((m) => m.blockId === id).length;
    }
    return 0;
  }

  function renderScopes() {
    const panel = $('scopesPanel');
    panel.innerHTML = '';
    for (const scope of ALL_SCOPES) {
      const btn = document.createElement('button');
      btn.className = 'chip' + (state.scopes.has(scope) ? ' active' : '');
      btn.textContent = SCOPE_LABELS[scope];
      btn.onclick = () => {
        if (state.scopes.has(scope)) {
          if (state.scopes.size === 1) return;
          state.scopes.delete(scope);
        } else {
          state.scopes.add(scope);
        }
        renderScopes();
        loadRecords();
      };
      panel.appendChild(btn);
    }
    const all = document.createElement('button');
    all.className = 'chip' + (state.scopes.size === ALL_SCOPES.length ? ' active' : '');
    all.textContent = 'All fields';
    all.onclick = () => { state.scopes = new Set(ALL_SCOPES); renderScopes(); loadRecords(); };
    panel.appendChild(all);
    const reset = document.createElement('button');
    reset.className = 'chip';
    reset.textContent = 'Reset';
    reset.onclick = () => { state.scopes = new Set(DEFAULT_SCOPES); renderScopes(); loadRecords(); };
    panel.appendChild(reset);
  }

  function renderMethods() {
    const el = $('methodFilters');
    el.innerHTML = '';
    for (const m of METHODS) {
      const btn = document.createElement('button');
      const selected = m === 'ALL' ? state.method == null : state.method === m;
      btn.className = `chip ${m.toLowerCase()}${selected ? ' active' : ''}`;
      btn.textContent = m;
      btn.onclick = () => {
        state.method = m === 'ALL' ? null : m;
        renderMethods();
        loadRecords();
      };
      el.appendChild(btn);
    }
  }

  function renderList() {
    const list = $('recordList');
    const empty = $('emptyState');
    list.innerHTML = '';
    if (!state.records.length) {
      empty.classList.remove('hidden');
      return;
    }
    empty.classList.add('hidden');
    for (const record of state.records) {
      const card = document.createElement('div');
      card.className = 'card';
      const st = statusBadge(record);
      card.innerHTML = `
        <div class="card-row">
          <span class="badge method ${methodClass(record.method)}">${escapeHtml(record.method)}</span>
          <span class="path">${escapeHtml(record.path)}</span>
          <span class="badge status ${st.cls}">${escapeHtml(st.text)}</span>
        </div>
        <div class="url-line">
          <span class="url">${escapeHtml(record.url)}</span>
          <span class="dur">${escapeHtml(record.formattedDuration || '-')}</span>
        </div>`;
      card.onclick = () => openDetail(record.id);
      list.appendChild(card);
    }
  }

  function showList() {
    state.selectedId = null;
    state.record = null;
    $('listView').classList.remove('hidden');
    $('detailView').classList.add('hidden');
    $('backBtn').classList.add('hidden');
    $('detailSearchToggle').classList.add('hidden');
    $('clearBtn').classList.remove('hidden');
    $('pageTitle').textContent = 'Network Monitor';
  }

  async function openDetail(id, initialQuery) {
    state.selectedId = id;
    const res = await fetch(`/api/records/${encodeURIComponent(id)}`);
    if (!res.ok) {
      toast('Record not found');
      showList();
      return;
    }
    state.record = await res.json();
    state.tab = 0;
    state.detailQuery = initialQuery || state.query || '';
    state.detailSearchVisible = !!state.detailQuery;
    state.matchCursor = 0;
    $('listView').classList.add('hidden');
    $('detailView').classList.remove('hidden');
    $('backBtn').classList.remove('hidden');
    $('detailSearchToggle').classList.remove('hidden');
    $('clearBtn').classList.add('hidden');
    $('pageTitle').textContent = state.record.path || 'Details';
    $('detailSearchInput').value = state.detailQuery;
    $('detailSearchBar').classList.toggle('hidden', !state.detailSearchVisible);
    updateMatches();
    if (state.matches.length) state.tab = state.matches[0].tab;
    renderTabs();
    renderDetail();
    scrollActiveMatch();
  }

  function effectiveTabScopes() {
    return state.followCurrentTab ? new Set([state.tab]) : state.detailTabScopes;
  }

  function updateMatches() {
    state.matches = collectMatches(state.record, state.detailQuery, effectiveTabScopes());
    if (state.matchCursor >= state.matches.length) state.matchCursor = 0;
    const label = $('detailMatchLabel');
    if (!state.detailQuery.trim()) label.textContent = '';
    else if (!state.matches.length) label.textContent = 'No matches';
    else label.textContent = `${state.matchCursor + 1} - ${state.matches.length}`;
  }

  function renderTabs() {
    document.querySelectorAll('#detailTabs .tab').forEach((btn) => {
      const i = Number(btn.dataset.tab);
      btn.classList.toggle('active', i === state.tab);
      btn.onclick = () => {
        state.tab = i;
        if (state.followCurrentTab) state.matchCursor = 0;
        updateMatches();
        renderTabs();
        renderDetail();
      };
    });
  }

  function renderDetailScopes() {
    const panel = $('detailScopesPanel');
    panel.innerHTML = '';
    const current = document.createElement('button');
    current.className = 'chip' + (state.followCurrentTab ? ' active' : '');
    current.textContent = 'Current tab';
    current.onclick = () => {
      state.followCurrentTab = true;
      state.matchCursor = 0;
      renderDetailScopes();
      updateMatches();
      renderDetail();
    };
    panel.appendChild(current);

    const all = document.createElement('button');
    all.className = 'chip' + (!state.followCurrentTab && state.detailTabScopes.size === 4 ? ' active' : '');
    all.textContent = 'All tabs';
    all.onclick = () => {
      state.followCurrentTab = false;
      state.detailTabScopes = new Set([0, 1, 2, 3]);
      state.matchCursor = 0;
      renderDetailScopes();
      updateMatches();
      renderDetail();
    };
    panel.appendChild(all);

    TAB_LABELS.forEach((label, i) => {
      const btn = document.createElement('button');
      const selected = !state.followCurrentTab && state.detailTabScopes.has(i);
      btn.className = 'chip' + (selected ? ' active' : '');
      btn.textContent = label;
      btn.onclick = () => {
        state.followCurrentTab = false;
        const next = new Set(state.detailTabScopes);
        if (next.has(i)) {
          if (next.size === 1) return;
          next.delete(i);
        } else next.add(i);
        state.detailTabScopes = next;
        state.matchCursor = 0;
        renderDetailScopes();
        updateMatches();
        renderDetail();
      };
      panel.appendChild(btn);
    });
  }

  function infoBlock(title, items, opts = {}) {
    const q = opts.query || '';
    let html = `<div class="block"><div class="block-head"><div class="block-title">${escapeHtml(title)}</div></div>`;
    for (const item of items) {
      const offset = item.blockId ? matchOffset(item.blockId) : 0;
      const valueHtml = item.blockId && q
        ? highlight(item.value, q, offset, state.matches[state.matchCursor]?.globalIndex ?? -1)
        : escapeHtml(item.value);
      html += `<div class="kv"><div class="label">${escapeHtml(item.label)}</div>
        <div class="value ${item.copyable ? 'copyable' : ''}" data-copy="${item.copyable ? encodeURIComponent(item.value) : ''}">${valueHtml}</div></div>`;
    }
    html += '</div>';
    return html;
  }

  function codeBlock(title, content, blockId) {
    const q = state.detailQuery.trim();
    const canTable = !q && looksLikeJson(content);
    const viewId = `view-${blockId || title}`;
    const offset = blockId ? matchOffset(blockId) : 0;
    const active = state.matches[state.matchCursor]?.globalIndex ?? -1;
    const body = q
      ? `<pre class="pre">${highlight(content, q, offset, active)}</pre>`
      : `<pre class="pre" data-raw="${escapeHtml(content)}"></pre>`;

    return `<div class="block" data-code-block="${escapeHtml(viewId)}" data-content="${encodeURIComponent(content)}" data-can-table="${canTable ? '1' : '0'}">
      <div class="block-head">
        <div class="block-title">${escapeHtml(title)}</div>
        <div class="block-actions">
          ${canTable ? `<button class="mini-btn view-json active" data-mode="json">Raw JSON</button>
                        <button class="mini-btn view-table" data-mode="table">Table</button>` : ''}
          <button class="mini-btn copy-btn">Copy</button>
        </div>
      </div>
      <div class="code-body">${q ? body : `<pre class="pre">${escapeHtml(content)}</pre>`}</div>
    </div>`;
  }

  function looksLikeJson(text) {
    const t = (text || '').trim();
    if (!t) return false;
    try {
      const v = JSON.parse(t);
      return v && (typeof v === 'object');
    } catch { return false; }
  }

  function renderJsonTable(value) {
    if (Array.isArray(value)) {
      if (!value.length) return '<p class="muted">Empty list</p>';
      if (value.every((x) => x && typeof x === 'object' && !Array.isArray(x))) {
        const keys = [...new Set(value.flatMap((row) => Object.keys(row)))];
        let html = '<table class="json-table"><thead><tr>';
        for (const k of keys) html += `<th>${escapeHtml(k)}</th>`;
        html += '</tr></thead><tbody>';
        for (const row of value) {
          html += '<tr>';
          for (const k of keys) {
            const cell = row[k];
            html += `<td>${escapeHtml(cell == null ? '' : typeof cell === 'object' ? JSON.stringify(cell) : String(cell))}</td>`;
          }
          html += '</tr>';
        }
        html += '</tbody></table>';
        return html;
      }
      let html = '<table class="json-table"><thead><tr><th>#</th><th>Value</th></tr></thead><tbody>';
      value.forEach((v, i) => {
        html += `<tr><td>${i}</td><td>${escapeHtml(typeof v === 'object' ? JSON.stringify(v) : String(v))}</td></tr>`;
      });
      html += '</tbody></table>';
      return html;
    }
    if (value && typeof value === 'object') {
      let html = '<table class="json-table"><tbody>';
      for (const [k, v] of Object.entries(value)) {
        html += `<tr><th>${escapeHtml(k)}</th><td>${escapeHtml(typeof v === 'object' ? JSON.stringify(v, null, 2) : String(v))}</td></tr>`;
      }
      html += '</tbody></table>';
      return html;
    }
    return `<pre class="pre">${escapeHtml(String(value))}</pre>`;
  }

  function renderDetail() {
    const record = state.record;
    if (!record) return;
    const q = state.detailSearchVisible ? state.detailQuery.trim() : '';
    const body = $('detailBody');
    let html = '';

    if (state.tab === 0) {
      html += infoBlock('General', [
        { label: 'URL', value: record.url || '', copyable: true, blockId: 'overviewUrl' },
        { label: 'Method', value: record.method || '', blockId: 'overviewMethod' },
        { label: 'Status', value: `${record.statusCode ?? 'Pending'} ${record.statusMessage ?? ''}`.trim(), blockId: 'overviewStatus' },
        { label: 'Duration', value: record.formattedDuration || '-' },
        { label: 'Start Time', value: formatTime(record.startTime) },
        ...(record.endTime ? [{ label: 'End Time', value: formatTime(record.endTime) }] : []),
      ], { query: q });
      html += infoBlock('Size', [
        { label: 'Req headers', value: record.formattedRequestHeadersSize || '-' },
        { label: 'Req body', value: record.formattedRequestBodySize || '-' },
        { label: 'Req total', value: record.formattedRequestPayloadSize || '-' },
        { label: 'Res headers', value: record.formattedResponseHeadersSize || '-' },
        { label: 'Res body', value: record.formattedResponseBodySize || '-' },
        { label: 'Res total', value: record.formattedResponsePayloadSize || '-' },
      ]);
      if (record.errorMessage) {
        html += infoBlock('Error', [
          { label: 'Message', value: record.errorMessage, blockId: 'overviewError' },
        ], { query: q });
      }
      if (record.authToken) {
        html += infoBlock('Authentication', [
          { label: 'Token', value: record.authToken, copyable: true, blockId: 'overviewToken' },
        ], { query: q });
        if (record.jwt) {
          html += `<div class="block"><div class="block-head"><div class="block-title">JWT Decode</div></div>
            <div class="kv"><div class="label">Expires At</div><div class="value">${escapeHtml(formatTime(record.jwt.expiresAt))}</div></div>
            <div class="kv"><div class="label">Issued At</div><div class="value">${escapeHtml(formatTime(record.jwt.issuedAt))}</div></div>
            ${codeBlock('JWT Header', record.jwt.headerFormatted || '', 'jwtHeader')}
            ${codeBlock('JWT Payload', record.jwt.payloadFormatted || '', 'jwtPayload')}
          </div>`;
        } else if (record.jwtStatus === 'notJwt') {
          html += `<div class="block"><p class="muted">This auth token is not a JWT. Expected Bearer token with header.payload.signature format.</p></div>`;
        } else if (record.jwtStatus === 'decodeFailed') {
          html += `<div class="block"><p class="muted">This token looks like a JWT but the header or payload could not be decoded.</p></div>`;
        }
      }
    } else if (state.tab === 1) {
      if (record.queryParametersFormatted) {
        html += codeBlock('Query Parameters', record.queryParametersFormatted, 'requestQuery');
      }
      html += codeBlock('Request Body', record.requestBodyFormatted || 'No request body', record.requestBodyFormatted ? 'requestBody' : null);
    } else if (state.tab === 2) {
      html += codeBlock('Response Body', record.responseBodyFormatted || 'No response body', record.responseBodyFormatted ? 'responseBody' : null);
    } else {
      html += codeBlock('Request Headers', record.requestHeadersFormatted || '', 'requestHeaders');
      html += codeBlock('Response Headers', record.responseHeadersFormatted || 'No response headers', record.responseHeadersFormatted ? 'responseHeaders' : null);
    }

    body.innerHTML = html;

    body.querySelectorAll('.copyable').forEach((el) => {
      el.onclick = () => {
        const text = decodeURIComponent(el.getAttribute('data-copy') || '');
        if (text) copyText(text, 'Copied');
      };
    });

    body.querySelectorAll('[data-code-block]').forEach((block) => {
      const content = decodeURIComponent(block.getAttribute('data-content') || '');
      const bodyEl = block.querySelector('.code-body');
      block.querySelector('.copy-btn')?.addEventListener('click', () => copyText(content, `Copied ${block.querySelector('.block-title')?.textContent || ''}`));
      const jsonBtn = block.querySelector('.view-json');
      const tableBtn = block.querySelector('.view-table');
      if (jsonBtn && tableBtn && bodyEl) {
        jsonBtn.onclick = () => {
          jsonBtn.classList.add('active');
          tableBtn.classList.remove('active');
          bodyEl.innerHTML = `<pre class="pre">${escapeHtml(content)}</pre>`;
        };
        tableBtn.onclick = () => {
          tableBtn.classList.add('active');
          jsonBtn.classList.remove('active');
          try {
            bodyEl.innerHTML = renderJsonTable(JSON.parse(content));
          } catch {
            bodyEl.innerHTML = `<pre class="pre">${escapeHtml(content)}</pre>`;
          }
        };
      }
    });
  }

  function formatTime(iso) {
    if (!iso) return '-';
    try {
      const d = new Date(iso);
      return d.toLocaleString();
    } catch { return iso; }
  }

  function scrollActiveMatch() {
    const el = document.getElementById('active-match');
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }

  function goMatch(delta) {
    if (!state.matches.length) return;
    state.matchCursor = (state.matchCursor + delta + state.matches.length) % state.matches.length;
    const m = state.matches[state.matchCursor];
    if (m.tab !== state.tab) {
      state.tab = m.tab;
      renderTabs();
    }
    updateMatches();
    renderDetail();
    requestAnimationFrame(scrollActiveMatch);
  }

  async function loadRecords() {
    const params = new URLSearchParams();
    if (state.query) params.set('q', state.query);
    if (state.method) params.set('method', state.method);
    params.set('scopes', [...state.scopes].join(','));
    const res = await fetch(`/api/records?${params}`);
    const data = await res.json();
    state.records = data.records || [];
    renderList();
    $('statusLine').textContent = `${data.filtered ?? state.records.length} shown · ${data.total ?? state.records.length} total`;
  }

  function connectSse() {
    const es = new EventSource('/api/events');
    es.onmessage = () => {
      loadRecords();
      if (state.selectedId) {
        fetch(`/api/records/${encodeURIComponent(state.selectedId)}`)
          .then((r) => r.ok ? r.json() : null)
          .then((rec) => {
            if (!rec) return;
            state.record = rec;
            updateMatches();
            renderDetail();
          });
      }
    };
    es.onerror = () => {
      $('statusLine').textContent = 'Reconnecting…';
    };
  }

  // Wire UI
  $('searchInput').addEventListener('input', (e) => {
    state.query = e.target.value;
    loadRecords();
  });
  $('scopesToggle').onclick = () => {
    state.showScopes = !state.showScopes;
    $('scopesPanel').classList.toggle('hidden', !state.showScopes);
  };
  $('backBtn').onclick = showList;
  $('clearBtn').onclick = async () => {
    if (!confirm('Clear all records?')) return;
    await fetch('/api/records', { method: 'DELETE' });
    loadRecords();
  };
  $('detailSearchToggle').onclick = () => {
    state.detailSearchVisible = !state.detailSearchVisible;
    $('detailSearchBar').classList.toggle('hidden', !state.detailSearchVisible);
    if (!state.detailSearchVisible) {
      state.detailQuery = '';
      $('detailSearchInput').value = '';
      state.matchCursor = 0;
      updateMatches();
      renderDetail();
    } else {
      $('detailSearchInput').focus();
    }
  };
  $('closeDetailSearch').onclick = () => {
    state.detailSearchVisible = false;
    state.detailQuery = '';
    $('detailSearchInput').value = '';
    $('detailSearchBar').classList.add('hidden');
    state.matchCursor = 0;
    updateMatches();
    renderDetail();
  };
  $('detailSearchInput').addEventListener('input', (e) => {
    state.detailQuery = e.target.value;
    state.matchCursor = 0;
    updateMatches();
    renderDetail();
    scrollActiveMatch();
  });
  $('prevMatch').onclick = () => goMatch(-1);
  $('nextMatch').onclick = () => goMatch(1);
  $('detailScopesToggle').onclick = () => {
    state.showDetailScopes = !state.showDetailScopes;
    $('detailScopesPanel').classList.toggle('hidden', !state.showDetailScopes);
  };

  renderScopes();
  renderMethods();
  renderDetailScopes();
  showList();
  loadRecords();
  connectSse();
})();
''';
}
