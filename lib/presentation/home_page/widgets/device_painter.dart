import 'package:flutter/material.dart';
import 'package:idm_client/domain/device.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
///
/// The base class for rendering devices on canvas.
class DevicePainter extends CustomPainter {
  final Size _cameraSize;
  final List<Device> _devices;
  final NativeDeviceOrientation orientation;
  ///
  /// Creates a new instanse of [DevicePainter] with given [cameraResolution], list of [devices] and current [orientation].
  DevicePainter(
    Size cameraResolution,
    List<Device> devices,
    this.orientation,
  )   : _cameraSize = cameraResolution,
        _devices = devices;
  //
  // Converts coordinates depending on the orientation of the device.
  Offset transformCoordinates(
      double x, double y, double width, double height, Size canvasSize) {
    switch (orientation) {
      case NativeDeviceOrientation.portraitDown:
        return Offset(
            canvasSize.width - x - width, canvasSize.height - y - height);

      case NativeDeviceOrientation.landscapeLeft:
        return Offset(y, canvasSize.height - x - height);

      case NativeDeviceOrientation.landscapeRight:
        return Offset(canvasSize.width - y - width, x);
      default:
        return Offset(x, y);
    }
  }

  //
  //
  @override
  void paint(Canvas canvas, Size size) {}
  //
  //
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

///
/// Drawing frames around detected devices.
class DeviceFramePainter extends DevicePainter {
  ///
  /// Creates a new instanse of [DeviceFramePainter] with given [cameraResolution], list of [devices] and current [orientation].
  DeviceFramePainter(super.cameraResolution, super.devices, super.orientation);
  //
  //
  @override
  void paint(Canvas canvas, Size size) {
    double curWidtg = size.width;
    double curHeight = size.height;
    if (orientation == NativeDeviceOrientation.landscapeLeft ||
        orientation == NativeDeviceOrientation.landscapeRight) {
      curWidtg = size.height;
      curHeight = size.width;
    }
    final xScale = curWidtg / _cameraSize.width;
    final yScale = curHeight / _cameraSize.height;
    for (final dev in _devices) {
      final x = dev.pos.x * xScale;
      final y = dev.pos.y * yScale;
      final width = dev.size.width * xScale;
      final height = dev.size.height * yScale;
      final Offset newPos = transformCoordinates(x, y, width, height, size);
      final Rect rect = newPos & Size(width, height);
      canvas.drawRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = const Color.fromARGB(255, 37, 86, 123)
            ..strokeWidth = 3.0);
    }
  }
}
///
/// Drawing information panel of the detected device.
class DeviceBarPainter extends DevicePainter {
  ///
  /// Creates a new instanse of [DeviceBarPainter] with given [cameraResolution], list of [devices], current [orientation] and [text] of QR code.
  DeviceBarPainter(
      super.cameraResolution, super.devices, super.orientation, this.text);
  String text;
  //
  //
  @override
  void paint(Canvas canvas, Size size) {
    const double rectHeight = 100;
    const double borderRadius = 30;
    const double padding = 20;
    final Rect rect = Rect.fromLTWH(
      padding,
      size.height - rectHeight - padding,
      size.width - 6 * padding, //size.width - 2 * padding,
      rectHeight,
    );
    final RRect roundedRect = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.circular(borderRadius),
      topRight: const Radius.circular(borderRadius),
      bottomLeft: const Radius.circular(borderRadius),
      bottomRight: const Radius.circular(borderRadius),
    );
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromARGB(255, 3, 62, 107), // Начальный цвет
        Color.fromARGB(255, 37, 86, 123), // Конечный цвет
        Color.fromARGB(2255, 3, 62, 107), // Дополнительный цвет
      ],
      stops: [0.0, 0.5, 1.0], // Позиции цветов (0-1)
    );
    canvas.drawRRect(
        roundedRect,
        Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.fill);
    const textStyle = TextStyle(
      color: Color.fromARGB(255, 102, 163, 210),
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: rect.width,
    );
    final double textX = rect.left + (rect.width - textPainter.width) / 2;
    final double textY = rect.top + (rect.height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(textX, textY));
  }
}
