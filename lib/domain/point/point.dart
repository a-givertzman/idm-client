import 'package:idm_client/domain/point/point_status.dart';
import 'package:idm_client/domain/point/point_type.dart';
///
/// Class `Point` - data unit,
/// - `name` - name of the device
/// - `type` - defines the type
/// - `value` - contains value
/// - `status` - dafines the satus
/// - `timestamp` - defines the creation time
class Point<T> {
  final String name;
  final PointType type;
  final T value;
  final Status status;
  final String timestamp;
  ///
  /// Returns [Point] new instance
  const Point({
    required this.name,
    required this.type,
    required this.value,
    required this.status,
    required this.timestamp,
  });
  ///
  /// Returns string representation of class content
  @override
  String toString() {
    return 'Point(name: $name, type: $type, value: $value, status: $status, timestamp: $timestamp)';
  }
}
