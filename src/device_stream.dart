import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:yaml/yaml.dart';

class Point {
  final double x;
  final double y;
  Point(this.x, this.y);
}

class Subscribe {
  final String deviceId;
  final StreamController<Point> controller;
  Subscribe(this.deviceId) : controller = StreamController<Point>.broadcast();
  void add(Point point) {
    controller.add(point);
  }

  void close() {
    controller.close();
  }
}

class DeviceStream {
  final Map<String, Point> events = {};
  final Map<String, Subscribe> subscribes = {};
  final String addr;
  late final Socket _socket;
  DeviceStream(this.addr) {
    _connect();
  }
  void _connect() async {
    try {
      int port = 37206;
      _socket = await Socket.connect(addr, port);
      _socket.listen(_handleData, onError: _handleError, onDone: _handleDone);
    } catch (e) {
      print('Error connecting to server: $e');
    }
  }

  void _handleData(Uint8List data) {
    // В каком формате приходят данные? Допустим ямлик
    // yaml
    // deviceId:
    //  x: ...
    //  y: ...
    String message = String.fromCharCodes(data).trim();
    var yaml = loadYaml(message);
    for (var deviceId in yaml) {
      double x = yaml[deviceId]['x'];
      double y = yaml[deviceId]['y'];

      Point point = Point(x, y);
      events[deviceId] = point;

      // Уведомление подписчиков
      if (subscribes.containsKey(deviceId)) {
        subscribes[deviceId]!.add(point);
      }
    }
  }

  void _handleError(error) {
    print('Error: $error');
  }

  void _handleDone() {
    print('Connection closed');
  }

  void subscribe(String deviceId) {
    if (!subscribes.containsKey(deviceId)) {
      subscribes[deviceId] = Subscribe(deviceId);
    }
  }

  Stream<Point>? getStream(String deviceId) {
    return subscribes[deviceId]?.controller.stream;
  }

  void close() {
    _socket.close();
    for (var subscribe in subscribes.values) {
      subscribe.close();
    }
  }
}

void main() {
  final deviceStream = DeviceStream('127.0.0.1');
  deviceStream.subscribe('device1');
  deviceStream.getStream('device1')?.listen((point) {
    print('Received update for device1: (${point.x}, ${point.y})');
  });
  Future.delayed(Duration(seconds: 10), () {
    deviceStream.close();
    print('DeviceStream closed');
  });
}
