import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'network_monitoring_localizations_ar.dart';
import 'network_monitoring_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of NetworkMonitoringLocalizations
/// returned by `NetworkMonitoringLocalizations.of(context)`.
///
/// Applications need to include `NetworkMonitoringLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/network_monitoring_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: NetworkMonitoringLocalizations.localizationsDelegates,
///   supportedLocales: NetworkMonitoringLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the NetworkMonitoringLocalizations.supportedLocales
/// property.
abstract class NetworkMonitoringLocalizations {
  NetworkMonitoringLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static NetworkMonitoringLocalizations of(BuildContext context) {
    return Localizations.of<NetworkMonitoringLocalizations>(
      context,
      NetworkMonitoringLocalizations,
    )!;
  }

  static const LocalizationsDelegate<NetworkMonitoringLocalizations> delegate =
      _NetworkMonitoringLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @networkMonitor.
  ///
  /// In en, this message translates to:
  /// **'Network Monitor'**
  String get networkMonitor;

  /// No description provided for @resumeAllRequests.
  ///
  /// In en, this message translates to:
  /// **'Resume all requests'**
  String get resumeAllRequests;

  /// No description provided for @pauseAllRequests.
  ///
  /// In en, this message translates to:
  /// **'Pause all requests'**
  String get pauseAllRequests;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @addBreakpoint.
  ///
  /// In en, this message translates to:
  /// **'Add Breakpoint'**
  String get addBreakpoint;

  /// No description provided for @appliedBreakpoints.
  ///
  /// In en, this message translates to:
  /// **'Applied Breakpoints'**
  String get appliedBreakpoints;

  /// No description provided for @devModeOptions.
  ///
  /// In en, this message translates to:
  /// **'Dev Mode Options'**
  String get devModeOptions;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @clearAllRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all records?'**
  String get clearAllRecordsTitle;

  /// No description provided for @clearAllRecordsMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove all captured HTTP requests from the list.'**
  String get clearAllRecordsMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @urlCopied.
  ///
  /// In en, this message translates to:
  /// **'URL copied'**
  String get urlCopied;

  /// No description provided for @breakpointRemovedFor.
  ///
  /// In en, this message translates to:
  /// **'Breakpoint removed for {path}'**
  String breakpointRemovedFor(Object path);

  /// No description provided for @breakpointAddedFor.
  ///
  /// In en, this message translates to:
  /// **'Breakpoint added for {path}'**
  String breakpointAddedFor(Object path);

  /// No description provided for @pausedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} paused'**
  String pausedCount(Object count);

  /// No description provided for @requestsPaused.
  ///
  /// In en, this message translates to:
  /// **'{count} request(s) paused'**
  String requestsPaused(Object count);

  /// No description provided for @continueAll.
  ///
  /// In en, this message translates to:
  /// **'Continue All'**
  String get continueAll;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by URL, path, or status code...'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get filterAll;

  /// No description provided for @noHttpRequestsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No HTTP requests recorded'**
  String get noHttpRequestsRecorded;

  /// No description provided for @requestsWillAppearWhenActive.
  ///
  /// In en, this message translates to:
  /// **'Requests will appear here when monitoring is active'**
  String get requestsWillAppearWhenActive;

  /// No description provided for @removeBreakpoint.
  ///
  /// In en, this message translates to:
  /// **'Remove breakpoint'**
  String get removeBreakpoint;

  /// No description provided for @addBreakpointTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add breakpoint'**
  String get addBreakpointTooltip;

  /// No description provided for @noBreakpointsConfigured.
  ///
  /// In en, this message translates to:
  /// **'No breakpoints configured'**
  String get noBreakpointsConfigured;

  /// No description provided for @allEndpoints.
  ///
  /// In en, this message translates to:
  /// **'All Endpoints'**
  String get allEndpoints;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @removeBreakpointThisEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Remove Breakpoint (this endpoint)'**
  String get removeBreakpointThisEndpoint;

