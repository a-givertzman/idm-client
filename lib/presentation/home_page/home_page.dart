//import 'package:camera/camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:idm_client/domain/detect_device/detect_device.dart';
import 'package:idm_client/main.dart';
//import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
//import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

///
/// Home Page
class HomePage extends StatefulWidget {
  HomePage({super.key, required this.cameras});
  //final String title;
  late List<CameraDescription> cameras;
  //
  //
  @override
  State<HomePage> createState() => _MyHomePageState();
}

class Pos {
  final double x;
  final double y;
  const Pos(this.x, this.y);
}

///
/// Overview info about Device
class Device {
  final String id;
  final String name;
  final Pos pos;
  const Device({
    required this.id,
    required this.name,
    required this.pos,
  });
}

//
//
class _MyHomePageState extends State<HomePage> {
  late CameraController _cameraController;
  //final DetectDevice _detectDevice = DetectDevice();
  final List<Device> _devices = [];
  late MobileScannerController _controller;
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

    await _cameraController!.initialize();

    if (mounted) {
      setState(() {
        _cameraResolution = Size(
          _cameraController!.value.previewSize!.width,
          _cameraController!.value.previewSize!.height,
        );
      });
    }

    _controller = MobileScannerController();
    await _controller!.start();
  }
  //
  //
  // @override
  // initState() {
  //   initCamera();
  //   super.initState();
  // }

  //
  //
  // Future<void> initCamera() async {
  //   _controller = CameraController(cameras[0], ResolutionPreset.max);
  //   return _controller.initialize().then((_) {
  //     _controller.startImageStream((CameraImage image) {
  //       _detectDevice.add(image);
  //     });
  //     if (!mounted) {
  //       return;
  //     }
  //     setState(() {});
  //   });
  // }

  //
  //
  @override
  void dispose() async {
    //await _detectDevice.close();
    _controller.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  void _handleDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    final Size screenSize = MediaQuery.of(context).size;

    for (final barcode in barcodes) {
      final String? qrCode = barcode.rawValue;
      if (qrCode != null) {
        if (barcode.corners != null && barcode.corners!.isNotEmpty) {
          final List<Offset> corners = barcode.corners!;

          // Получаем разрешение камеры
          final double imageWidth = _cameraResolution!.width;
          final double imageHeight = _cameraResolution!.height;

          // Учитываем ориентацию камеры
          final bool isPortrait = screenSize.height > screenSize.width;
          final double scaleX = isPortrait
              ? screenSize.width / imageHeight
              : screenSize.width / imageWidth;
          final double scaleY = isPortrait
              ? screenSize.height / imageWidth
              : screenSize.height / imageHeight;

          // Преобразуем координаты углов в экранные координаты
          final double left =
              corners.map((point) => point.dx).reduce((a, b) => a < b ? a : b);
          final double top =
              corners.map((point) => point.dy).reduce((a, b) => a < b ? a : b);
          final double right =
              corners.map((point) => point.dx).reduce((a, b) => a > b ? a : b);
          final double bottom =
              corners.map((point) => point.dy).reduce((a, b) => a > b ? a : b);

          setState(() {
            _qrRect = Rect.fromLTRB(
              left * scaleX,
              top * scaleY,
              right * scaleX,
              bottom * scaleY,
            );
            _qrData = qrCode;
          });
        }

        // setState(() {
        //   _devices.clear();
        //   _devices.add(Device(
        //     id: qrCode,
        //     name: "Device $qrCode",
        //     pos: Pos(0, 0),
        //   ));
        // });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraResolution == null || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetect,
          ),
          if (_qrRect != null)
            Positioned(
              left: _qrRect!.left,
              top: _qrRect!.top,
              child: Container(
                width: _qrRect!.width,
                height: _qrRect!.height,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 4),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.all(16),
              child: Text(
                _qrData ?? "Scan a QR code",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // DeviceNamewWidget(devices: _devices),
        ],
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   if (!_controller.value.isInitialized) {
  //     return Container();
  //   } else {
  //     return Scaffold(
  //       body: Stack(
  //         fit: StackFit.expand,
  //         children: [
  //           MobileScanner(
  //             controller: _controller,
  //             onDetect: _handleDetect,
  //           ),
  //           //CameraPreview(_controller),
  //           //DeviceOverviewWidget(detectDevice: _detectDevice),
  //         ],
  //       ),
  //     );
  //   }
  // }
}

class QrBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DeviceNamewWidget extends StatelessWidget {
  const DeviceNamewWidget({super.key, required this.devices});

  final List<Device> devices;

  @override
  Widget build(BuildContext context) {
    final String deviceName =
        devices.isNotEmpty ? devices.last.name : "No device detected";
    return Positioned(
        left: 10,
        bottom: 10,
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 0.1,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              color: Colors.black,
            ),
            child: Row(
              children: [
                Text(
                  'detected name: ${deviceName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                )
              ],
            )));
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
                child: Column(
                  children: [
                    Text(event.name),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('Info'),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Doc'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}
