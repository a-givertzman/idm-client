import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/device.dart';

///
///
class DevicePainter extends CustomPainter {
  final _log = const Log("DevicePainter");
  final Size _cameraSize;
  final List<Device> _devices;
  ///
  ///
  DevicePainter(
    Size cameraResolution,
    List<Device> devices,
  ):
    _cameraSize = cameraResolution,
    _devices = devices;
  //
  //
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..style=PaintingStyle.stroke
        ..color = Colors.deepOrange
        ..strokeWidth = 3.0
    );
    // _log.warn('.StreamBuilder | cameraSize: $cameraSize');
    // _log.warn('.StreamBuilder | canvasSize: $size');
    final xScale = size.width / _cameraSize.width ;
    final yScale = size.height / _cameraSize.height;
    // _log.warn('.StreamBuilder | xScale: $xScale, yScale: $yScale');
    for (final dev in _devices) {
      final x = dev.pos.x * xScale;
      final y = dev.pos.y * yScale;
      final width = dev.size.width * xScale;
      final heigh = dev.size.height * yScale;
      // _log.warn('.StreamBuilder | Device Pos($x, $y)  size: ($width, $heigh)');
      final Rect rect = Offset(x, y) & Size(width, heigh);
      canvas.drawRect(
        rect,
        Paint()
          ..style=PaintingStyle.stroke
          ..color = Colors.blueAccent
          ..strokeWidth = 3.0
      );
      paintText(canvas, '${dev.id}: ${dev.title}', x, y + heigh, 200);
      paintText(canvas, dev.details, x, y + heigh + 16, 200);
    }
  }
  void paintText(Canvas canvas, String text, double x, double y, double width) {
      const textStyle = TextStyle(
        color: Colors.blueAccent,
        fontSize: 16,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: width,
      );
      textPainter.paint(canvas, Offset(x, y));
  }
  //
  //
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}