  /// No description provided for @addBreakpointThisEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Add Breakpoint (this endpoint)'**
  String get addBreakpointThisEndpoint;

  /// No description provided for @addBreakpointCustom.
  ///
  /// In en, this message translates to:
  /// **'Add Breakpoint (custom)...'**
  String get addBreakpointCustom;

  /// No description provided for @copyUrl.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get copyUrl;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get cancelled;

  /// No description provided for @allRequestsPausedHint.
  ///
  /// In en, this message translates to:
  /// **'All requests are paused. Tap resume to continue sending traffic.'**
  String get allRequestsPausedHint;

  /// No description provided for @allEndpointsBreakpointActiveHint.
  ///
  /// In en, this message translates to:
  /// **'Breakpoint active for all endpoints. Matching requests will pause.'**
  String get allEndpointsBreakpointActiveHint;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @specificEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Specific Endpoint'**
  String get specificEndpoint;

  /// No description provided for @endpointPatternHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. /api/login or /users'**
  String get endpointPatternHint;

  /// No description provided for @breakOn.
  ///
  /// In en, this message translates to:
  /// **'Break On'**
  String get breakOn;

  /// No description provided for @bothRequestAndResponse.
  ///
  /// In en, this message translates to:
  /// **'Both Request & Response'**
  String get bothRequestAndResponse;

  /// No description provided for @requestOnly.
  ///
  /// In en, this message translates to:
  /// **'Request Only'**
  String get requestOnly;

  /// No description provided for @responseOnly.
  ///
  /// In en, this message translates to:
  /// **'Response Only'**
  String get responseOnly;

  /// No description provided for @enableDevMode.
  ///
  /// In en, this message translates to:
  /// **'Enable Dev Mode'**
  String get enableDevMode;

  /// No description provided for @enterDevModePassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password to enable developer mode'**
  String get enterDevModePassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPassword;

  /// No description provided for @validationFailed.
  ///
  /// In en, this message translates to:
  /// **'Validation failed'**
  String get validationFailed;

  /// No description provided for @httpMonitoring.
  ///
  /// In en, this message translates to:
  /// **'HTTP Monitoring'**
  String get httpMonitoring;

  /// No description provided for @httpMonitoringDescription.
  ///
  /// In en, this message translates to:
  /// **'Monitor all HTTP requests and responses in real-time. Shows a floating button for quick access.'**
  String get httpMonitoringDescription;

  /// No description provided for @monitoringHttp.
  ///
  /// In en, this message translates to:
  /// **'Monitoring HTTP'**
  String get monitoringHttp;

  /// No description provided for @showFloatingButton.
  ///
  /// In en, this message translates to:
  /// **'Show Floating Button'**
  String get showFloatingButton;

  /// No description provided for @breakpoints.
  ///
  /// In en, this message translates to:
  /// **'Breakpoints'**
  String get breakpoints;

  /// No description provided for @noBreakpointsConfiguredDevMode.
  ///
  /// In en, this message translates to:
  /// **'No breakpoints configured. Add breakpoints from the monitor view.'**
  String get noBreakpointsConfiguredDevMode;

  /// No description provided for @disableDevMode.
  ///
  /// In en, this message translates to:
  /// **'Disable Dev Mode'**
  String get disableDevMode;

  /// No description provided for @copyRequestHeaders.
  ///
  /// In en, this message translates to:
  /// **'Copy Request Headers'**
  String get copyRequestHeaders;

  /// No description provided for @copyRequestBody.
  ///
  /// In en, this message translates to:
  /// **'Copy Request Body'**
  String get copyRequestBody;

  /// No description provided for @copyResponseBody.
  ///
  /// In en, this message translates to:
  /// **'Copy Response Body'**
  String get copyResponseBody;

  /// No description provided for @copyAuthToken.
  ///
  /// In en, this message translates to:
  /// **'Copy Auth Token'**
  String get copyAuthToken;

