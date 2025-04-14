import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/detect_device/detect_device.dart';
import 'package:idm_client/domain/device.dart';
import 'package:idm_client/presentation/home_page/widgets/device_info_widget.dart';
import 'package:idm_client/presentation/home_page/widgets/device_painter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:idm_client/presentation/home_page/widgets/device_buttons.dart';

///
/// The main widget of the [HomePage] body that controls the scanning.
class HomeBody extends StatefulWidget {
  ///
  /// Creates a new instanse of [HomeBody] with [key].
  const HomeBody({super.key});
  //
  //
  @override
  State<HomeBody> createState() => _HomeBodyState();
}

///
/// Status of the [HomeBody].
class _HomeBodyState extends State<HomeBody> {
  final _log = const Log("HomeBody");
  Device? _lastDetectedDevice;
  // bool values for init state
  bool _showFrame = false;
  bool _showAdditionalButtons = false;
  bool _showInfo = false;
  bool _showDoc = false;

  ///
  /// Creation of [MobileScannerController] for working with the camera and scanning QR codes.
  final MobileScannerController _cameraController = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 500,
    formats: [BarcodeFormat.all],
  );
  final DetectDevice _detectDevice = DetectDevice({});
  final Map<String, Device> _devices = {};
  //
  //
  @override
  void initState() {
    super.initState();
  }

  ///
  /// Building a camera view based on device [orientation].
  /// Returns the rotated camera widget.
  Widget _buildCameraView(NativeDeviceOrientation orientation) {
    int turns = 0; // 1 turn = 90 degrees
    switch (orientation) {
      case NativeDeviceOrientation.portraitUp:
        turns = 0;
        break;
      case NativeDeviceOrientation.landscapeRight:
        turns = 1;
        break;
      case NativeDeviceOrientation.portraitDown:
        turns = 2;
        break;
      case NativeDeviceOrientation.landscapeLeft:
        turns = 3;
        break;
      default:
        turns = 0;
    }
    return RotatedBox(
      quarterTurns: turns,
      child: MobileScanner(
        controller: _cameraController,
        onDetect: (barcodes) {
          _detectDevice.add(barcodes);
        },
        onDetectError: (error, stackTrace) {
          _log.warn('.MobileScanner.onError | error: $error');
        },
      ),
    );
  }

  //
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: NativeDeviceOrientationReader(builder: (context) {
      NativeDeviceOrientation orientation =
          NativeDeviceOrientationReader.orientation(context);
      return Stack(
        children: [
          _buildCameraView(orientation),
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return StreamBuilder<Device?>(
                stream: _detectDevice.stream,
                builder:
                    (BuildContext context, AsyncSnapshot<Device?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: Stack(
                      children: [
                        CircularProgressIndicator(
                          color: Color.fromARGB(255, 102, 163, 210),
                        ),
                      ],
                    ));
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    _showFrame = false;
                  }
                  if (snapshot.hasError) {
                    _log.warn('.StreamBuilder | Error: ${snapshot.error}');
                  }
                  if (snapshot.hasData) {
                    _updateDevices(snapshot);
                  }
                  return Stack(
                    children: [
                      if (_showFrame && _devices.isNotEmpty)
                        CustomPaint(
                          size:
                              Size(constraints.maxWidth, constraints.maxHeight),
                          painter: DeviceFramePainter(
                              _cameraController.value.size,
                              _devices.values.toList(),
                              orientation),
                          foregroundPainter: DeviceBarPainter(
                              _cameraController.value.size,
                              _devices.values.toList(),
                              orientation,
                              _devices.values.first.id),
                        ),
                      if (_lastDetectedDevice != null)
                        CustomPaint(
                          size:
                              Size(constraints.maxWidth, constraints.maxHeight),
                          painter: DeviceBarPainter(
                              _cameraController.value.size,
                              _devices.values.toList(),
                              orientation,
                              _devices.values.first.id),
                        ),
                      DeviceButtons(
                          showAdditionalButtons: _showAdditionalButtons,
                          onPlusPressed: () => setState(() {
                                _showAdditionalButtons =
                                    !_showAdditionalButtons;
                              }),
                          onInfoPressed: () => setState(() {
                                _showInfo = !_showInfo;
                                _showDoc = false;
                              }),
                          onDocPressed: () => setState(() {
                                _showDoc = !_showDoc;
                                _showInfo = false;
                        }),
                      ),
                      if (_showInfo && _devices.isNotEmpty) ...[
                        DeviceInfoWidget(
                          devId: _devices.values.first.id,
                          onClosePressed: () => setState(() {
                            _showInfo = false;
                          }),
                        )
                      ],
                      if (_showDoc) ...[loadDoc()],
                    ],
                  );
                });
          }),
        ],
      );
    }));
  }
  ///
  /// Loading and displaying the documentation window.
  Widget loadDoc() {
    return Positioned(
      top: 100,
      left: 100,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'I am doc',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  ///
  /// Write barcode information into list of [Device]'s.
  void _updateDevices(AsyncSnapshot<Device?> snapshot) {
    final device = snapshot.data;
    if (device != null) {
      _showFrame = true;
      if (_devices.containsKey(device.id)) {
        _devices[device.id]?.updateSameQR(device.pos, device.size);
      } else {
        _devices[device.id] = device;
      }
      _lastDetectedDevice = device;
    }
    _devices.removeWhere((key, Device dev) {
      return !dev.isActual;
    });
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
