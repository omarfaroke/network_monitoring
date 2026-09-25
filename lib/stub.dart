/// No-op entry point for builds that must not link the monitoring implementation.
///
/// Import `package:network_monitoring/stub.dart` instead of
/// `package:network_monitoring/network_monitoring.dart` so the full library
/// is absent from the import graph and can be tree-shaken from release
/// binaries.
///
/// The host app is responsible for selecting this entry (or the full one)
/// at compile time — for example via a flavor, env file, or build script.
library;

export 'src/stub/stub.dart';
