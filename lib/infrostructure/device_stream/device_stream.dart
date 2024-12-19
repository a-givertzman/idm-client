import 'dart:async';
//
//
import 'package:idm_client/domain/point/point.dart';
import 'package:idm_client/infrostructure/device_stream/connection.dart';
/// Class `DeviceStream` - device info provider
/// - `_connection` - connection to server
/// - `_subscriptions` - subscriptions on certain device
class DeviceStream {
  final Connection _connection;
  final Map<String, StreamController<Point>> _subscriptions = {};
  DeviceStream({
    required Connection connection,
  }) : _connection = connection {
    _listenConnection();
  }
  ///
  /// Stream of events coming from connection line
  /// Returns a stream of points for a given subscription name. Creates a new stream if one doesn't exist.
  Stream<Point> stream(String name) {
    if (!_subscriptions.containsKey(name)) {
      _subscriptions[name] = StreamController<Point>.broadcast();
    }
    return _subscriptions[name]!.stream;
  }
  ///
  /// Listening events from the connection
  void _listenConnection() {
    _connection.stream.listen((event) {
      final name = event.name;
      final controller = _subscriptions[name];
      if (controller != null) {
        controller.add(event);
      }
    });
  }
  ///
  /// Releases all resources
  void close() {
    _connection.close();
    for (var controller in _subscriptions.values) {
      controller.close();
    }
    _subscriptions.clear();
  }
}
