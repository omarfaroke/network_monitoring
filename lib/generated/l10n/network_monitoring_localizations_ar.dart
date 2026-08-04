// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'network_monitoring_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class NetworkMonitoringLocalizationsAr extends NetworkMonitoringLocalizations {
  NetworkMonitoringLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get networkMonitor => 'مراقب الشبكة';

  @override
  String get resumeAllRequests => 'استئناف جميع الطلبات';

  @override
  String get pauseAllRequests => 'إيقاف جميع الطلبات مؤقتًا';

  @override
  String get more => 'المزيد';

  @override
  String get addBreakpoint => 'إضافة نقطة توقف';

  @override
  String get appliedBreakpoints => 'نقاط التوقف المطبقة';

  @override
  String get devModeOptions => 'خيارات وضع المطور';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get clearAllRecordsTitle => 'مسح جميع السجلات؟';

  @override
  String get clearAllRecordsMessage =>
      'سيؤدي هذا إلى إزالة جميع طلبات HTTP الملتقطة من القائمة.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get addAction => 'إضافة';

  @override
  String get clear => 'مسح';

  @override
  String get urlCopied => 'تم نسخ الرابط';

  @override
  String breakpointRemovedFor(Object path) {
    return 'تمت إزالة نقطة التوقف لـ $path';
  }

  @override
  String breakpointAddedFor(Object path) {
    return 'تمت إضافة نقطة التوقف لـ $path';
  }

  @override
  String pausedCount(Object count) {
    return '$count متوقف';
  }

  @override
  String requestsPaused(Object count) {
    return '$count طلب(ات) متوقف';
  }

  @override
  String get continueAll => 'متابعة الكل';

  @override
  String get searchHint => 'البحث في الطلبات...';

  @override
  String get searchScopes => 'البحث في';

  @override
  String get searchScopeUrl => 'الرابط';

  @override
  String get searchScopeStatus => 'الحالة';

  @override
  String get searchScopeHeaders => 'الرؤوس';

  @override
  String get searchScopeQuery => 'الاستعلام';

  @override
  String get searchScopeRequest => 'الطلب';

  @override
  String get searchScopeResponse => 'الاستجابة';

  @override
  String get searchScopeAll => 'كل الحقول';

  @override
  String get searchScopeReset => 'إعادة تعيين';

  @override
  String get searchScopeCurrentTab => 'التبويب الحالي';

  @override
  String get searchScopeAllTabs => 'كل التبويبات';

  @override
  String get searchInDetails => 'بحث في التفاصيل';

  @override
  String get searchInDetailsHint => 'البحث في الطلب / الاستجابة...';

  @override
  String searchMatchesCount(int count) {
    return '$count نتيجة';
  }

  @override
  String searchMatchOf(int current, int total) {
    return '$current - $total';
  }

  @override
  String get searchNoMatches => 'لا توجد نتائج';

  @override
  String get searchPrevious => 'المطابقة السابقة';

  @override
  String get searchNext => 'المطابقة التالية';

  @override
  String get filterAll => 'الكل';

  @override
  String get noHttpRequestsRecorded => 'لا توجد طلبات HTTP مسجلة';

  @override
  String get requestsWillAppearWhenActive =>
      'ستظهر الطلبات هنا عند تفعيل المراقبة';

  @override
  String get removeBreakpoint => 'إزالة نقطة التوقف';

  @override
  String get addBreakpointTooltip => 'إضافة نقطة توقف';

  @override
  String get noBreakpointsConfigured => 'لا توجد نقاط توقف مُعدّة';

  @override
  String get allEndpoints => 'جميع النقاط النهائية';

  @override
  String get unknown => 'غير معروف';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get removeBreakpointThisEndpoint =>
      'إزالة نقطة التوقف (هذه النقطة النهائية)';

  @override
  String get addBreakpointThisEndpoint =>
      'إضافة نقطة توقف (هذه النقطة النهائية)';

  @override
  String get addBreakpointCustom => 'إضافة نقطة توقف (مخصص)...';

  @override
  String get copyUrl => 'نسخ الرابط';

  @override
  String get cancelled => 'ملغى';

  @override
  String get allRequestsPausedHint =>
      'جميع الطلبات متوقفة مؤقتًا. اضغط على استئناف لمتابعة إرسال البيانات.';

  @override
  String get allEndpointsBreakpointActiveHint =>
      'نقطة توقف نشطة لجميع النقاط النهائية. سيتم إيقاف الطلبات المطابقة مؤقتًا.';

  @override
  String get target => 'الهدف';

  @override
  String get specificEndpoint => 'نقطة نهائية محددة';

  @override
  String get endpointPatternHint => 'مثال: /api/login أو /users';

  @override
  String get breakOn => 'التوقف عند';

  @override
  String get bothRequestAndResponse => 'الطلب والاستجابة معًا';

  @override
  String get requestOnly => 'الطلب فقط';

  @override
  String get responseOnly => 'الاستجابة فقط';

  @override
  String get enableDevMode => 'تفعيل وضع المطور';

  @override
  String get enterDevModePassword => 'أدخل كلمة المرور لتفعيل وضع المطور';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enable => 'تفعيل';

  @override
  String get incorrectPassword => 'كلمة مرور غير صحيحة';

  @override
  String get validationFailed => 'فشل التحقق';

  @override
  String get httpMonitoring => 'مراقبة HTTP';

  @override
  String get httpMonitoringDescription =>
      'راقب جميع طلبات واستجابات HTTP في الوقت الفعلي. يعرض زرًا عائمًا للوصول السريع.';

  @override
  String get monitoringHttp => 'مراقبة HTTP';

  @override
  String get showFloatingButton => 'إظهار الزر العائم';

  @override
  String get remoteMonitor => 'المراقبة عن بُعد';

  @override
  String get remoteMonitorDescription =>
      'تشغيل خادم ويب محلي لفتح شاشة مراقبة الشبكة في متصفح جهاز آخر على نفس الشبكة.';

  @override
  String get remoteMonitorEnabled => 'تفعيل المراقبة عن بُعد';

  @override
  String get remoteMonitorUrl => 'افتح في المتصفح';

  @override
  String get remoteMonitorUrlCopied => 'تم نسخ رابط المراقبة عن بُعد';

  @override
  String get remoteMonitorStarting => 'جاري تشغيل المراقبة عن بُعد…';

  @override
  String get remoteMonitorFailed => 'تعذر تشغيل المراقبة عن بُعد';

  @override
  String get breakpoints => 'نقاط التوقف';

  @override
  String get noBreakpointsConfiguredDevMode =>
      'لا توجد نقاط توقف. أضف نقاط توقف من شاشة المراقبة.';

  @override
  String get disableDevMode => 'تعطيل وضع المطور';

  @override
  String get copyRequestHeaders => 'نسخ رؤوس الطلب';

  @override
  String get copyRequestBody => 'نسخ محتوى الطلب';

  @override
  String get copyResponseBody => 'نسخ محتوى الاستجابة';

  @override
  String get copyAuthToken => 'نسخ رمز المصادقة';

  @override
  String get shareAllDetails => 'مشاركة جميع التفاصيل';

  @override
  String get copiedToClipboard => 'تم النسخ إلى الحافظة';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get request => 'الطلب';

  @override
  String get response => 'الاستجابة';

  @override
  String get headers => 'الرؤوس';

  @override
  String get size => 'الحجم';

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
  String get general => 'عام';

  @override
  String get url => 'الرابط';

  @override
  String get method => 'الطريقة';

  @override
  String get status => 'الحالة';

  @override
  String get duration => 'المدة';

  @override
  String get startTime => 'وقت البدء';

  @override
  String get endTime => 'وقت الانتهاء';

  @override
  String get error => 'خطأ';

  @override
  String get message => 'الرسالة';

  @override
  String get authentication => 'المصادقة';

  @override
  String get token => 'الرمز';

  @override
  String get jwtHeader => 'رأس JWT';

  @override
  String get jwtPayload => 'حمولة JWT';

  @override
  String get expiresAt => 'تنتهي في';

  @override
  String get issuedAt => 'صدرت في';

  @override
  String get copyJwtPayload => 'نسخ حمولة JWT';

  @override
  String get jwtDecode => 'فك JWT';

  @override
  String get jwtNotJwtHint =>
      'رمز المصادقة هذا ليس JWT. الصيغة المتوقعة: Bearer token بصيغة header.payload.signature.';

  @override
  String get jwtDecodeFailedHint =>
      'يبدو أن هذا الرمز JWT لكن تعذر فك رأس الرمز أو حمولته.';

  @override
  String get queryParameters => 'معلمات الاستعلام';

  @override
  String get requestBody => 'محتوى الطلب';

  @override
  String get responseBody => 'محتوى الاستجابة';

  @override
  String get requestHeaders => 'رؤوس الطلب';

  @override
  String get responseHeaders => 'رؤوس الاستجابة';

  @override
  String get noRequestBody => 'لا يوجد محتوى للطلب';

  @override
  String get noResponseBody => 'لا يوجد محتوى للاستجابة';

  @override
  String get noResponseHeaders => 'لا توجد رؤوس للاستجابة';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String copiedLabel(Object label) {
    return 'تم نسخ $label';
  }

  @override
  String copiedTitle(Object title) {
    return 'تم نسخ $title';
  }

  @override
  String copiedItem(Object index) {
    return 'تم نسخ العنصر [$index]';
  }

  @override
  String copiedKey(Object key) {
    return 'تم نسخ \"$key\"';
  }

  @override
  String copiedKeyBracket(Object key) {
    return 'تم نسخ [$key]';
  }

  @override
  String get editRequest => 'تعديل الطلب';

  @override
  String get editResponse => 'تعديل الاستجابة';

  @override
  String get continueAction => 'متابعة';

  @override
  String get responsePaused => 'الاستجابة متوقفة';

  @override
  String get requestPaused => 'الطلب متوقف';

  @override
  String get editHeadersHint => 'تعديل الرؤوس كـ JSON...';

  @override
  String get editBodyHint => 'تعديل محتوى الطلب...';

  @override
  String get invalidJsonInHeaders => 'JSON غير صالح في الرؤوس';

  @override
  String get rawJson => 'JSON خام';

  @override
  String get table => 'جدول';

  @override
  String get skipNoEdit => 'تخطي (بدون تعديل)';

  @override
  String get applyAndContinue => 'تطبيق ومتابعة';

  @override
  String get body => 'المحتوى';

  @override
  String get breakpointTypeAll => 'الكل';

  @override
  String get breakpointTypeRequest => 'طلب';

  @override
  String get breakpointTypeResponse => 'استجابة';

  @override
  String get requestCancelledByBreakpoint =>
      'تم إلغاء الطلب بواسطة نقطة التوقف';

  @override
  String get cancelledByBreakpoint => 'تم الإلغاء بواسطة نقطة التوقف';

  @override
  String get shareApiRequestDetails => '=== تفاصيل طلب API ===';

  @override
  String get shareRequestHeaders => '--- رؤوس الطلب ---';

  @override
  String get shareRequestBody => '--- محتوى الطلب ---';

  @override
  String get shareResponseHeaders => '--- رؤوس الاستجابة ---';

  @override
  String get shareResponseBody => '--- محتوى الاستجابة ---';
}
