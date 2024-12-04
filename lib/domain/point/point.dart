import 'package:idm_client/domain/point/point_status.dart';
import 'package:idm_client/domain/point/point_type.dart';

///
/// Data unit,
/// - contains value
/// - timestemp 
/// - status
class Point<T> {
  final PointType type;
  final T value;
  final Status status;
  final String timestamp;
  ///
  /// Returns [Point] new instance
  const Point({
    required this.type,
    required this.value,
    required this.status,
    required this.timestamp,
  });
}