import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:idm_client/presentation/home_page/home_page.dart';

///
/// TODO: To be added
class DetectDevice {
  final StreamController<Device> _controller = StreamController();
  bool _exit = false;
  // TODO: to be deleted
  int _count = 0;

  ///
  /// TODO: To be added
  DetectDevice();

  ///
  /// Add new image for detection
  void add(CameraImage image) {
    _count++;
    const x = 30.0;
    final y = _count * 2.0;
    _controller.add(Device(
      id: '01',
      name: 'Device.Detected',
      pos: Pos(x, y),
    ));
    if (_count > 100) {
      _count = 0;
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
    _exit = true;
    return _controller.close();
  }
}
