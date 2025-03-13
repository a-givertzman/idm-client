import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/detect_device/detect_device.dart';
import 'package:idm_client/domain/device.dart';
//import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
//import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

///
/// Home Page
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  //
  //
  @override
  State<HomePage> createState() => _HomePageState();
}
//
//
class _HomePageState extends State<HomePage> {
  final _log = const Log("HomePage");
  late CameraController _cameraController;
  final DetectDevice _detectDevice = DetectDevice({});
  final Map<String, Device> _devices = {};
  Size? _cameraResolution;
  Size? _screenSize;
  //
  //
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  ///
  /// Camera initialization
  /// 
  /// IMPORTENT !
  /// 
  /// If you are using the Camera plugin make sure to configure your
  /// CameraController to only use ImageFormatGroup.nv21 for Android
  /// and ImageFormatGroup.bgra8888 for iOS. [source](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/google_mlkit_commons#creating-an-inputimage).
  Future<void> _initializeCamera() async {
    _log.warn('._initializeCamera | Camera init for ${Platform.operatingSystem}...');
    final List<CameraDescription> cameras = await availableCameras();
    final firstCamera = cameras.first;
    _log.warn('._initializeCamera | Camera: ${firstCamera.name}');
    _cameraController = CameraController(
      fps: 1,
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
        ? ImageFormatGroup.nv21 // for Android
        : ImageFormatGroup.bgra8888, // for iOS
    );
    await _cameraController.initialize();
    _detectDevice.updateOrientation(
      firstCamera.sensorOrientation,
      firstCamera.lensDirection,
      _cameraController.value.deviceOrientation,
    );
    _cameraController.startImageStream((image) {
      // _log.warn('.imageStream | Image: $image');
      _detectDevice.add(image);
    });
    _log.warn('._initializeCamera | Done');
    if (mounted) {
      setState(() {
        _cameraResolution = Size(
          _cameraController.value.previewSize!.width,
          _cameraController.value.previewSize!.height,
        );
      });
    }
  }
  //
  //
  @override
  Widget build(BuildContext context) {
    if (_cameraResolution == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(
            _cameraController,
            child: Positioned(
              top: 100,
              left: 100,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 5, color: Colors.deepOrange)
                ),
                child: Text('This is a Text widget', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.amber)),
              )
            ),
          ),
          StreamBuilder(
            stream: _detectDevice.stream,
            builder: (BuildContext context, AsyncSnapshot<Device> snapshot) {
              _log.warn('._initializeCamera | snapshot: ${snapshot}');
              _updateDevices(snapshot);
              return Stack(
                fit: StackFit.expand,
                children: _devices.values.map((device) {
                  return Positioned(
                    left: device.pos.x,
                    top: device.pos.y,
                    child: ListTile(
                      title: Text('${device.id}: ${device.title}'),
                      subtitle: Text(device.details),
                      // width: _qrRect!.width,
                      // height: _qrRect!.height,
                      // decoration: BoxDecoration(
                      //   border: Border.all(color: Colors.green, width: 4),
                      // ),
                    ),
                  );
                }).toList(),
              );
            }
          ),
        ],
      ),
    );
  }
  ///
  /// Write barcode iformation into list of [Device]'s
  void _updateDevices(AsyncSnapshot<Device> snapshot) {
    final device = snapshot.data;
    if (device != null) {
      if (_devices.containsKey(device.id)) {
        _devices[device.id] = device;
      } else {
        _devices[device.id] = device;
      }
    }
  }
  //
  //
  @override
  void dispose() async {
    await _detectDevice.close();
    _cameraController.dispose();
    super.dispose();
  }
}
///
///
class DeviceOverviewWidget extends StatelessWidget {
  const DeviceOverviewWidget({
    super.key,
    required DetectDevice detectDevice,
  }) : _detectDevice = detectDevice;

  final DetectDevice _detectDevice;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _detectDevice.stream,
      builder: (BuildContext context, AsyncSnapshot<Device> snapshot) {
        if (snapshot.hasData) {
          final event = snapshot.data;
          if (event != null) {
            return Positioned(
              left: event.pos.x,
              top: event.pos.y,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  color: Colors.transparent,
                ),
              ),
            );
          }
        }
        return const Text('???');
      },
    );
  }
}












          // if (_qrRect != null)
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: 0,
          //   child: Container(
          //     color: Colors.black.withValues(alpha: 0.5),
          //     padding: const EdgeInsets.all(16),
          //     child: Text(
          //       _qrData ?? "Scan a QR code",
          //       style: const TextStyle(
          //         color: Colors.white,
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //       ),
          //       textAlign: TextAlign.center,
          //     ),
          //   ),
          // ),
