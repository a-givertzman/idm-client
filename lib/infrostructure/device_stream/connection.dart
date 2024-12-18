import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
//
//
import 'package:idm_client/domain/point/point.dart';
import 'package:idm_client/infrostructure/device_stream/message.dart';
import 'package:yaml/yaml.dart';
/// Class `Connection` - manages the socket connection
/// - `_controller` - StreamController to manage the stream of Point objects
/// - `_socket` - socket object representing the network connection to the server
/// - `addr` - addres of the server
/// - `port` - port of the server
class Connection {
  final _controller = StreamController<Point>();
  late final Socket socket;
  final String addr;
  final int port;
  late final Message _message;
  Connection({
    required this.addr,
    this.port = 1234,
  }) {
    _initSocket();
    _message = Message(this);
  }
  /// Stream of event coming from the connection line
  Stream<Point> get stream => _controller.stream;
  //
  //
  void _initSocket() async {
    try {
      socket = await Socket.connect(addr, port);
      socket.listen(_message,
          onError: _handleError, onDone: _handleDone);
    } catch (e) {
      print('Error connecting to server: $e');
    }
  }
  //
  //
  void _handleError(error) {
    print('Error: $error');
  }
  //
  //
  void _handleDone() {
    print('Connection closed');
  }
  //
  //
  void close() {
    socket.close();
    _controller.close();
  }
}
