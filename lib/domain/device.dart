import 'dart:async';
import 'dart:ui';

import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/pos.dart';

///
/// Overview info about Device
/// - has a living timeout
class Device {
  static const _log = Log("Device");
  static final Finalizer<Timer> _finalizer = Finalizer((t) {
    t.cancel();
    _log.warn('.Finalizer | Timer canceled');
  });
  final String id;
  final String title;
  final String details;
  final Pos pos;
  final Size size;
  bool _isActual = true;
  ///
  /// Overview info about Device
  /// - [timeout] - living time, after it device will be deleted, default 1000ms
  Device({
    required this.id,
    required this.title,
    required this.pos,
    required this.size,
    required this.details,
    Duration timeout = const Duration(milliseconds: 1000),
  }) {
    final t = Timer(
      timeout,
      () {
        _isActual = false;
      }
    );
    _finalizer.attach(t, t);
  }
  ///
  /// - Returns true antil it must live
  /// - Returns false when it must be deleted
  bool get isActual => _isActual;
}

