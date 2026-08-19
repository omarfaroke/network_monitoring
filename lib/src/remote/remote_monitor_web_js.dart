part of 'remote_monitor_web.dart';

const _kAppJs = r'''
(() => {
  const DEFAULT_SCOPES = new Set(['url', 'status']);
  const ALL_SCOPES = ['url', 'status', 'headers', 'query', 'requestBody', 'responseBody'];
  const SCOPE_LABELS = {
    url: 'URL', status: 'Status', headers: 'Headers', query: 'Query',
    requestBody: 'Request', responseBody: 'Response',
  };
  const METHODS = ['ALL', 'GET', 'POST', 'PUT', 'PATCH', 'DELETE'];
  const TAB_LABELS = ['Overview', 'Request', 'Response', 'Headers'];
  const ICONS = {
    search: 'M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 12.59 2.5 9.5 2.5S3 5.91 3 9.5 6.41 16.5 10 16.5c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z',
    tune: 'M3 17v2h6v-2H3zM3 5v2h10V5H3zm10 16v-2h8v-2h-8v-2h-2v6h2zM7 9v2H3v2h4v2h2V9H7zm14 4v-2H11v2h10zm-6-4h2V7h4V5h-4V3h-2v6z',
    delete_outline: 'M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM8 9h8v10H8V9zm7.5-5l-1-1h-5l-1 1H5v2h14V4z',
    pause: 'M6 19h4V5H6v14zm8-14v14h4V5h-4z',
    play_arrow: 'M8 5v14l11-7z',
    more_vert: 'M12 8c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z',
    add_circle_outline: 'M13 7h-2v4H7v2h4v4h2v-4h4v-2h-4V7zm-1-5C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z',
    rule: 'M16.54 11L13 7.46l1.41-1.41 2.12 2.12 4.24-4.24 1.41 1.41L16.54 11zM11 7H2v2h9V7zm10 6.41L19.59 12 17 14.59 14.41 12 13 13.41 15.59 16 13 18.59 14.41 20 17 17.41 19.59 20 21 18.59 18.41 16 21 13.41zM11 15H2v2h9v-2z',
    pause_circle: 'M9 16h2V8H9v8zm3-14C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm1-4h2V8h-2v8z',
    pause_circle_filled: 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z',
    edit: 'M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z',
    stop: 'M6 6h12v12H6z',
    copy: 'M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z',
    code: 'M9.4 16.6L4.8 12l4.6-4.6L8 6l-6 6 6 6 1.4-1.4zm5.2 0l4.6-4.6-4.6-4.6L16 6l6 6-6 6-1.4-1.4z',
    table_rows: 'M21 8H3V4h18v4zm0 2H3v4h18v-4zm0 6H3v4h18v-4z',
    close: 'M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z',
    arrow_back: 'M17.77 3.77L16 2 6 12l10 10 1.77-1.77L9.54 12z',
    keyboard_arrow_up: 'M7.41 15.41L12 10.83l4.59 4.58L18 14l-6-6-6 6z',
    keyboard_arrow_down: 'M7.41 8.59L12 13.17l4.59-4.58L18 10l-6 6-6-6z',
    http: 'M24 9v6h-2V9h2zM4.5 15h-2V9h2v6zm5.7 0H7.7L6 9h2.1l.9 4.2L10 9h2.1l-1.9 6zm4.7-1.8V15h-2V9h3.3c.8 0 1.5.2 1.9.6.4.4.6.9.6 1.5 0 .5-.1.9-.4 1.2-.2.3-.6.5-1 .6l1.3 2.1h-2.2l-1.1-1.8h-.4zm.8-1.3c.2 0 .4-.1.5-.2.1-.1.2-.3.2-.5s-.1-.4-.2-.5c-.1-.1-.3-.2-.5-.2h-1v1.4h1z',
    open_in_new: 'M19 19H5V5h7V3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2v-7h-2v7zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3h-7z',
    skip_next: 'M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z',
    send: 'M2.01 21L23 12 2.01 3 2 10l15 2-15 2z',
    cancel: 'M12 2C6.47 2 2 6.47 2 12s4.47 10 10 10 10-4.47 10-10S17.53 2 12 2zm5 13.59L15.59 17 12 13.41 8.41 17 7 15.59 10.59 12 7 8.41 8.41 7 12 10.59 15.59 7 17 8.41 13.41 12 17 15.59z',
  };

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
    pausedGlobally: false,
    activeBreakpointCount: 0,
    hasEnabledAllEndpointsBreakpoint: false,
    breakpoints: [],
    total: 0,
    filtered: 0,
  };

  const $ = (id) => document.getElementById(id);
  const toastEl = $('toast');

  function svgIcon(name) {
    const d = ICONS[name];
    if (!d) return '';
    return `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="${d}"></path></svg>`;
  }

  function setIcon(el, name) {
    if (!el) return;
    const badge = el.querySelector('.count-badge');
    el.innerHTML = svgIcon(name);
    if (badge) el.appendChild(badge);
  }

  function toast(msg) {
    toastEl.textContent = msg;
    toastEl.classList.remove('hidden');
    clearTimeout(toastEl._t);
    toastEl._t = setTimeout(() => toastEl.classList.add('hidden'), 1400);
  }

  function copyWithExecCommand(text) {
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.setAttribute('readonly', '');
    textarea.style.position = 'fixed';
    textarea.style.top = '0';
    textarea.style.left = '0';
    textarea.style.width = '1px';
    textarea.style.height = '1px';
    textarea.style.padding = '0';
    textarea.style.border = 'none';
    textarea.style.opacity = '0';
    document.body.appendChild(textarea);
    textarea.focus();
    textarea.select();
    textarea.setSelectionRange(0, textarea.value.length);
    let ok = false;
    try {
      ok = document.execCommand('copy');
    } catch (_) {
      ok = false;
    }
    document.body.removeChild(textarea);
    return ok;
  }

  async function copyText(text, msg) {
    const value = text == null ? '' : String(text);
    try {
      // Clipboard API is only available in secure contexts (HTTPS / localhost).
      // The remote monitor is typically opened via http://<lan-ip>, so fall back.
      if (window.isSecureContext && navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(value);
      } else if (!copyWithExecCommand(value)) {
        throw new Error('copy');
      }
      toast(msg || 'Copied to clipboard');
    } catch {
      if (copyWithExecCommand(value)) {
        toast(msg || 'Copied to clipboard');
      } else {
        toast('Copy failed');
      }
    }
  }

  async function api(path, opts = {}) {
    const init = { method: opts.method || 'GET', headers: {} };
    if (opts.body !== undefined) {
      init.headers['Content-Type'] = 'application/json';
      init.body = JSON.stringify(opts.body);
    }
    const res = await fetch(path, init);
    const text = await res.text();
    const data = text ? JSON.parse(text) : {};
    if (!res.ok) throw new Error(data.error || 'Request failed');
    return data;
  }

  function methodClass(m) {
    return (m || '').toLowerCase();
  }

  function statusBadge(record) {
    if (record.status === 'pending') return { text: '...', cls: 'pending' };
    if (record.status === 'cancelled') return { text: 'CANCELLED', cls: 'cancelled' };
    const code = record.statusCode;
    if (code == null) return { text: 'ERR', cls: 'err' };
    if (code >= 200 && code < 300) return { text: String(code), cls: 'ok' };
    return { text: String(code), cls: 'err' };
  }

  function isMobile() {
    return window.matchMedia('(max-width: 800px)').matches;
  }

  function escapeHtml(s) {
    return String(s)
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
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
    const first = state.matches.find((m) => m.blockId === blockId);
    return first ? first.globalIndex : 0;
  }

  function applyMonitorState(data) {
    if (!data) return;
    state.pausedGlobally = !!data.pausedGlobally;
    state.activeBreakpointCount = data.activeBreakpointCount || 0;
    state.hasEnabledAllEndpointsBreakpoint = !!data.hasEnabledAllEndpointsBreakpoint;
    state.breakpoints = data.breakpoints || state.breakpoints;
    if (typeof data.total === 'number') state.total = data.total;
    if (typeof data.filtered === 'number') state.filtered = data.filtered;
    renderChrome();
  }

  function renderChrome() {
    const pauseBtn = $('pauseBtn');
    pauseBtn.title = state.pausedGlobally ? 'Resume all requests' : 'Pause all requests';
    pauseBtn.setAttribute('aria-label', pauseBtn.title);
    pauseBtn.classList.toggle('paused', state.pausedGlobally);
    setIcon(pauseBtn, state.pausedGlobally ? 'play_arrow' : 'pause');

    const badge = $('pausedBadge');
    if (state.activeBreakpointCount > 0) {
      badge.textContent = `${state.activeBreakpointCount} paused`;
      badge.classList.remove('hidden');
    } else {
      badge.classList.add('hidden');
    }

    const count = $('bpCount');
    if (state.breakpoints.length) {
      count.textContent = String(state.breakpoints.length);
      count.classList.remove('hidden');
    } else {
      count.classList.add('hidden');
    }
    $('bpsBtn').classList.toggle('active', state.breakpoints.length > 0);

    const scopesActive = state.scopes.size !== DEFAULT_SCOPES.size ||
      ![...DEFAULT_SCOPES].every((s) => state.scopes.has(s));
    $('scopesToggle').classList.toggle('active', state.showScopes || scopesActive);

    renderHints();
    applyLayout();
    $('statusLine').textContent = `${state.filtered} shown · ${state.total} total`;
  }

  function renderHints() {
    const host = $('hintBars');
    let html = '';
    if (state.pausedGlobally) {
      html += `<div class="hint-bar pause">${svgIcon('pause')}<span class="hint-text">All requests are paused. Tap resume to continue sending traffic.</span><button class="link" data-hint="resume">Resume all requests</button></div>`;
    } else if (state.hasEnabledAllEndpointsBreakpoint) {
      html += `<div class="hint-bar all-ep">${svgIcon('rule')}<span class="hint-text">Breakpoint active for all endpoints. Matching requests will pause.</span></div>`;
    }
    if (state.activeBreakpointCount > 0) {
      html += `<div class="hint-bar active-bp">${svgIcon('pause_circle_filled')}<span class="hint-text">${state.activeBreakpointCount} request(s) paused</span><button class="link" data-hint="continue-all">Continue All</button></div>`;
    }
    host.innerHTML = html;
    host.querySelectorAll('[data-hint]').forEach((btn) => {
      btn.onclick = async () => {
        const action = btn.getAttribute('data-hint');
        if (action === 'resume') await api('/api/pause', { method: 'POST', body: { paused: false } });
        if (action === 'continue-all') await api('/api/active-breakpoints/continue-all', { method: 'POST', body: {} });
        loadRecords();
      };
    });
  }

  function applyLayout() {
    const hasSelection = !!state.selectedId;
    $('detailPane').classList.toggle('open', hasSelection);
    $('backBtn').classList.toggle('hidden', !isMobile() || !hasSelection);
    $('app').classList.toggle('detail-open', isMobile() && hasSelection);
    $('detailEmpty').classList.toggle('hidden', hasSelection);
    $('detailView').classList.toggle('hidden', !hasSelection);
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
      list.appendChild(renderCard(record));
    }
  }

  function renderCard(record) {
    const card = document.createElement('div');
    const selected = record.id === state.selectedId;
    card.className = 'card' + (selected ? ' selected' : '') + (record.isPaused ? ' paused' : '');
    const st = statusBadge(record);
    const actions = record.isPaused
      ? `<button class="action-btn edit" data-stop="edit" title="Edit">${svgIcon('edit')}</button>
         <button class="action-btn play" data-stop="continue" title="Continue">${svgIcon('play_arrow')}</button>
         <button class="action-btn stop" data-stop="cancel" title="Cancel">${svgIcon('stop')}</button>`
      : `<button class="action-btn bp ${record.hasBreakpoint ? 'active' : ''}" data-stop="toggle-bp" title="${record.hasBreakpoint ? 'Remove breakpoint' : 'Add breakpoint'}">${svgIcon(record.hasBreakpoint ? 'pause_circle_filled' : 'pause_circle')}</button>
         <span class="badge status ${st.cls}">${escapeHtml(st.text)}</span>`;
    card.innerHTML = `
      <div class="card-row">
        <span class="badge method ${methodClass(record.method)}">${escapeHtml(record.method)}</span>
        <span class="path">${escapeHtml(record.path)}</span>
        <span class="card-actions">${actions}</span>
      </div>
      <div class="url-line">
        <span class="url">${escapeHtml(record.url)}</span>
        <span class="dur">${escapeHtml(record.formattedDuration || '-')}</span>
      </div>`;
    card.onclick = () => openDetail(record.id);
    card.oncontextmenu = (e) => {
      e.preventDefault();
      showRecordMenu(e.clientX, e.clientY, record);
    };
    let pressTimer = 0;
    card.addEventListener('touchstart', (e) => {
      const t = e.changedTouches[0];
      pressTimer = setTimeout(() => showRecordMenu(t.clientX, t.clientY, record), 500);
    }, { passive: true });
    card.addEventListener('touchend', () => clearTimeout(pressTimer));
    card.addEventListener('touchmove', () => clearTimeout(pressTimer));
    card.querySelectorAll('[data-stop]').forEach((el) => {
      el.onclick = (e) => {
        e.stopPropagation();
        handleCardAction(el.getAttribute('data-stop'), record);
      };
    });
    return card;
  }

  async function handleCardAction(action, record) {
    try {
      if (action === 'toggle-bp') {
        await api('/api/breakpoints/toggle-endpoint', { method: 'POST', body: { path: record.path } });
        toast(record.hasBreakpoint ? `Breakpoint removed for ${record.path}` : `Breakpoint added for ${record.path}`);
        loadRecords();
        return;
      }
      const bpId = record.pausedBreakpointId;
      if (action === 'continue' && bpId) {
        await api(`/api/active-breakpoints/${encodeURIComponent(bpId)}/continue`, { method: 'POST', body: {} });
        loadRecords();
        return;
      }
      if (action === 'cancel' && bpId) {
        await api(`/api/active-breakpoints/${encodeURIComponent(bpId)}/cancel`, { method: 'POST', body: {} });
        loadRecords();
        return;
      }
      if (action === 'edit' && bpId) {
        await openEditModal(record.id, bpId);
      }
    } catch (err) {
      toast(err.message || 'Action failed');
    }
  }

  function hideMenu() {
    $('ctxMenu').classList.add('hidden');
    $('ctxMenu').innerHTML = '';
  }

  function showMenu(x, y, items) {
    const menu = $('ctxMenu');
    menu.innerHTML = items.map((item, i) =>
      `<button class="menu-item ${item.cls || ''}" data-i="${i}">${svgIcon(item.icon)}<span>${escapeHtml(item.label)}</span></button>`
    ).join('');
    menu.classList.remove('hidden');
    const rect = menu.getBoundingClientRect();
    const left = Math.min(x, window.innerWidth - rect.width - 8);
    const top = Math.min(y, window.innerHeight - rect.height - 8);
    menu.style.left = `${Math.max(8, left)}px`;
    menu.style.top = `${Math.max(8, top)}px`;
    menu.querySelectorAll('[data-i]').forEach((btn) => {
      btn.onclick = () => {
        const item = items[Number(btn.getAttribute('data-i'))];
        hideMenu();
        item.onSelect();
      };
    });
  }

  function showRecordMenu(x, y, record) {
    showMenu(x, y, [
      { icon: 'open_in_new', label: 'View Details', onSelect: () => openDetail(record.id) },
      {
        icon: record.hasBreakpoint ? 'pause_circle_filled' : 'pause_circle',
        label: record.hasBreakpoint ? 'Remove Breakpoint (this endpoint)' : 'Add Breakpoint (this endpoint)',
        cls: record.hasBreakpoint ? 'orange' : '',
        onSelect: () => handleCardAction('toggle-bp', record),
      },
      { icon: 'tune', label: 'Add Breakpoint (custom)...', onSelect: () => openAddBreakpoint(record.path) },
      { icon: 'copy', label: 'Copy URL', onSelect: () => copyText(record.url, 'URL copied') },
    ]);
  }

  function clearSelection() {
    state.selectedId = null;
    state.record = null;
    applyLayout();
    renderList();
  }

  async function openDetail(id, initialQuery) {
    state.selectedId = id;
    try {
      state.record = await api(`/api/records/${encodeURIComponent(id)}`);
    } catch {
      toast('Record not found');
      clearSelection();
      return;
    }
    state.tab = 0;
    state.detailQuery = initialQuery || state.query || '';
    state.detailSearchVisible = !!state.detailQuery;
    state.matchCursor = 0;
    $('detailTitle').textContent = `${state.record.method || ''} ${state.record.path || ''}`.trim() || 'Details';
    $('detailSearchInput').value = state.detailQuery;
    $('detailSearchBar').classList.toggle('hidden', !state.detailSearchVisible);
    $('detailSearchToggle').classList.toggle('active', state.detailSearchVisible);
    applyLayout();
    renderList();
    updateMatches();
    if (state.matches.length) state.tab = state.matches[0].tab;
    renderTabs();
    renderDetail();
    scrollActiveMatch();
  }

  async function refreshDetail() {
    if (!state.selectedId) return;
    try {
      state.record = await api(`/api/records/${encodeURIComponent(state.selectedId)}`);
      $('detailTitle').textContent = `${state.record.method || ''} ${state.record.path || ''}`.trim() || 'Details';
      updateMatches();
      renderDetail();
    } catch {
      clearSelection();
    }
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
      const copy = item.copyable
        ? `<button class="copy-inline" data-copy="${encodeURIComponent(item.value)}" title="Copy">${svgIcon('copy')}</button>`
        : '';
      html += `<div class="kv"><div class="label">${escapeHtml(item.label)}</div>
        <div class="value">${valueHtml}</div>${copy}</div>`;
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
      : `<pre class="pre">${escapeHtml(content)}</pre>`;
    return `<div class="block" data-code-block="${escapeHtml(viewId)}" data-content="${encodeURIComponent(content)}" data-can-table="${canTable ? '1' : '0'}">
      <div class="block-head">
        <div class="block-title">${escapeHtml(title)}</div>
        <div class="block-actions">
          ${canTable ? `<button class="icon-btn tiny view-table" title="Table">${svgIcon('table_rows')}</button>` : ''}
          <button class="icon-btn tiny copy-btn" title="Copy">${svgIcon('copy')}</button>
        </div>
      </div>
      <div class="code-body">${body}</div>
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
    body.querySelectorAll('[data-copy]').forEach((el) => {
      el.onclick = () => {
        const text = decodeURIComponent(el.getAttribute('data-copy') || '');
        if (text) copyText(text, 'Copied');
      };
    });
    body.querySelectorAll('[data-code-block]').forEach((block) => {
      const content = decodeURIComponent(block.getAttribute('data-content') || '');
      const bodyEl = block.querySelector('.code-body');
      const tableBtn = block.querySelector('.view-table');
      let tableView = false;
      block.querySelector('.copy-btn')?.addEventListener('click', () => copyText(content, `Copied ${block.querySelector('.block-title')?.textContent || ''}`));
      if (tableBtn && bodyEl) {
        tableBtn.onclick = () => {
          tableView = !tableView;
          tableBtn.classList.toggle('active', tableView);
          tableBtn.title = tableView ? 'Raw JSON' : 'Table';
          tableBtn.innerHTML = svgIcon(tableView ? 'code' : 'table_rows');
          if (tableView) {
            try { bodyEl.innerHTML = renderJsonTable(JSON.parse(content)); }
            catch { bodyEl.innerHTML = `<pre class="pre">${escapeHtml(content)}</pre>`; }
          } else {
            bodyEl.innerHTML = `<pre class="pre">${escapeHtml(content)}</pre>`;
          }
        };
      }
    });
  }

  function formatTime(iso) {
    if (!iso) return '-';
    try { return new Date(iso).toLocaleString(); }
    catch { return iso; }
  }

  function prettyJson(value) {
    if (value == null) return '';
    try {
      if (typeof value === 'string') {
        const trimmed = value.trim();
        if (!trimmed) return '';
        try { return JSON.stringify(JSON.parse(trimmed), null, 2); }
        catch { return value; }
      }
      return JSON.stringify(value, null, 2);
    } catch {
      return String(value);
    }
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
    try {
      const params = new URLSearchParams();
      if (state.query) params.set('q', state.query);
      if (state.method) params.set('method', state.method);
      params.set('scopes', [...state.scopes].join(','));
      const data = await api(`/api/records?${params}`);
      state.records = data.records || [];
      applyMonitorState(data);
      renderList();
      if (state.selectedId) await refreshDetail();
    } catch (_) {
      $('statusLine').textContent = 'Reconnecting…';
    }
  }

  function connectSse() {
    const es = new EventSource('/api/events');
    es.onmessage = () => { loadRecords(); };
    es.onerror = () => { $('statusLine').textContent = 'Reconnecting…'; };
  }

  function closeModal() {
    const overlay = $('modalOverlay');
    overlay.classList.add('hidden');
    overlay.innerHTML = '';
    overlay.onclick = null;
  }

  function openModal(innerHtml, { dismissible = true, wide = false } = {}) {
    const overlay = $('modalOverlay');
    overlay.innerHTML = `<div class="modal ${wide ? 'wide' : ''}" role="dialog">${innerHtml}</div>`;
    overlay.classList.remove('hidden');
    overlay.onclick = (e) => {
      if (dismissible && e.target === overlay) closeModal();
    };
    return overlay.querySelector('.modal');
  }

  function openAddBreakpoint(initialPath) {
    const specific = !!(initialPath && initialPath.length);
    const modal = openModal(`
      <div class="modal-head"><h3>Add Breakpoint</h3><button class="icon-btn" data-close title="Close">${svgIcon('close')}</button></div>
      <div class="modal-body">
        <label class="group-title">Target</label>
        <label class="radio-row"><input type="radio" name="bp-target" value="allEndpoints" ${specific ? '' : 'checked'}> All Endpoints</label>
        <label class="radio-row"><input type="radio" name="bp-target" value="specificEndpoint" ${specific ? 'checked' : ''}> Specific Endpoint</label>
        <div id="bpPatternWrap" class="${specific ? '' : 'hidden'}">
          <input id="bpPattern" type="text" placeholder="e.g. /api/login or /users" value="${escapeHtml(initialPath || '')}" />
        </div>
        <label class="group-title">Break On</label>
        <label class="radio-row"><input type="radio" name="bp-type" value="all" checked> Both Request &amp; Response</label>
        <label class="radio-row"><input type="radio" name="bp-type" value="request"> Request Only</label>
        <label class="radio-row"><input type="radio" name="bp-type" value="response"> Response Only</label>
      </div>
      <div class="modal-actions">
        <button class="text-btn" data-close>Cancel</button>
        <button class="text-btn primary" id="bpAddConfirm">Add</button>
      </div>
    `);
    const wrap = modal.querySelector('#bpPatternWrap');
    modal.querySelectorAll('[name="bp-target"]').forEach((el) => {
      el.onchange = () => wrap.classList.toggle('hidden', el.value !== 'specificEndpoint' || !el.checked);
    });
    modal.querySelectorAll('[data-close]').forEach((el) => { el.onclick = closeModal; });
    modal.querySelector('#bpAddConfirm').onclick = async () => {
      const target = modal.querySelector('[name="bp-target"]:checked').value;
      const type = modal.querySelector('[name="bp-type"]:checked').value;
      const endpointPattern = modal.querySelector('#bpPattern').value;
      await api('/api/breakpoints', { method: 'POST', body: { target, type, endpointPattern } });
      closeModal();
      loadRecords();
    };
  }

  function openAppliedBreakpoints() {
    const items = state.breakpoints.length
      ? state.breakpoints.map((bp) => `
          <div class="bp-item" data-index="${bp.index}">
            <div class="bp-meta">
              <div class="bp-title">${escapeHtml(bp.target === 'allEndpoints' ? 'All Endpoints' : (bp.endpointPattern || 'Unknown'))}</div>
              <div class="muted">${escapeHtml(bp.typeLabel || bp.type)}</div>
            </div>
            <label class="switch"><input type="checkbox" ${bp.isEnabled ? 'checked' : ''}><span class="slider"></span></label>
            <button class="icon-btn tiny danger" data-del title="Delete">${svgIcon('delete_outline')}</button>
          </div>`).join('')
      : '<p class="muted" style="text-align:center;padding:24px 0">No breakpoints configured</p>';
    const modal = openModal(`
      <div class="modal-head">${svgIcon('rule')}<h3>Applied Breakpoints</h3><button class="icon-btn" data-close title="Close">${svgIcon('close')}</button></div>
      <div class="modal-body">${items}</div>
    `);
    modal.querySelectorAll('[data-close]').forEach((el) => { el.onclick = closeModal; });
    modal.querySelectorAll('.bp-item').forEach((row) => {
      const index = Number(row.getAttribute('data-index'));
      row.querySelector('input[type="checkbox"]').onchange = async (e) => {
        await api(`/api/breakpoints/${index}`, { method: 'PATCH', body: { isEnabled: e.target.checked } });
        loadRecords();
      };
      row.querySelector('[data-del]').onclick = async () => {
        await api(`/api/breakpoints/${index}`, { method: 'DELETE' });
        await loadRecords();
        openAppliedBreakpoints();
      };
    });
  }

  function openClearDialog() {
    const modal = openModal(`
      <div class="modal-head"><h3>Clear all records?</h3></div>
      <div class="modal-body"><p class="muted">This will remove all captured HTTP requests from the list.</p></div>
      <div class="modal-actions">
        <button class="text-btn" data-close>Cancel</button>
        <button class="text-btn danger" id="clearConfirm">Clear</button>
      </div>
    `);
    modal.querySelector('[data-close]').onclick = closeModal;
    modal.querySelector('#clearConfirm').onclick = async () => {
      await api('/api/records', { method: 'DELETE' });
      clearSelection();
      closeModal();
      loadRecords();
    };
  }

  async function openEditModal(recordId, breakpointId) {
    let record;
    try {
      record = await api(`/api/records/${encodeURIComponent(recordId)}`);
    } catch {
      toast('Record not found');
      return;
    }
    const isResponse = String(breakpointId).startsWith('res_');
    const originalHeaders = prettyJson(isResponse ? record.responseHeaders : record.requestHeaders) || '{}';
    const originalBody = prettyJson(isResponse ? record.responseBody : record.requestBody);
    const modal = openModal(`
      <div class="modal-head">
        <h3>${isResponse ? 'Edit Response' : 'Edit Request'}</h3>
        <button class="text-btn danger" id="editCancel">${svgIcon('cancel')} Cancel</button>
        <button class="text-btn ok" id="editContinue">${svgIcon('play_arrow')} Continue</button>
        <button class="icon-btn" data-close title="Close">${svgIcon('close')}</button>
      </div>
      <div class="edit-banner">
        <div class="title">${svgIcon('pause_circle_filled')} ${isResponse ? 'Response paused' : 'Request paused'}</div>
        <div>${escapeHtml(record.method || '')} ${escapeHtml(record.path || '')}</div>
        <div class="muted">${escapeHtml(record.url || '')}</div>
      </div>
      <div class="edit-tabs">
        <button class="tab active" data-edit-tab="headers">Headers</button>
        <button class="tab" data-edit-tab="body">Body</button>
      </div>
      <div class="modal-body">
        <textarea id="editHeaders">${escapeHtml(originalHeaders)}</textarea>
        <textarea id="editBody" class="hidden">${escapeHtml(originalBody)}</textarea>
      </div>
      <div class="edit-actions">
        <button class="btn ghost" id="editSkip">${svgIcon('skip_next')} Skip (no edit)</button>
        <button class="btn solid" id="editApply">${svgIcon('send')} Apply &amp; Continue</button>
      </div>
    `, { dismissible: false, wide: true });

    const headersEl = modal.querySelector('#editHeaders');
    const bodyEl = modal.querySelector('#editBody');
    modal.querySelectorAll('[data-edit-tab]').forEach((btn) => {
      btn.onclick = () => {
        const tab = btn.getAttribute('data-edit-tab');
        modal.querySelectorAll('[data-edit-tab]').forEach((b) => b.classList.toggle('active', b === btn));
        headersEl.classList.toggle('hidden', tab !== 'headers');
        bodyEl.classList.toggle('hidden', tab !== 'body');
      };
    });
    modal.querySelector('[data-close]').onclick = closeModal;

    async function continueWith(payload) {
      await api(`/api/active-breakpoints/${encodeURIComponent(breakpointId)}/continue`, {
        method: 'POST',
        body: payload,
      });
      closeModal();
      loadRecords();
    }
    modal.querySelector('#editSkip').onclick = () => continueWith({});
    modal.querySelector('#editContinue').onclick = () => continueWith({});
    modal.querySelector('#editCancel').onclick = async () => {
      await api(`/api/active-breakpoints/${encodeURIComponent(breakpointId)}/cancel`, { method: 'POST', body: {} });
      closeModal();
      loadRecords();
    };
    modal.querySelector('#editApply').onclick = async () => {
      const payload = {};
      const headersText = headersEl.value.trim();
      if (headersText && headersText !== originalHeaders.trim()) {
        try {
          payload.editedHeaders = JSON.parse(headersText);
        } catch {
          toast('Invalid JSON in headers');
          return;
        }
      }
      const bodyText = bodyEl.value.trim();
      if (bodyText && bodyText !== originalBody.trim()) payload.editedBody = bodyText;
      await continueWith(payload);
    };
  }

  function showDetailMore(btn) {
    const record = state.record;
    if (!record) return;
    const rect = btn.getBoundingClientRect();
    const items = [
      { icon: 'copy', label: 'Copy URL', onSelect: () => copyText(record.url, 'Copied to clipboard') },
      { icon: 'copy', label: 'Copy Request Headers', onSelect: () => copyText(record.requestHeadersFormatted || '', 'Copied to clipboard') },
      { icon: 'copy', label: 'Copy Request Body', onSelect: () => copyText(record.requestBodyFormatted || '', 'Copied to clipboard') },
      { icon: 'copy', label: 'Copy Response Body', onSelect: () => copyText(record.responseBodyFormatted || '', 'Copied to clipboard') },
    ];
    if (record.authToken) {
      items.push({ icon: 'copy', label: 'Copy Token', onSelect: () => copyText(record.authToken, 'Copied to clipboard') });
    }
    if (record.jwt?.payloadFormatted) {
      items.push({ icon: 'copy', label: 'Copy JWT Payload', onSelect: () => copyText(record.jwt.payloadFormatted, 'Copied to clipboard') });
    }
    showMenu(rect.right, rect.bottom, items);
  }

  function initIcons() {
    setIcon($('pauseBtn'), 'pause');
    setIcon($('addBpBtn'), 'add_circle_outline');
    setIcon($('bpsBtn'), 'rule');
    setIcon($('clearBtn'), 'delete_outline');
    setIcon($('backBtn'), 'arrow_back');
    setIcon($('detailSearchToggle'), 'search');
    setIcon($('detailMoreBtn'), 'more_vert');
    setIcon($('scopesToggle'), 'tune');
    setIcon($('clearSearchBtn'), 'close');
    setIcon($('prevMatch'), 'keyboard_arrow_up');
    setIcon($('nextMatch'), 'keyboard_arrow_down');
    setIcon($('detailScopesToggle'), 'tune');
    setIcon($('closeDetailSearch'), 'close');
    $('searchIcon').innerHTML = svgIcon('search');
    $('detailSearchIcon').innerHTML = svgIcon('search');
    $('emptyIcon').innerHTML = svgIcon('http');
    $('detailEmptyIcon').innerHTML = svgIcon('http');
  }

  $('searchInput').addEventListener('input', (e) => {
    state.query = e.target.value;
    $('clearSearchBtn').classList.toggle('hidden', !state.query);
    loadRecords();
  });
  $('clearSearchBtn').onclick = () => {
    state.query = '';
    $('searchInput').value = '';
    $('clearSearchBtn').classList.add('hidden');
    loadRecords();
  };
  $('scopesToggle').onclick = () => {
    state.showScopes = !state.showScopes;
    $('scopesPanel').classList.toggle('hidden', !state.showScopes);
    renderChrome();
  };
  $('backBtn').onclick = clearSelection;
  $('pauseBtn').onclick = async () => {
    await api('/api/pause', { method: 'POST', body: {} });
    loadRecords();
  };
  $('addBpBtn').onclick = () => openAddBreakpoint('');
  $('bpsBtn').onclick = openAppliedBreakpoints;
  $('clearBtn').onclick = openClearDialog;
  $('detailSearchToggle').onclick = () => {
    state.detailSearchVisible = !state.detailSearchVisible;
    $('detailSearchBar').classList.toggle('hidden', !state.detailSearchVisible);
    $('detailSearchToggle').classList.toggle('active', state.detailSearchVisible);
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
    $('detailSearchToggle').classList.remove('active');
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
  $('detailMoreBtn').onclick = (e) => {
    e.stopPropagation();
    showDetailMore($('detailMoreBtn'));
  };
  document.addEventListener('click', hideMenu);
  window.addEventListener('resize', applyLayout);
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      hideMenu();
      if (!$('modalOverlay').classList.contains('hidden')) closeModal();
      else if (isMobile() && state.selectedId) clearSelection();
    }
  });

  initIcons();
  renderScopes();
  renderMethods();
  renderDetailScopes();
  applyLayout();
  loadRecords();
  connectSse();
})();
''';
