import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:idm_client/domain/point/point.dart';
import 'package:yaml/yaml.dart';

/// Class `Connection` - manages the socket connection
/// - `_controller` - StreamController to manage the stream of Point objects
/// - `_socket` - socket object representing the network connection to the server
/// - `addr` - addres of the server
/// - `port` - port of the server
class Connection {
  final _controller = StreamController<Point>();
  late final Socket _socket;
  final String addr;
  final int port;

  Connection({
    required this.addr,
    this.port = 1234,
  }) {
    _initSocket();
  }

  /// Stream of event coming from the connection line
  Stream<Point> get stream => _controller.stream;

  void _initSocket() async {
    try {
      _socket = await Socket.connect(addr, port);
      _socket.listen(_handleData, onError: _handleError, onDone: _handleDone);
    } catch (e) {
      print('Error connecting to server: $e');
    }
  }

  void _handleData(Uint8List data) {
    String message = String.fromCharCodes(data).trim();
    var yaml = loadYaml(message);

    for (var deviceId in yaml.keys) {
      var deviceData = yaml[deviceId];
      if (deviceData != null && deviceData is YamlMap) {
        var value = (deviceData['value'] as num).toDouble();
        var type = deviceData['type'];
        var status = deviceData['status'];
        var timestamp = deviceData['timestamp'];

        _controller.add(Point<double>(
          type: type,
          value: value,
          status: status,
          timestamp: timestamp,
        ));
      }
    }
  }

  void _handleError(error) {
    print('Error: $error');
  }

  void _handleDone() {
    print('Connection closed');
  }

  void close() {
    _socket.close();
    _controller.close();
  }
}
