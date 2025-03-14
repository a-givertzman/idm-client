import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/detect_device/detect_device.dart';
import 'package:idm_client/domain/device.dart';
import 'package:idm_client/presentation/home_page/widgets/device_pinter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
///
/// The body of the HomePage
class HomeBody extends StatefulWidget {
  const HomeBody({super.key});
  //
  //
  @override
  State<HomeBody> createState() => _HomeBodyState();
}
//
//
class _HomeBodyState extends State<HomeBody> {
  final _log = const Log("HomeBody");
  final MobileScannerController _cameraController = MobileScannerController(
    detectionTimeoutMs: 1000,
    formats: [BarcodeFormat.all],
  );
  final DetectDevice _detectDevice = DetectDevice({});
  final Map<String, Device> _devices = {};
  // Size? _cameraResolution;
  //
  //
  @override
  void initState() {
    super.initState();
  }
  //
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: (barcodes) {
              // _log.warn('.MobileScanner.onDetect | barcodes: $barcodes');
              _detectDevice.add(barcodes);
            },
            onDetectError: (error, stackTrace) {
              _log.warn('.MobileScanner.onError | error: $error');
            },
          ),
          Positioned(
            top: 100,
            left: 100,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 5, color: Colors.deepOrange)
              ),
              child: Text('This is a Text widget', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.amber)),
            )
          ),
          LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            return StreamBuilder(
              stream: _detectDevice.stream,
              builder: (BuildContext context, AsyncSnapshot<Device> snapshot) {
                // _log.warn('.StreamBuilder | snapshot: $snapshot');
                if (snapshot.hasError) {
                  _log.warn('.StreamBuilder | Error: ${snapshot.error}');
                }
                // _log.warn('.StreamBuilder | Data: ${snapshot.data}');
                _updateDevices(snapshot);
                final devWidget = CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: DevicePainter(
                    _cameraController.cameraResolution,
                    _devices.values.toList(),
                  )
                );
                _devices.clear();
                return devWidget;
              }
            );
          })
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
