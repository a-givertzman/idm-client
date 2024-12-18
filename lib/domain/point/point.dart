import 'package:idm_client/domain/point/point_status.dart';
import 'package:idm_client/domain/point/point_type.dart';

///
/// Data unit,
/// - name of the device
/// - contains value
/// - timestemp
/// - status
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
}
