import 'dart:async';

import 'package:idm_client/domain/point/point.dart';

///
/// TODO A connection line to be implemented
class Connection {
  final _controller = StreamController<Point>();
  ///
  /// TODO Some constructor to be implemented
  ///
  /// Stream of event comong from the connection line
  Stream<Point> get stream => _controller.stream;
}