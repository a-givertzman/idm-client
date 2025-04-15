import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hmi_core/hmi_core_result.dart';
import 'package:idm_client/domain/error/failure.dart';
import 'package:idm_client/infrostructure/device_info/api.dart';

///
/// TODO: Type doc
class DeviceInfo {
  String? manufacturer;
  String? vendor;
  String? orderCode;
  String? model;
  String? serial;
  String? name;
  String? description;
  String? width;
  String? height;
  String? depth;
  String? weight;
  Api? _remote;
  ///
  /// TODO: Type doc
  DeviceInfo({
    this.manufacturer,
    this.vendor,
    this.orderCode,
    this.model,
    this.serial,
    this.name,
    this.description,
    this.width,
    this.height,
    this.depth,
    this.weight,
  });
  ///
  /// TODO: Type doc
  DeviceInfo.fromApi({
    required String address,
  }):
    _remote = Api(address);
  ///
  /// TODO: Type doc
  Future<Result<DeviceInfo, Failure>> fetch(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final content = await rootBundle.loadString('assets/device/device.json');
    final devices = jsonDecode(content);
    Map<String, dynamic> response;
    if (devices.containsKey(id)) {
      response = {
        "ok": devices[id],
        "err": null,
      };
    } else {
      response = {
        "ok": null,
        "err": {
          "msg": "Device not found",
          "details": "No data for dev-id '$id'"
        },
      };
    }
    if (response['ok'] != null) {
      return devices[id];
    } else {
      throw Exception('Устройство не найдено');
    }
  }
}