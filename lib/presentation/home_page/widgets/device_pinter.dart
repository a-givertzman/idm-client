import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/device.dart';

///
///
class DevicePainter extends CustomPainter {
  final _log = const Log("DevicePainter");
  final Size? _cameraResolution;
  final List<Device> _devices;
  ///
  ///
  DevicePainter(
    Size? cameraResolution,
    List<Device> devices,
  ):
    _cameraResolution = cameraResolution,
    _devices = devices;
  //
  //
  @override
  void paint(Canvas canvas, Size size) {
    final cameraResolution = _cameraResolution;
    _log.warn('.StreamBuilder | cameraResolution: ${cameraResolution}');
    if (cameraResolution != null) {
      final xScale = cameraResolution.width / size.width ;
      final yScale = cameraResolution.height / size.height;
      for (final dev in _devices) {
        _log.warn('.StreamBuilder | Device Pos(${dev.pos.x}, ${dev.pos.y})  size: ${dev.size}');
        final Rect rect = Rect.fromPoints(
          Offset(dev.pos.x * xScale, dev.pos.y * yScale),
          Offset((dev.pos.x + dev.size.width) * xScale, (dev.pos.y + dev.size.width) * yScale),
        );
        canvas.drawRect(
          rect,
          // Paint()..shader = gradient.createShader(rect),
          Paint()
            ..style=PaintingStyle.stroke
            ..color = Colors.blueAccent
            ..strokeWidth = 3.0
        );
        //         title: Text('${device.id}: ${device.title}'),
        //         subtitle: Text(device.details),

      }
    }
  }
  //
  //
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}