part of 'remote_monitor_web.dart';

const _kAppCss = r'''
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
  --list-width: 380px;
  font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif;
}
* { box-sizing: border-box; }
html, body { height: 100%; }
body {
  margin: 0;
  background: var(--bg);
  color: var(--text);
  overflow: hidden;
}
#app {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: var(--surface);
}
.topbar {
  flex-shrink: 0;
  z-index: 20;
  background: var(--surface);
  border-bottom: 1px solid var(--border);
  padding: 10px 16px 8px;
}
.topbar-row { display: flex; align-items: center; gap: 8px; }
.topbar h1, .detail-header h2 {
  font-size: 18px;
  font-weight: 700;
  margin: 0;
  flex: 1;
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.detail-header h2 { font-size: 16px; }
.topbar-actions { display: flex; align-items: center; gap: 2px; flex-shrink: 0; }
.status-line { font-size: 12px; color: var(--muted); margin-top: 4px; }
.paused-badge {
  background: var(--pending);
  color: #fff;
  font-size: 10px;
  font-weight: 700;
  padding: 2px 8px;
  border-radius: 12px;
  white-space: nowrap;
}
.icon-btn {
  position: relative;
  border: none;
  background: transparent;
  border-radius: 20px;
  width: 40px;
  height: 40px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: var(--text);
  padding: 0;
}
.icon-btn.tiny { width: 36px; height: 36px; }
.icon-btn:hover { background: var(--field); }
.icon-btn.active { color: var(--primary); }
.icon-btn.danger { color: var(--err); }
.icon-btn.paused { color: var(--pending); }
.icon-btn svg { width: 22px; height: 22px; fill: currentColor; display: block; }
.icon-btn.tiny svg { width: 20px; height: 20px; }
.count-badge {
  position: absolute;
  top: 4px;
  right: 2px;
  min-width: 16px;
  height: 16px;
  padding: 0 4px;
  border-radius: 8px;
  background: var(--primary);
  color: #fff;
  font-size: 10px;
  font-weight: 700;
  line-height: 16px;
  text-align: center;
}
.hidden { display: none !important; }
.workspace {
  flex: 1;
  min-height: 0;
  display: grid;
  grid-template-columns: minmax(280px, var(--list-width)) 1fr;
}
.list-pane, .detail-pane {
  min-height: 0;
  min-width: 0;
  display: flex;
  flex-direction: column;
}
.list-pane { border-right: 1px solid var(--border); background: var(--surface); }
.search-panel { flex-shrink: 0; padding: 12px 16px; border-bottom: 1px solid var(--border); }
.search-row { display: flex; gap: 8px; }
.search-field {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 4px;
  background: var(--field);
  border-radius: var(--radius);
  padding: 0 4px 0 10px;
}
.field-icon { color: var(--muted); display: inline-flex; }
.field-icon svg { width: 20px; height: 20px; fill: currentColor; }
.search-field input, #detailSearchInput {
  flex: 1;
  border: none;
  background: transparent;
  padding: 12px 6px;
  font-size: 14px;
  outline: none;
  color: var(--text);
  min-width: 0;
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
.hint-bar {
  width: 100%;
  padding: 10px 16px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  font-weight: 500;
  flex-shrink: 0;
}
.hint-bar svg { width: 20px; height: 20px; fill: currentColor; flex-shrink: 0; }
.hint-bar .hint-text { flex: 1; }
.hint-bar button.link {
  border: none;
  background: none;
  color: var(--primary);
  font-weight: 700;
  font-size: 12px;
  cursor: pointer;
  padding: 0;
}
.hint-bar.pause { background: color-mix(in srgb, var(--pending) 12%, transparent); color: #9a3412; }
.hint-bar.pause svg { color: var(--pending); }
.hint-bar.all-ep { background: color-mix(in srgb, var(--primary) 8%, transparent); color: var(--primary); }
.hint-bar.active-bp { background: color-mix(in srgb, var(--pending) 10%, transparent); color: var(--pending); }
.record-list {
  flex: 1;
  overflow: auto;
  padding: 8px 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.card {
  border: 1px solid var(--border);
  background: var(--field);
  border-radius: var(--radius);
  padding: 12px;
  cursor: pointer;
  box-shadow: var(--shadow);
}
.card:hover { border-color: var(--primary); }
.card.selected {
  border-color: var(--primary);
  background: color-mix(in srgb, var(--primary) 10%, var(--field));
}
.card.focused {
  outline: 2px solid var(--primary);
  outline-offset: -1px;
}
.card.paused {
  border-color: color-mix(in srgb, var(--pending) 40%, var(--border));
  background: color-mix(in srgb, var(--pending) 8%, var(--field));
}
.card.paused.selected {
  border-color: var(--primary);
}
.card-row { display: flex; align-items: center; gap: 8px; }
.path { flex: 1; font-size: 12px; font-weight: 500; overflow-wrap: anywhere; word-break: break-word; }
.url-line { display: flex; gap: 8px; margin-top: 6px; align-items: flex-start; }
.url-line .url { flex: 1; font-size: 10px; color: var(--muted); overflow-wrap: anywhere; word-break: break-word; }
.url-line .url.original { text-decoration: line-through; opacity: .7; margin-top: 2px; display: block; }
.url-line .dur { font-size: 10px; color: var(--muted); flex-shrink: 0; }
.card-actions { display: flex; align-items: center; gap: 4px; flex-shrink: 0; }
.action-btn {
  width: 26px;
  height: 26px;
  border: 1px solid transparent;
  border-radius: 4px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  padding: 0;
  background: transparent;
  color: var(--text);
}
.action-btn svg { width: 16px; height: 16px; fill: currentColor; }
.action-btn.bp {
  background: var(--field);
  border-color: var(--border);
  color: var(--muted);
}
.action-btn.bp.active {
  background: color-mix(in srgb, var(--pending) 15%, transparent);
  border-color: color-mix(in srgb, var(--pending) 40%, transparent);
  color: var(--pending);
}
.action-btn.edit { background: color-mix(in srgb, var(--primary) 10%, transparent); color: var(--primary); }
.action-btn.play { background: color-mix(in srgb, var(--ok) 10%, transparent); color: var(--ok); }
.action-btn.stop { background: color-mix(in srgb, var(--err) 10%, transparent); color: var(--err); }
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
.badge.status.cancelled { color: var(--muted); background: color-mix(in srgb, var(--muted) 15%, white); }
.empty { text-align: center; padding: 64px 24px; color: var(--muted); }
.detail-empty { flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; }
.empty-icon { color: var(--muted); opacity: .5; margin-bottom: 12px; }
.empty-icon svg { width: 64px; height: 64px; fill: currentColor; }
.muted { color: var(--muted); font-size: 12px; }
.detail-view { flex: 1; min-height: 0; display: flex; flex-direction: column; }
.detail-header { flex-shrink: 0; border-bottom: 1px solid var(--border); padding: 8px 12px 0; }
.tabs {
  display: flex; gap: 0;
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
.detail-body { flex: 1; overflow: auto; padding: 16px; }
.detail-search { padding: 8px 4px 12px; }
.detail-search-nav { display: flex; align-items: center; gap: 4px; margin-top: 8px; }
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
.block-actions { display: flex; gap: 8px; align-items: center; }
.kv { display: grid; grid-template-columns: 120px 1fr auto; gap: 8px; font-size: 13px; margin-bottom: 8px; align-items: start; }
.kv .label { color: var(--muted); font-weight: 500; font-size: 12px; }
.kv .value { word-break: break-word; font-size: 12px; }
.kv .copy-inline { color: var(--muted); cursor: pointer; background: none; border: none; padding: 0; display: inline-flex; }
.kv .copy-inline svg { width: 16px; height: 16px; fill: currentColor; }
.pre {
  margin: 0;
  white-space: pre-wrap;
  word-break: break-word;
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-size: 12px;
  line-height: 1.5;
}
.code-body {
  background: var(--surface);
  border-radius: 8px;
  overflow: auto;
}
.code-view {
  display: grid;
  grid-template-columns: auto 16px 1fr;
  column-gap: 8px;
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-size: 12px;
  line-height: 1.5;
  padding: 8px 8px 8px 4px;
  min-width: min-content;
}
.code-line { display: contents; }
.fold-btn {
  border: none;
  background: transparent;
  width: 16px;
  height: 18px;
  padding: 0;
  cursor: pointer;
  color: var(--muted);
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
.fold-btn svg { width: 14px; height: 14px; fill: currentColor; }
.fold-spacer { width: 16px; height: 18px; display: inline-block; }
.ln {
  color: var(--muted);
  opacity: .75;
  text-align: right;
  user-select: none;
  white-space: pre;
}
.code-text { white-space: pre; }
.code-view.search {
  display: flex;
  gap: 8px;
  align-items: flex-start;
}
.code-view.search .gutter {
  margin: 0;
  color: var(--muted);
  opacity: .75;
  user-select: none;
  text-align: right;
  white-space: pre;
  font-family: inherit;
  font-size: inherit;
  line-height: inherit;
}
.code-view.search .pre {
  flex: 1;
  white-space: pre;
  word-break: normal;
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
  color: #000;
  padding: 0 1px;
  border-radius: 2px;
}
mark.hl.active {
  background: #ea580c;
  color: #fff;
  font-weight: 700;
  padding: 0 2px;
  border-radius: 2px;
  box-shadow: 0 0 0 1px #c2410c;
}
.toast {
  position: fixed; left: 50%; bottom: 24px; transform: translateX(-50%);
  background: #111; color: #fff; padding: 10px 16px;
  border-radius: 8px; font-size: 13px; z-index: 80;
}
.menu {
  position: fixed;
  z-index: 70;
  min-width: 240px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0,0,0,.16);
  padding: 6px;
}
.menu-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  color: var(--text);
  border: none;
  background: none;
  width: 100%;
  text-align: left;
}
.menu-item:hover { background: var(--field); }
.menu-item svg { width: 22px; height: 22px; fill: currentColor; color: var(--muted); flex-shrink: 0; }
.menu-item.orange svg { color: var(--pending); }
.modal-overlay {
  position: fixed; inset: 0;
  background: rgba(0,0,0,.4);
  z-index: 60;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
}
.modal {
  background: var(--surface);
  border-radius: 12px;
  width: min(520px, 100%);
  max-height: min(86vh, 720px);
  overflow: auto;
  box-shadow: 0 16px 48px rgba(0,0,0,.2);
}
.modal.wide { width: min(720px, 100%); }
.modal-head {
  display: flex; align-items: center; gap: 8px;
  padding: 16px 16px 8px;
}
.modal-head h3 { margin: 0; flex: 1; font-size: 18px; }
.modal-head > svg { width: 22px; height: 22px; fill: currentColor; color: var(--primary); flex-shrink: 0; }
.modal-body { padding: 8px 16px 16px; }
.modal-actions {
  display: flex; justify-content: flex-end; gap: 8px;
  padding: 0 16px 16px;
}
.modal label.group-title {
  display: block;
  font-size: 14px;
  font-weight: 700;
  margin: 12px 0 6px;
}
.radio-row, .bp-row {
  display: flex; align-items: center; gap: 8px;
  padding: 4px 0;
  font-size: 14px;
}
.modal input[type="text"], .modal textarea {
  width: 100%;
  border: none;
  background: var(--field);
  border-radius: 8px;
  padding: 10px 12px;
  font-size: 14px;
  color: var(--text);
  outline: none;
}
.modal textarea {
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-size: 12px;
  min-height: 180px;
  resize: vertical;
}
.text-btn {
  border: none;
  background: none;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  padding: 8px 12px;
  color: var(--muted);
  display: inline-flex;
  align-items: center;
  gap: 4px;
}
.text-btn svg { width: 18px; height: 18px; fill: currentColor; }
.text-btn.primary { color: var(--primary); font-weight: 700; }
.text-btn.danger { color: var(--err); font-weight: 700; }
.text-btn.ok { color: var(--ok); font-weight: 700; }
.bp-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  margin-bottom: 8px;
  background: var(--field);
  border: 1px solid var(--border);
  border-radius: 10px;
}
.bp-item .bp-meta { flex: 1; min-width: 0; }
.bp-item .bp-title { font-size: 14px; font-weight: 500; }
.switch {
  position: relative;
  width: 40px;
  height: 22px;
  flex-shrink: 0;
}
.switch input { opacity: 0; width: 0; height: 0; }
.slider {
  position: absolute; inset: 0;
  background: #c6c6cb;
  border-radius: 22px;
  cursor: pointer;
}
.slider:before {
  content: '';
  position: absolute;
  height: 18px; width: 18px;
  left: 2px; bottom: 2px;
  background: #fff;
  border-radius: 50%;
  transition: .15s;
}
.switch input:checked + .slider { background: color-mix(in srgb, var(--primary) 70%, #93c5fd); }
.switch input:checked + .slider:before { transform: translateX(18px); background: var(--primary); }
.edit-banner {
  background: color-mix(in srgb, var(--pending) 8%, transparent);
  padding: 10px 16px;
  font-size: 12px;
}
.edit-banner .title { color: var(--pending); font-weight: 700; display: flex; align-items: center; gap: 6px; }
.edit-banner svg { width: 16px; height: 16px; fill: currentColor; }
.edit-tabs { display: flex; border-bottom: 1px solid var(--border); padding: 0 8px; }
.edit-actions {
  display: flex; gap: 12px;
  padding: 12px 16px;
  border-top: 1px solid var(--border);
}
.edit-actions .btn {
  flex: 1;
  border-radius: 8px;
  padding: 12px;
  font-weight: 700;
  font-size: 12px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}
.edit-actions .btn svg { width: 18px; height: 18px; fill: currentColor; }
.edit-actions .btn.ghost {
  background: transparent;
  border: 1px solid var(--border);
  color: var(--text);
}
.edit-actions .btn.solid {
  background: var(--primary);
  border: none;
  color: #fff;
}
@media (max-width: 800px) {
  .workspace { grid-template-columns: 1fr; }
  .detail-pane { display: none; }
  .detail-pane.open {
    display: flex;
    position: fixed;
    inset: 0;
    z-index: 30;
    background: var(--surface);
  }
  #app.detail-open .list-pane { display: none; }
  #app.detail-open .topbar { display: none; }
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
  .chip.active { background: color-mix(in srgb, var(--primary) 22%, var(--field)); }
  .badge.method.get, .badge.status.ok { background: color-mix(in srgb, var(--get) 22%, var(--field)); }
  .badge.method.post { background: color-mix(in srgb, var(--post) 22%, var(--field)); }
  .badge.method.put, .badge.status.pending { background: color-mix(in srgb, var(--put) 22%, var(--field)); }
  .badge.method.patch { background: color-mix(in srgb, var(--patch) 22%, var(--field)); }
  .badge.method.delete, .badge.status.err { background: color-mix(in srgb, var(--err) 22%, var(--field)); }
}
''';
