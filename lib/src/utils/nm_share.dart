import 'package:flutter/material.dart';

import '../network_monitoring_registry.dart';

void nmShareContent(BuildContext context, String content) {
  NetworkMonitoringRegistry.config.shareContent(context, content);
}
