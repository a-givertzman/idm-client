import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/presentation/app_widget.dart';
///
/// Application entry point.
void main() async {
  Log.initialize(
    level: switch(kDebugMode) {
      true => LogLevel.debug,
      false => LogLevel.info,
    },
  );
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppWidget());
}
