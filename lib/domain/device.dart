import 'dart:async';
import 'dart:ui';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/pos.dart';
///
/// Overview info about [Device].
/// Controls the lifetime of the device ts position on the screen.
class Device {
  static const _log = Log("Device");
  final String id;
  final String title;
  final String details;
  Pos pos;
  Size size;
  bool _isActual = true;
  final void Function()? onExpire;
  Timer? t;
  final Duration _timeout;
  ///
  ///
  /// Creates a new instanse of [Device] with:
  /// [id] - unique identifier
  /// [title] - displayed name
  /// [pos] - initial position on the screen
  /// [size] - initial size
  /// [details] -  additional information
  /// [timeout] - living time, after it device will be deleted, default 500ms
  /// [onExpire] - callback when time expires
  Device({
    required this.id,
    required this.title,
    required this.pos,
    required this.size,
    required this.details,
    Duration timeout = const Duration(milliseconds: 500),
    this.onExpire,
  }) : _timeout = timeout;

  ///
  /// Starts/restarts the device life [Timer].
  void _startTimer() {
    t?.cancel();
    t = Timer(_timeout, () {
      _isActual = false;
      _log.warn('Timer expired for device: $id');
      onExpire?.call();
    });
  }
  ///
  /// Updating the position and size for the same QR code.
  void updateSameQR(Pos newPos, Size newSize) {
    pos = newPos;
    size = newSize;
    _isActual = true;
    _startTimer();
  }
  ///
  /// - Returns true antil it must live
  /// - Returns false when it must be deleted
  bool get isActual => _isActual;
}
