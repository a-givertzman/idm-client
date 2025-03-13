import 'dart:async';

import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/device.dart';
import 'package:idm_client/domain/pos.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

///
/// TODO: To be added
class DetectDevice {
  final _log = const Log("DetectDevice");
  final StreamController<Device> _controller = StreamController();
  final Map<String, String> _details;
  ///
  /// Returns stream of detected [Device]'s
  /// - use `add()` method to pass frames to be scanned for [Device]'s barcodes
  DetectDevice(
    Map<String, String>? deviceDetails,
  ):
    _details = deviceDetails ?? {};

  ///
  /// Add new image for detection
  void add(BarcodeCapture event) {
    _log.warn('.add | Barcodes: ${event.barcodes}');
    for (Barcode barcode in event.barcodes) {
      _log.warn('.add | Barcode: $barcode');
      _log.warn('.add | Barcode.type: ${barcode.type}');
      switch (barcode.type) {
        case BarcodeType.url:
          final id = barcode.url?.url;
          final title = barcode.url?.title ?? 'Undefined device';
          final details = _details[id] ?? barcode.displayValue ?? '---';
          if (id != null) {
            _controller.add(Device(
              id: id,
              title: title,
              pos: Pos(
                barcode.corners.first.dx,
                barcode.corners.first.dy,
              ),
              size: barcode.size,
              details: details
            ));
          } else {
            _log.warn('.add | Unknown bar-code: $barcode');
          }
          break;
        default:
          _log.warn('.add | Unknown bar-code type: ${barcode.type}');
      }
    }
  }

  ///
  /// Detected devices
  Stream<Device> get stream {
    return _controller.stream;
  }
  ///
  /// Clear resources
  Future close() {
    return _controller.close();
  }
}
