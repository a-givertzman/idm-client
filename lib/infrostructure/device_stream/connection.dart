import 'dart:async';
import 'dart:io';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/point/point.dart';
import 'package:idm_client/infrostructure/device_stream/message.dart';
/// Class `Connection` - manages the socket connection
/// - `_controller` - StreamController to manage the stream of Point objects
/// - `_socket` - socket object representing the network connection to the server
/// - `addr` - addres of the server
/// - `port` - port of the server
class Connection {
  final _log = const Log("Connection");
  final _controller = StreamController<Point>();
  final String _addr;
  final int _port;
  late final Message _message;
  bool _close = false;
  /// Creates [Connection] new instance
  /// - `_controller` - StreamController to manage the stream of Point objects
  /// - `_socket` - socket object representing the network connection to the server
  /// - `addr` - addres of the server
  /// - `port` - port of the server
  Connection({
    required String addr,
    int port = 1234,
  }): 
    _addr = addr,
    _port = port {
    _connect();
  }
  /// Stream of event coming from the connection line
  Stream<Point> get stream => _controller.stream;
  //
  //
  Future<void> _connect() async {
    Future.microtask(() async {
      while (!_close) {
        try {
          _log.warn('._connect | Connecting to: $_addr:$_port');
          final socket = await Socket.connect(_addr, _port);
          _message = Message(socket: socket);
          _message.stream.listen(
            (Point event) {

            },
            onDone: () {
              _log.debug('._connect.listen | Done');
            },
            onError: (err) {
              _log.warn('._connect.listen | Error: $err');
            },
          );
        } catch (err) {
          _log.warn('._connect.listen | Connecting error: $err');
        }
      }
    });
  }
  ///
  /// Releases all resources
  void close() {
    _close = true;
    _message.close();
    _controller.close();
  }
}
