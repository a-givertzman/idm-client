import 'dart:async';
import 'dart:typed_data';
//
//
import 'package:flutter/material.dart';
import 'package:idm_client/domain/point/point.dart';
import 'package:idm_client/infrostructure/device_stream/connection.dart';
import 'package:yaml/yaml.dart';
import 'package:hmi_core/hmi_core_result.dart';
///
/// - Converting Stream<List<int>> into Stream<Point>
/// - Sends Point converting it into List<int>
class Message {
  final Connection connection;
  ///
  /// - connection - Socket connection
  Message(this.connection);
  ///
  /// Incoming stream of Point's
  Stream<Point> stream() {
    return connection.stream; //.map((bytes) => bytes as List<int>);
  }
  ///
  /// Sends Point
  void add(Point point) {
    // Convert Point to YAML, then to bytes
    Uint8List bytes = convertToBytes(point);
    connection.socket.add(bytes);
  }
  //
  //
  Uint8List convertToBytes(Point point) {
    String yaml = '''
    ${point.name}:
    type: ${point.type}
    value: ${point.value}
    status: ${point.status}
    timestamp: ${point.timestamp}
    ''';
    return Uint8List.fromList(yaml.codeUnits);
  }
  //
  //
  Result<Point, Err> parse(List<int> bytes) {
    String message = String.fromCharCodes(bytes).trim();
    var yaml = loadYaml(message);
    for (var deviceId in yaml.keys) {
      var deviceData = yaml[deviceId];
      if (deviceData != null && deviceData is YamlMap) {
        var value = (deviceData['value'] as num).toDouble();
        var type = deviceData['type'];
        var status = deviceData['status'];
        var timestamp = deviceData['timestamp'];
        Point point = Point<double>(
          name: deviceId,
          type: type,
          value: value,
          status: status,
          timestamp: timestamp,
        );
        return Ok(point);
      }
    }
    return Err(Err('Parsing error'));
  }
}
