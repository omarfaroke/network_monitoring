part 'remote_monitor_web_css.dart';
part 'remote_monitor_web_js.dart';

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
        <h1>Network Monitor</h1>
        <span id="pausedBadge" class="paused-badge hidden"></span>
        <div class="topbar-actions">
          <button id="pauseBtn" class="icon-btn" title="Pause all requests" aria-label="Pause all requests"></button>
          <button id="addBpBtn" class="icon-btn" title="Add Breakpoint" aria-label="Add Breakpoint"></button>
          <button id="bpsBtn" class="icon-btn" title="Applied Breakpoints" aria-label="Applied Breakpoints">
            <span id="bpCount" class="count-badge hidden"></span>
          </button>
          <button id="addHoBtn" class="icon-btn" title="Add Host Override" aria-label="Add Host Override"></button>
          <button id="hosBtn" class="icon-btn" title="Host Overrides" aria-label="Host Overrides">
            <span id="hoCount" class="count-badge hidden"></span>
          </button>
          <button id="clearBtn" class="icon-btn danger" title="Clear all" aria-label="Clear all"></button>
        </div>
      </div>
      <div id="statusLine" class="status-line">Connecting…</div>
    </header>

    <div class="workspace">
      <aside id="listPane" class="list-pane">
        <div class="search-panel">
          <div class="search-row">
            <div class="search-field">
              <span id="searchIcon" class="field-icon"></span>
              <input id="searchInput" type="search" placeholder="Search requests..." />
              <button id="clearSearchBtn" class="icon-btn tiny hidden" title="Clear" aria-label="Clear search"></button>
              <button id="scopesToggle" class="icon-btn tiny" title="Search in" aria-label="Search in"></button>
            </div>
          </div>
          <div id="scopesPanel" class="scopes-panel hidden"></div>
          <div id="methodFilters" class="chips"></div>
        </div>
        <div id="hintBars"></div>
        <div id="recordList" class="record-list"></div>
        <div id="emptyState" class="empty hidden">
          <div id="emptyIcon" class="empty-icon"></div>
          <p>No HTTP requests recorded</p>
          <p class="muted">Requests will appear here when monitoring is active</p>
        </div>
      </aside>

      <section id="detailPane" class="detail-pane">
        <div id="detailEmpty" class="empty detail-empty">
          <div id="detailEmptyIcon" class="empty-icon"></div>
          <p>Select a request to inspect</p>
          <p class="muted">Request and response details appear here</p>
        </div>
        <div id="detailView" class="detail-view hidden">
          <div class="detail-header">
            <div class="topbar-row">
              <button id="backBtn" class="icon-btn hidden" title="Back" aria-label="Back"></button>
              <h2 id="detailTitle">Details</h2>
              <div class="topbar-actions">
                <div id="detailPauseActions" class="card-actions hidden"></div>
                <button id="detailSearchToggle" class="icon-btn" title="Search in details" aria-label="Search in details"></button>
                <button id="detailMoreBtn" class="icon-btn" title="More" aria-label="More"></button>
              </div>
            </div>
            <div id="detailSearchBar" class="detail-search hidden">
              <div class="search-field">
                <span id="detailSearchIcon" class="field-icon"></span>
                <input id="detailSearchInput" type="search" placeholder="Search in request / response..." />
              </div>
              <div class="detail-search-nav">
                <span id="detailMatchLabel" class="muted"></span>
                <button id="prevMatch" class="icon-btn tiny" title="Previous match" aria-label="Previous match"></button>
                <button id="nextMatch" class="icon-btn tiny" title="Next match" aria-label="Next match"></button>
                <button id="detailScopesToggle" class="icon-btn tiny" title="Search in" aria-label="Search in"></button>
                <button id="closeDetailSearch" class="icon-btn tiny" title="Close" aria-label="Close search"></button>
              </div>
              <div id="detailScopesPanel" class="scopes-panel hidden"></div>
            </div>
            <div class="tabs" id="detailTabs">
              <button data-tab="0" class="tab active">Overview</button>
              <button data-tab="1" class="tab">Request</button>
              <button data-tab="2" class="tab">Response</button>
              <button data-tab="3" class="tab">Headers</button>
            </div>
          </div>
          <div id="detailBody" class="detail-body"></div>
        </div>
      </section>
    </div>
  </div>
  <div id="modalOverlay" class="modal-overlay hidden"></div>
  <div id="ctxMenu" class="menu hidden"></div>
  <div id="toast" class="toast hidden"></div>
  <script src="/app.js"></script>
</body>
</html>
''';

  static const appCss = _kAppCss;

  static const appJs = _kAppJs;
}