  /// No description provided for @shareAllDetails.
  ///
  /// In en, this message translates to:
  /// **'Share All Details'**
  String get shareAllDetails;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @response.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get response;

  /// No description provided for @headers.
  ///
  /// In en, this message translates to:
  /// **'Headers'**
  String get headers;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @sizeReqHeaders.
  ///
  /// In en, this message translates to:
  /// **'Req headers'**
  String get sizeReqHeaders;

  /// No description provided for @sizeReqBody.
  ///
  /// In en, this message translates to:
  /// **'Req body'**
  String get sizeReqBody;

  /// No description provided for @sizeReqTotal.
  ///
  /// In en, this message translates to:
  /// **'Req total'**
  String get sizeReqTotal;

  /// No description provided for @sizeResHeaders.
  ///
  /// In en, this message translates to:
  /// **'Res headers'**
  String get sizeResHeaders;

  /// No description provided for @sizeResBody.
  ///
  /// In en, this message translates to:
  /// **'Res body'**
  String get sizeResBody;

  /// No description provided for @sizeResTotal.
  ///
  /// In en, this message translates to:
  /// **'Res total'**
  String get sizeResTotal;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @url.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get url;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @authentication.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authentication;

  /// No description provided for @token.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get token;

  /// No description provided for @jwtHeader.
  ///
  /// In en, this message translates to:
  /// **'JWT Header'**
  String get jwtHeader;

  /// No description provided for @jwtPayload.
  ///
  /// In en, this message translates to:
  /// **'JWT Payload'**
  String get jwtPayload;

  /// No description provided for @expiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expires At'**
  String get expiresAt;

  /// No description provided for @issuedAt.
  ///
  /// In en, this message translates to:
  /// **'Issued At'**
  String get issuedAt;

  /// No description provided for @copyJwtPayload.
  ///
  /// In en, this message translates to:
  /// **'Copy JWT Payload'**
  String get copyJwtPayload;

  /// No description provided for @jwtDecode.
  ///
  /// In en, this message translates to:
  /// **'JWT Decode'**
  String get jwtDecode;

  /// No description provided for @jwtNotJwtHint.
  ///
  /// In en, this message translates to:
  /// **'This auth token is not a JWT. Expected Bearer token with header.payload.signature format.'**
  String get jwtNotJwtHint;

  /// No description provided for @jwtDecodeFailedHint.
  ///
  /// In en, this message translates to:
  /// **'This token looks like a JWT but the header or payload could not be decoded.'**
  String get jwtDecodeFailedHint;

  /// No description provided for @queryParameters.
  ///
  /// In en, this message translates to:
  /// **'Query Parameters'**
  String get queryParameters;

  /// No description provided for @requestBody.
  ///
  /// In en, this message translates to:
  /// **'Request Body'**
  String get requestBody;

  /// No description provided for @responseBody.
  ///
  /// In en, this message translates to:
  /// **'Response Body'**
  String get responseBody;

  /// No description provided for @requestHeaders.
  ///
  /// In en, this message translates to:
  /// **'Request Headers'**
  String get requestHeaders;

  /// No description provided for @responseHeaders.
  ///
  /// In en, this message translates to:
  /// **'Response Headers'**
  String get responseHeaders;

  /// No description provided for @noRequestBody.
  ///
  /// In en, this message translates to:
  /// **'No request body'**
  String get noRequestBody;

  /// No description provided for @noResponseBody.
  ///
  /// In en, this message translates to:
  /// **'No response body'**
  String get noResponseBody;

  /// No description provided for @noResponseHeaders.
  ///
  /// In en, this message translates to:
  /// **'No response headers'**
  String get noResponseHeaders;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @copiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Copied {label}'**
  String copiedLabel(Object label);

  /// No description provided for @copiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Copied {title}'**
  String copiedTitle(Object title);

  /// No description provided for @copiedItem.
  ///
  /// In en, this message translates to:
  /// **'Copied item [{index}]'**
  String copiedItem(Object index);

