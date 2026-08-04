// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'network_monitoring_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class NetworkMonitoringLocalizationsEn extends NetworkMonitoringLocalizations {
  NetworkMonitoringLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get networkMonitor => 'Network Monitor';

  @override
  String get resumeAllRequests => 'Resume all requests';

  @override
  String get pauseAllRequests => 'Pause all requests';

  @override
  String get more => 'More';

  @override
  String get addBreakpoint => 'Add Breakpoint';

  @override
  String get appliedBreakpoints => 'Applied Breakpoints';

  @override
  String get devModeOptions => 'Dev Mode Options';

  @override
  String get clearAll => 'Clear All';

  @override
  String get clearAllRecordsTitle => 'Clear all records?';

  @override
  String get clearAllRecordsMessage =>
      'This will remove all captured HTTP requests from the list.';

  @override
  String get cancel => 'Cancel';

  @override
  String get addAction => 'Add';

  @override
  String get clear => 'Clear';

  @override
  String get urlCopied => 'URL copied';

  @override
  String breakpointRemovedFor(Object path) {
    return 'Breakpoint removed for $path';
  }

  @override
  String breakpointAddedFor(Object path) {
    return 'Breakpoint added for $path';
  }

  @override
  String pausedCount(Object count) {
    return '$count paused';
  }

  @override
  String requestsPaused(Object count) {
    return '$count request(s) paused';
  }

  @override
  String get continueAll => 'Continue All';

  @override
  String get searchHint => 'Search requests...';

  @override
  String get searchScopes => 'Search in';

  @override
  String get searchScopeUrl => 'URL';

  @override
  String get searchScopeStatus => 'Status';

  @override
  String get searchScopeHeaders => 'Headers';

  @override
  String get searchScopeQuery => 'Query';

  @override
  String get searchScopeRequest => 'Request';

  @override
  String get searchScopeResponse => 'Response';

  @override
  String get searchScopeAll => 'All fields';

  @override
  String get searchScopeReset => 'Reset';

  @override
  String get searchScopeCurrentTab => 'Current tab';

  @override
  String get searchScopeAllTabs => 'All tabs';

  @override
  String get searchInDetails => 'Search in details';

  @override
  String get searchInDetailsHint => 'Search in request / response...';

  @override
  String searchMatchesCount(int count) {
    return '$count matches';
  }

  @override
  String searchMatchOf(int current, int total) {
    return '$current - $total';
  }

  @override
  String get searchNoMatches => 'No matches';

  @override
  String get searchPrevious => 'Previous match';

  @override
  String get searchNext => 'Next match';

  @override
  String get filterAll => 'ALL';

  @override
  String get noHttpRequestsRecorded => 'No HTTP requests recorded';

  @override
  String get requestsWillAppearWhenActive =>
      'Requests will appear here when monitoring is active';

  @override
  String get removeBreakpoint => 'Remove breakpoint';

  @override
  String get addBreakpointTooltip => 'Add breakpoint';

  @override
  String get noBreakpointsConfigured => 'No breakpoints configured';

  @override
  String get allEndpoints => 'All Endpoints';

  @override
  String get unknown => 'Unknown';

  @override
  String get viewDetails => 'View Details';

  @override
  String get removeBreakpointThisEndpoint =>
      'Remove Breakpoint (this endpoint)';

  @override
  String get addBreakpointThisEndpoint => 'Add Breakpoint (this endpoint)';

  @override
  String get addBreakpointCustom => 'Add Breakpoint (custom)...';

  @override
  String get copyUrl => 'Copy URL';

  @override
  String get cancelled => 'CANCELLED';

  @override
  String get allRequestsPausedHint =>
      'All requests are paused. Tap resume to continue sending traffic.';

  @override
  String get allEndpointsBreakpointActiveHint =>
      'Breakpoint active for all endpoints. Matching requests will pause.';

  @override
  String get target => 'Target';

  @override
  String get specificEndpoint => 'Specific Endpoint';

  @override
  String get endpointPatternHint => 'e.g. /api/login or /users';

  @override
  String get breakOn => 'Break On';

  @override
  String get bothRequestAndResponse => 'Both Request & Response';

  @override
  String get requestOnly => 'Request Only';

  @override
  String get responseOnly => 'Response Only';

  @override
  String get enableDevMode => 'Enable Dev Mode';

  @override
  String get enterDevModePassword => 'Enter password to enable developer mode';

  @override
  String get password => 'Password';

  @override
  String get enable => 'Enable';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get validationFailed => 'Validation failed';

  @override
  String get httpMonitoring => 'HTTP Monitoring';

  @override
  String get httpMonitoringDescription =>
      'Monitor all HTTP requests and responses in real-time. Shows a floating button for quick access.';

  @override
  String get monitoringHttp => 'Monitoring HTTP';

  @override
  String get showFloatingButton => 'Show Floating Button';

  @override
  String get remoteMonitor => 'Remote Monitor';

  @override
  String get remoteMonitorDescription =>
      'Start a local web server so you can open the network monitor in a browser on another device on the same network.';

  @override
  String get remoteMonitorEnabled => 'Enable remote monitor';

  @override
  String get remoteMonitorUrl => 'Open in browser';

  @override
  String get remoteMonitorUrlCopied => 'Remote monitor URL copied';

  @override
  String get remoteMonitorStarting => 'Starting remote monitor…';

  @override
  String get remoteMonitorFailed => 'Could not start remote monitor';

  @override
  String get breakpoints => 'Breakpoints';

  @override
  String get noBreakpointsConfiguredDevMode =>
      'No breakpoints configured. Add breakpoints from the monitor view.';

  @override
  String get disableDevMode => 'Disable Dev Mode';

  @override
  String get copyRequestHeaders => 'Copy Request Headers';

  @override
  String get copyRequestBody => 'Copy Request Body';

  @override
  String get copyResponseBody => 'Copy Response Body';

  @override
  String get copyAuthToken => 'Copy Auth Token';

  @override
  String get shareAllDetails => 'Share All Details';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get overview => 'Overview';

  @override
  String get request => 'Request';

  @override
  String get response => 'Response';

  @override
  String get headers => 'Headers';

  @override
  String get size => 'Size';

  @override
  String get sizeReqHeaders => 'Req headers';

  @override
  String get sizeReqBody => 'Req body';

  @override
  String get sizeReqTotal => 'Req total';

  @override
  String get sizeResHeaders => 'Res headers';

  @override
  String get sizeResBody => 'Res body';

  @override
  String get sizeResTotal => 'Res total';

  @override
  String get general => 'General';

  @override
  String get url => 'URL';

  @override
  String get method => 'Method';

  @override
  String get status => 'Status';

  @override
  String get duration => 'Duration';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get error => 'Error';

  @override
  String get message => 'Message';

  @override
  String get authentication => 'Authentication';

  @override
  String get token => 'Token';

  @override
  String get jwtHeader => 'JWT Header';

  @override
  String get jwtPayload => 'JWT Payload';

  @override
  String get expiresAt => 'Expires At';

  @override
  String get issuedAt => 'Issued At';

  @override
  String get copyJwtPayload => 'Copy JWT Payload';

  @override
  String get jwtDecode => 'JWT Decode';

  @override
  String get jwtNotJwtHint =>
      'This auth token is not a JWT. Expected Bearer token with header.payload.signature format.';

  @override
  String get jwtDecodeFailedHint =>
      'This token looks like a JWT but the header or payload could not be decoded.';

  @override
  String get queryParameters => 'Query Parameters';

  @override
  String get requestBody => 'Request Body';

  @override
  String get responseBody => 'Response Body';

  @override
  String get requestHeaders => 'Request Headers';

  @override
  String get responseHeaders => 'Response Headers';

  @override
  String get noRequestBody => 'No request body';

  @override
  String get noResponseBody => 'No response body';

  @override
  String get noResponseHeaders => 'No response headers';

  @override
  String get pending => 'Pending';

  @override
  String copiedLabel(Object label) {
    return 'Copied $label';
  }

  @override
  String copiedTitle(Object title) {
    return 'Copied $title';
  }

  @override
  String copiedItem(Object index) {
    return 'Copied item [$index]';
  }

  @override
  String copiedKey(Object key) {
    return 'Copied \"$key\"';
  }

  @override
  String copiedKeyBracket(Object key) {
    return 'Copied [$key]';
  }

  @override
  String get editRequest => 'Edit Request';

  @override
  String get editResponse => 'Edit Response';

  @override
  String get continueAction => 'Continue';

  @override
  String get responsePaused => 'Response paused';

  @override
  String get requestPaused => 'Request paused';

  @override
  String get editHeadersHint => 'Edit headers as JSON...';

  @override
  String get editBodyHint => 'Edit body content...';

  @override
  String get invalidJsonInHeaders => 'Invalid JSON in headers';

  @override
  String get rawJson => 'Raw JSON';

  @override
  String get table => 'Table';

  @override
  String get skipNoEdit => 'Skip (No Edit)';

  @override
  String get applyAndContinue => 'Apply & Continue';

  @override
  String get body => 'Body';

  @override
  String get breakpointTypeAll => 'ALL';

  @override
  String get breakpointTypeRequest => 'REQUEST';

  @override
  String get breakpointTypeResponse => 'RESPONSE';

  @override
  String get requestCancelledByBreakpoint => 'Request cancelled by breakpoint';

  @override
  String get cancelledByBreakpoint => 'Cancelled by breakpoint';

  @override
  String get shareApiRequestDetails => '=== API Request Details ===';

  @override
  String get shareRequestHeaders => '--- Request Headers ---';

  @override
  String get shareRequestBody => '--- Request Body ---';

  @override
  String get shareResponseHeaders => '--- Response Headers ---';

  @override
  String get shareResponseBody => '--- Response Body ---';
}
