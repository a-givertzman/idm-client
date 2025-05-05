import 'dart:io';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:hmi_core/hmi_core_result.dart';
import 'package:idm_client/domain/error/failure.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
///
/// Provides documentation of device.
class DeviceDoc {
  String? pdfPath;
  String? devId;
  final _log = const Log("DeviceDoc");
  ///
  /// Creates a new instanse of [DeviceDoc].
  DeviceDoc();
  ///
  /// Takes the pdf file corresponding to the device from assets and opens it in the available application on the running gadget.
  Future<void> openPdf(String id) async {
    try {
      String formattedId = id.replaceFirst('https://', 'https:/');
      pdfPath = 'assets/device/$formattedId.pdf';
      final result = await _copyAssetToLocal(pdfPath);
      if (result is Ok<File, Failure>) {
        final file = result.value;
        await OpenFilex.open(file.path);
      } else if (result is Err<File, Failure>) {
        _log.error('.openPdf | failure: $result');
      }
    } catch (e) {
      _log.error('.openPdf | error: $e');
    }
  }
  ///
  /// Copies given asset file to the local directory.
  Future<Result<File, Failure>> _copyAssetToLocal(String? assetPath) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${assetPath?.split('/').last}');
    final byteData = await rootBundle.load(assetPath!);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    if (file.existsSync()) {
      return Ok(file);
    } else {
      return Err(Failure(
        ("Device not found"),
      ));
    }
  }
}