  /// No description provided for @copiedKey.
  ///
  /// In en, this message translates to:
  /// **'Copied \"{key}\"'**
  String copiedKey(Object key);

  /// No description provided for @copiedKeyBracket.
  ///
  /// In en, this message translates to:
  /// **'Copied [{key}]'**
  String copiedKeyBracket(Object key);

  /// No description provided for @editRequest.
  ///
  /// In en, this message translates to:
  /// **'Edit Request'**
  String get editRequest;

  /// No description provided for @editResponse.
  ///
  /// In en, this message translates to:
  /// **'Edit Response'**
  String get editResponse;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @responsePaused.
  ///
  /// In en, this message translates to:
  /// **'Response paused'**
  String get responsePaused;

  /// No description provided for @requestPaused.
  ///
  /// In en, this message translates to:
  /// **'Request paused'**
  String get requestPaused;

  /// No description provided for @editHeadersHint.
  ///
  /// In en, this message translates to:
  /// **'Edit headers as JSON...'**
  String get editHeadersHint;

  /// No description provided for @editBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Edit body content...'**
  String get editBodyHint;

  /// No description provided for @invalidJsonInHeaders.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON in headers'**
  String get invalidJsonInHeaders;

  /// No description provided for @rawJson.
  ///
  /// In en, this message translates to:
  /// **'Raw JSON'**
  String get rawJson;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @skipNoEdit.
  ///
  /// In en, this message translates to:
  /// **'Skip (No Edit)'**
  String get skipNoEdit;

  /// No description provided for @applyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Apply & Continue'**
  String get applyAndContinue;

  /// No description provided for @body.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get body;

  /// No description provided for @breakpointTypeAll.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get breakpointTypeAll;

  /// No description provided for @breakpointTypeRequest.
  ///
  /// In en, this message translates to:
  /// **'REQUEST'**
  String get breakpointTypeRequest;

  /// No description provided for @breakpointTypeResponse.
  ///
  /// In en, this message translates to:
  /// **'RESPONSE'**
  String get breakpointTypeResponse;

  /// No description provided for @requestCancelledByBreakpoint.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled by breakpoint'**
  String get requestCancelledByBreakpoint;

  /// No description provided for @cancelledByBreakpoint.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by breakpoint'**
  String get cancelledByBreakpoint;

  /// No description provided for @shareApiRequestDetails.
  ///
  /// In en, this message translates to:
  /// **'=== API Request Details ==='**
  String get shareApiRequestDetails;

  /// No description provided for @shareRequestHeaders.
  ///
  /// In en, this message translates to:
  /// **'--- Request Headers ---'**
  String get shareRequestHeaders;

  /// No description provided for @shareRequestBody.
  ///
  /// In en, this message translates to:
  /// **'--- Request Body ---'**
  String get shareRequestBody;

  /// No description provided for @shareResponseHeaders.
  ///
  /// In en, this message translates to:
  /// **'--- Response Headers ---'**
  String get shareResponseHeaders;

  /// No description provided for @shareResponseBody.
  ///
  /// In en, this message translates to:
  /// **'--- Response Body ---'**
  String get shareResponseBody;
}

class _NetworkMonitoringLocalizationsDelegate
    extends LocalizationsDelegate<NetworkMonitoringLocalizations> {
  const _NetworkMonitoringLocalizationsDelegate();

  @override
  Future<NetworkMonitoringLocalizations> load(Locale locale) {
    return SynchronousFuture<NetworkMonitoringLocalizations>(
      lookupNetworkMonitoringLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_NetworkMonitoringLocalizationsDelegate old) => false;
}

NetworkMonitoringLocalizations lookupNetworkMonitoringLocalizations(
  Locale locale,
) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return NetworkMonitoringLocalizationsAr();
    case 'en':
      return NetworkMonitoringLocalizationsEn();
  }

  throw FlutterError(
    'NetworkMonitoringLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
