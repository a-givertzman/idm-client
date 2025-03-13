import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/detect_device/detect_device.dart';
import 'package:idm_client/domain/device.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
  final MobileScannerController _cameraController = MobileScannerController(
    detectionTimeoutMs: 1000,
    formats: [BarcodeFormat.all],
  );
  final DetectDevice _detectDevice = DetectDevice({});
  final Map<String, Device> _devices = {};
  Size? _cameraResolution;
  //
  //
  @override
  void initState() {
    super.initState();
    // _cameraController.barcodes.listen((BarcodeCapture barcodes) {
    //   _log.warn('.initState | barcodes: $barcodes');
    //   _detectDevice.add(barcodes);
    // });
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
              _log.warn('.MobileScanner.onDetect | barcodes: $barcodes');
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
          StreamBuilder(
            stream: _detectDevice.stream,
            builder: (BuildContext context, AsyncSnapshot<Device> snapshot) {
              // _log.warn('.StreamBuilder | snapshot: $snapshot');
              _log.warn('.StreamBuilder | Data: ${snapshot.data}');
              _log.warn('.StreamBuilder | Error: ${snapshot.error}');
              _updateDevices(snapshot);
              return Stack(
                children: _devices.values.map((device) {
                  _log.warn('.StreamBuilder | Device x: ${device.pos.x}  y: ${device.pos.y}');
                  return Positioned(
                    left: device.pos.x,
                    top: device.pos.y,
                    child: ListTile(
                      title: Text('${device.id}: ${device.title}'),
                      subtitle: Text(device.details),
                    ),
                  );
                }).toList(),
                // children: [
                //   Positioned(
                //     top: 200,
                //     left: 100,
                //     child: Container(
                //       decoration: BoxDecoration(
                //         border: Border.all(width: 5, color: Colors.deepOrange)
                //       ),
                //       child: Text('This is a Text widget', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.amber)),
                //     )
                //   )
                // ]
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
