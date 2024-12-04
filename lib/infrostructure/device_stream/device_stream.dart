import 'dart:async';

import 'package:idm_client/domain/point/point.dart';
import 'package:idm_client/infrostructure/device_stream/connection.dart';

///
/// TODO Add doc comment...
class DeviceStream {
  final Connection _connection;
  final Map<String, StreamController<Point>> _subscriptions = {};
  ///
  /// Returns DeviceStream new instance
  DeviceStream({
     required Connection connection,
  }):
    _connection = connection;
  ///
  /// Stream of events coming from connection line
  Stream<Point> stream(String name) {
    // TODO
    // get existing subscription by the `name` if exists
    // if not exists, create new one subscription = StreamController<Point>();
    // add subscription to the `_subscriptions` with specified `name
    return subscription.stream;
  }
  ///
  /// Listening events from the connection
  void _listenConnection() {
    _connection.stream.listen((event) {
      // TODO to be implemented...
      // get receivers
    });
  }
}