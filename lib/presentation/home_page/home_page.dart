import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
  State<HomePage> createState() => _MyHomePageState();
}
//
//
class _MyHomePageState extends State<HomePage> {
  late CameraController _cameraController;
  final DetectDevice _detectDevice = DetectDevice();
  final Map<String, Device> _devices = {};
  // late MobileScannerController _controller;
  Size? _cameraResolution;
  Rect? _qrRect;
  Size? _screenSize;
  String? _qrData;

  @override
  void initState() {
    super.initState();
    // _controller = MobileScannerController(
    //     detectionSpeed: DetectionSpeed.normal,
    //     //facing: CameraFacing.back,
    //     torchEnabled: false,
    //     //cameraResolution: Size(2000, 2000)
    //     );

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    await _cameraController.initialize();

    if (mounted) {
      setState(() {
        _cameraResolution = Size(
          _cameraController.value.previewSize!.width,
          _cameraController.value.previewSize!.height,
        );
      });
    }

    // _controller = MobileScannerController();
    // await _controller!.start();
  }
  //
  //
  @override
  void dispose() async {
    //await _detectDevice.close();
    // _controller.dispose();
    _cameraController.dispose();
    super.dispose();
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
          // MobileScanner(
          //   controller: _controller,
          //   onDetect: _handleDetect,
          // ),
          StreamBuilder(
            stream: _detectDevice.stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return Stack(
                children: _devices.entries.map((entry) {
                  final id = entry.key;
                  final device = entry.value;
                  return Positioned(
                    left: device.pos.x,
                    top: device.pos.y,
                    child: ListTile(
                      title: Text('${device.id}: ${device.name}'),
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
