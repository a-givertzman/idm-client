import 'dart:async';
import 'dart:ui';

import 'package:idm_client/domain/pos.dart';

///
/// Overview info about Device
/// - has a living timeout
class Device {
  final String id;
  final String title;
  final String details;
  final Pos pos;
  final Size size;
  bool _isActual = true;
  ///
  /// Overview info about Device
  Device({
    required this.id,
    required this.title,
    required this.pos,
    required this.size,
    required this.details,
  }) {
    Timer? t;
    t = Timer(
      const Duration(milliseconds: 1000),
      () {
        _isActual = false;
        t?.cancel();        
      }
    );
  }
  ///
  /// - Returns true antil it must live
  /// - Returns false when it must be deleted
  bool get isActual => _isActual;
}

