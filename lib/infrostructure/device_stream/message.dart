import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:hmi_core/hmi_core_option.dart';
import 'package:idm_client/domain/error/failure.dart';
import 'package:idm_client/domain/point/point.dart';
import 'package:idm_client/domain/point/point_status.dart';
import 'package:idm_client/domain/point/point_type.dart';
import 'package:hmi_core/hmi_core_result.dart';
import 'package:idm_client/domain/types/bytes.dart';
import 'package:idm_client/infrostructure/device_stream/connect.dart';
import 'package:ext_rw/src/api_client/message/field_id.dart';
import 'package:ext_rw/src/api_client/message/field_kind.dart';
import 'package:ext_rw/src/api_client/message/field_syn.dart';
import 'package:ext_rw/src/api_client/message/field_size.dart';
import 'package:ext_rw/src/api_client/message/field_data.dart';
import 'package:ext_rw/src/api_client/message/message_build.dart';
import 'package:ext_rw/src/api_client/message/parse_data.dart';
import 'package:ext_rw/src/api_client/message/parse_id.dart';
import 'package:ext_rw/src/api_client/message/parse_kind.dart';
import 'package:ext_rw/src/api_client/message/parse_size.dart';
import 'package:ext_rw/src/api_client/message/parse_syn.dart';
///
/// Converts Stream<List<int>> into Stream<Point>
/// Sends Point converting it into List<int>
/// - `_connect` - Socket connection
class Message {
  final _log = const Log("Message");
  final Connect _connect;
  // - '_controller` - StreamController output stream of bytes
  final StreamController<Point> _controller = StreamController();
  bool _isStarted = false;
  int _messageId = 0;
  // - `_subscriptions` - subscriptions on certain device
  late StreamSubscription? _subscription;
  final MessageBuild _messageBuild = MessageBuild(
    syn: FieldSyn.def(),
    id: FieldId.def(),
    kind: FieldKind.bytes,
    size: FieldSize.def(),
    data: FieldData([]),
  );
  ///
  /// Creates [Message] new instance
  /// - `connect` - Socket connection
  Message({required Connect connect}): _connect = connect;
  ///
  /// Incoming stream of Point's
  Stream<Point> get stream {
    if (!_isStarted) {
      _isStarted = true;
      final message = ParseData(
        field: ParseSize(
          size: FieldSize.def(),
          field: ParseKind(
            field: ParseId(
            id: FieldId.def(),
              field: ParseSyn.def(),
            ),
          ),
        ),
      );
      _subscription =_connect.stream.listen(
        (Bytes bytes) {
          // _log.debug('.listen.onData | Event: $event');
          Bytes? input = bytes;
          bool isSome = true;
          while (isSome) {
            switch (message.parse(input)) {
              case Some<(FieldId, FieldKind, FieldSize, Bytes)>(value: (final id, final kind, final _, final bytes)):
                // _log.debug('.listen.onData | id: $id,  kind: $kind,  size: $size, bytes: ${bytes.length > 16 ? bytes.sublist(0, 16) : bytes}');
                switch (_parse(bytes)) {
                  case Ok<Point, Failure>(value: final point):
                    _controller.add(point);
                  case Err<Point, Failure>(: final error):
                    _log.warn('.stream.listen | Error: $error');
                }
                input = null;
              case None():
                isSome = false;
                // _log.debug('.listen.onData | None');
            }
          }
        },
        onDone: () async {
          _log.debug('.stream.listen.onDone | Done');
          await _subscription?.cancel();
          await _connect.close();
        },
        onError: (err) {
          _log.warn('.stream.listen.onError | Error: $err');
        }
      );
    }
    return _controller.stream;
  }
  ///
  /// Sends Point
  void add(Point point) {
    Uint8List bytes = _toBytes(point);
    // _log.debug('.add | id: $id,  bytes: ${bytes.length > 16 ? bytes.sublist(0, 16) : bytes}');
    _messageId++;
    _connect.add(
      _messageBuild.build(bytes, id: _messageId)
    );
  }
  ///
  /// Convert Point to JSON, then to bytes
  Uint8List _toBytes(Point point) {
    final map = {
      'name': point.name,
      'type': point.type.toStr(),
      'value': point.value,
      'status': point.status.toInt(),
      'timestamp': point.timestamp,
    };
    final jsonVal = json.encode(map);
    return utf8.encode(jsonVal);
  }
  //
  //
  Result<Point, Failure> _parse(List<int> bytes) {
    try {
      String message = String.fromCharCodes(bytes).trim();
      final jsonVal = json.decode(message);
      final name = jsonVal['name'];
      final type = PointType.fromStr(jsonVal['type']);
      final value = switch (type) {
        PointType.bool => jsonVal['value'],
        PointType.int => jsonVal['value'],
        PointType.real => jsonVal['value'],
        PointType.double => jsonVal['value'],
        PointType.string => jsonVal['value'],
      };
      var status = Status.fromInt(jsonVal['status']);
      var timestamp = jsonVal['timestamp'];
      return Ok(Point(
        name: name,
        type: type,
        value: value,
        status: status,
        timestamp: timestamp,
      ));
    } catch (err) {
      return Err(Failure('Message.parse | Parsing error: $err'));
    }
  }
  ///
  /// Returns a [Future] that completes once all buffered data is accepted by the underlying [StreamConsumer].
  /// 
  /// This method must not be called while an [addStream] is incomplete.
  /// 
  /// NOTE: This is not necessarily the same as the data being flushed by the operating system.
  Future flush() {
    return _connect.flush();
  }
  ///
  /// Reases all resources
  Future<void> close() async {
    await _subscription?.cancel();
    await _connect.close();
    await _controller.close();
  }
}
