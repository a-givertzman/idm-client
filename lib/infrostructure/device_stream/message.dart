import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/error/failure.dart';
import 'package:idm_client/domain/point/point.dart';
import 'package:idm_client/domain/point/point_status.dart';
import 'package:idm_client/domain/point/point_type.dart';
import 'package:hmi_core/hmi_core_result.dart';
import 'package:idm_client/infrostructure/device_stream/connect.dart';
///
/// - Converting Stream<List<int>> into Stream<Point>
/// - Sends Point converting it into List<int>
class Message {
  final _log = const Log("Message");
  final Connect _connect;
  final StreamController<Point> _controller = StreamController();
  bool _isStarted = false;
  ///
  /// - connection - Socket connection
  Message({required Connect connect}): _connect = connect;
  ///
  /// Incoming stream of Point's
  Stream<Point> get stream {
    if (!_isStarted) {
      _isStarted = true;
      _connect.stream.listen(
        (bytes) {
          switch (_parse(bytes)) {
            case Ok<Point, Failure>(value: final point):
              _controller.add(point);
            case Err<Point, Failure>(: final error):
              _log.warn('.stream.listen | Error: $error');
          }
        },
        onDone: () {
          _log.debug('.stream.listen.onDone | Done');
          
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
    _connect.add(bytes);
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
  ///
  /// 
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
      return Ok(Point<double>(
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
  /// Reases all resources
  Future<void> close() async {
    await _connect.close();
    await _controller.close();
  }
}
