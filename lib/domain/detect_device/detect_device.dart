import 'dart:async';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/device.dart';
import 'package:idm_client/domain/pos.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
///
/// Device detection by QR code.
/// Processes camera frames, recognizes qr codes and creates devices.
class DetectDevice {
  final _log = const Log("DetectDevice");
  final StreamController<Device?> _controller = StreamController.broadcast();
  final Map<String, String> _details;
  ///
  /// Creates a new instance of [DetectDevice] with [deviceDetails] that could be null.
  /// Returns stream of detected [Device]'s.
  DetectDevice(
    Map<String, String>? deviceDetails,
  ) : _details = deviceDetails ?? {};

  ///
  /// Add new [event] for detection.
  void add(BarcodeCapture event) {
    for (Barcode barcode in event.barcodes) {
      _log.warn(
          '.add | Barcode: type: ${barcode.type}, url: ${barcode.url?.url}');
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
              details: details,
              timeout: const Duration(milliseconds: 500),
              onExpire: () => addEmpty(),
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

  /// Stream of detected devices.
  /// Returns [Device] when detected, or null when time expires.
  Stream<Device?> get stream {
    return _controller.stream;
  }
  ///
  /// Sends null to the thread to process the device disappearing.
  void addEmpty() {
    if (!_controller.isClosed) {
      _log.warn('DetectDevice.addEmpty() called - Sending null');
      _controller.add(null);
    }
  }

  ///
  /// Clear resources.
  Future close() {
    return _controller.close();
  }
}
