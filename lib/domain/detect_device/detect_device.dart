import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/device.dart';
import 'package:idm_client/domain/pos.dart';

///
/// TODO: To be added
class DetectDevice {
  final _log = const Log("DetectDevice");
  final StreamController<Device> _controller = StreamController();
  // TODO: Use some single BarcodeFormat, to be mach more faster
  final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
  final Map<String, String> _details;
  DeviceOrientation _deviceOrientation = DeviceOrientation.portraitUp;
  int _sensorOrientation = 0;
  CameraLensDirection _lensDirection = CameraLensDirection.front;
  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
  ///
  /// Returns stream of detected [Device]'s
  /// - use `add()` method to pass frames to be scanned for [Device]'s barcodes
  DetectDevice(
    Map<String, String>? deviceDetails,
  ):
    _details = deviceDetails ?? {};

  ///
  /// Add new image for detection
  void add(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage != null) {
      _scan(inputImage);
    }
  }

  ///
  /// Detected devices
  Stream<Device> get stream {
    return _controller.stream;
  }
  ///
  /// Detects device barcode
  Future<void> _scan(InputImage inputImage) async {
    final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
    for (Barcode barcode in barcodes) {
      switch (barcode.type) {
        case BarcodeType.url:
          final value = barcode.value as BarcodeUrl;
          final id = value.url;
          final title = value.title ?? 'Undefined device';
          final details = _details[id] ?? barcode.displayValue ?? '---';
          if (id != null) {
            _controller.add(Device(
              id: id,
              title: title,
              pos: Pos(
                barcode.cornerPoints.first.x as double,
                barcode.cornerPoints.first.y as double,
              ),
              size: barcode.boundingBox.width,
              details: details
            ));
          } else {
            _log.warn('.scan | Unknown bar-code: $barcode');
          }
          break;
        default:
          _log.warn('.scan | Unknown bar-code type: ${barcode.type}');
      }
    }
  }
  ///
  ///
  void updateOrientation(int sensorOrientation, CameraLensDirection lensDirection, DeviceOrientation deviceOrientation) {
     _sensorOrientation = sensorOrientation; 
     _lensDirection = lensDirection;
     _deviceOrientation = deviceOrientation;
  }
  ///
  /// If you are using the Camera plugin make sure to configure your
  /// CameraController to only use ImageFormatGroup.nv21 for Android
  /// and ImageFormatGroup.bgra8888 for iOS.
  /// 
  /// Notice that the image rotation is computed in a different way for both
  /// iOS and Android. Image rotation is used in Android to convert the
  /// InputImage from Dart to Java, but it is not used in iOS to convert from
  /// Dart to Obj-C. However, image rotation and camera.lensDirection can be
  /// used in both platforms to compensate x and y coordinates on a canvas.
  /// 
  /// [source](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/google_mlkit_commons#creating-an-inputimage)
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(_sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_deviceOrientation];
      if (rotationCompensation == null) return null;
      if (_lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (_sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (_sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
            (Platform.isAndroid && format != InputImageFormat.nv21) ||
            (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }
    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;
    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
  ///
  /// Clear resources
  Future close() {
    return _controller.close();
  }
}
