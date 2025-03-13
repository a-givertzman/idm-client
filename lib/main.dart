import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:idm_client/presentation/app_widget.dart';
//
//
late List<CameraDescription> cameras;
///
/// Pplication entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(AppWidget(cameras: cameras));
}
