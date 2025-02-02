import 'dart:async';
import 'dart:io';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/types/bytes.dart';
/// Infinit trys to connect socket, yields event from socket via `stream` getter
/// - `addr` - addres of the server
/// - `port` - port of the server
class Connect {
  final _log = const Log("Connect");
  // - `_socket` - socket object representing the network connection to the server
  Socket? _socket; 
  // - `_controller` - StreamController output stream of bytes
  final _controller = StreamController<Bytes>();
  // - `_subscriptions` - subscriptions on certain device
  StreamSubscription<Bytes>? _subscription;
  final String _addr;
  final int _port;
  final List<Bytes> _buffer = [];
  bool _isStarted = false;
  bool _close = false;
  /// Creates [Connect] new instance
  /// - `addr` - IPV4 addres of the server
  /// - `port` - certain free port of the server
  Connect({
    required String addr,
    int port = 1234,
  }): 
    _addr = addr,
    _port = port;
  /// Stream of event coming from the connection line
  Stream<Bytes> get stream {
    _connect();
    return _controller.stream;
  }
  //
  //
  Future<void> _connect() async {
    if (_isStarted) {
      return;
    }
    _isStarted = true;
    Future.microtask(() async {
      while (!_close) {
        try {
          _log.info('._connect | Connecting to: $_addr:$_port...');
          final socket = await Socket.connect(_addr, _port);
          socket.setOption(SocketOption.tcpNoDelay, true);
          _log.info('._connect | Connecting to: $_addr:$_port - Ok');
          _socket = socket;
          _sendBuffer();
          _listen(socket);
          break;
        } catch (err) {
          _log.warn('._connect.listen | Connecting error: $err');
          await Future.delayed(const Duration(seconds: 3));
        }
      }
    });
    _log.info('._connect | Exit');
  }
  ///
  /// Listening socket stream
  void _listen(Socket socket) {
    _subscription = socket.listen(
      (Bytes event) {
        _log.warn('._listen | Event: $event');
        _controller.add(event);
      },
      onDone: () async {
        _log.warn('._listen | Done');
        _isStarted = false;
        _subscription?.cancel;
        await Future.delayed(const Duration(seconds: 1));
        _connect();
      },
      onError: (err) {
        _log.warn('._listen | Error: $err');
      },
    );
    _log.info('._listen | Exit');
  }
  ///
  /// Sends accumulated buffer
  void _sendBuffer() {
    try {
      while (_buffer.isNotEmpty && !_close) {
        final bytes = _buffer.removeAt(0);
        _socket?.add(bytes);
      }
    } catch (err) {
      _log.warn('._sendBuffer | Error: $err');
    }
  }
  ///
  /// Sends Bytes, supports buffering if connection lost
  void add(Bytes bytes) {
    final socket = _socket;
    if (socket == null) {
      _buffer.add(bytes);
    } else {
      _sendBuffer();
      _socket?.add(bytes);
    }
  }
  ///
  /// Returns a [Future] that completes once all buffered data is accepted by the underlying [StreamConsumer].
  /// 
  /// This method must not be called while an [addStream] is incomplete.
  /// 
  /// NOTE: This is not necessarily the same as the data being flushed by the operating system.
  Future flush() {
    return _socket?.flush() ?? Future.value();
  }
  ///
  /// Releases all resources
  Future<void> close() async {
    _close = true;
    await _socket?.close();
    await _controller.close();
  }
}
