import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hmi_core/hmi_core_result.dart';
import 'package:idm_client/domain/error/failure.dart';
import 'package:idm_client/infrostructure/device_info/api.dart';

///
/// Provides basic overview info by device
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
  /// Creates a new instanse of [DeviceInfo] with fields:
  /// - manufacturer
  /// - vendor
  /// - orderCode
  /// - model
  /// - serial
  /// - name
  /// - description
  /// - width
  /// - height
  /// - depth
  /// - weight
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
  /// Returns [DeviceInfo] ready to be fetched from the API later
  DeviceInfo.fromApi({
    required String address,
  }) : _remote = Api(address);
  ///
  /// Returns fetched from the API [DeviceInfo] data
  Future<Result<DeviceInfo, Failure>> fetch(String id) async {
    final remote = _remote;
    if (remote != null) {

    }
    final content = await rootBundle.loadString('assets/device/device.json');
    final devices = jsonDecode(content);
    if (devices.containsKey(id)) {
      final data = devices[id] as Map<String, dynamic>;
      return Ok(DeviceInfo(
        manufacturer: data['manufacturer'],
        name: data['name'],
        model: data['model'],
        description: data['description'],
      ));
    } else {
      return Err(Failure(
        ("Device not found"),
      ));
    }
  }
}
