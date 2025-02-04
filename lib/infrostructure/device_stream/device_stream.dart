import 'dart:async';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/point/point.dart';
import 'package:idm_client/infrostructure/device_stream/message.dart';
///
/// Provides information of the device.
class DeviceStream {
  final _log = const Log("DeviceStream");
  final Message _message;
  // - `_subscriptions` - subscriptions on certain device
  final Map<String, StreamController<Point>> _subscriptions = {};
  ///
  /// Creates a new instance of [DeviceStream] with incoming [message]
  DeviceStream({
    required Message message,
  }) : _message = message {
    _listenConnection();
  }
  ///
  /// Returns a stream of [Point] for a given subscription [name]. Creates a new stream if one doesn't exist.
  Stream<Point> stream(String name) {
    if (!_subscriptions.containsKey(name)) {
      _subscriptions[name] = StreamController<Point>.broadcast();
    }
    return _subscriptions[name]!.stream;
  }
  ///
  /// Listening to the events from the connection.
  void _listenConnection() {
    _message.stream.listen(
      (event) {
        final name = event.name;
        final controller = _subscriptions[name];
        if (controller != null) {
          controller.add(event);
        }
      },
      onDone: () async {
        _log.warn('._listenConnection.listen | Done');
        _message.close();
        await Future.delayed(const Duration(milliseconds: 100));
        _listenConnection();
      },
      onError: (err) {
        _log.warn('._listenConnection.listen | Connection error: $err');
      },
    );
  }
  ///
  /// Releases all resources.
  void close() {
    _message.close();
    for (var controller in _subscriptions.values) {
      controller.close();
    }
    _subscriptions.clear();
  }
}
