import 'package:idm_client/domain/point/point_status.dart';
import 'package:idm_client/domain/point/point_type.dart';
///
/// A block of data that includes information comimg from JSON file.
class Point<T> {
  ///
  /// A name of the device.
  final String name;
  ///
  /// A specified type of the [value].
  final PointType type;
  ///
  /// The received value.
  final T value;
  ///
  /// The status of this point.
  final Status status;
  ///
  /// The creation time of this point.
  final String timestamp;
  ///
  /// Creates a new instance of [Point].
  const Point({
    required this.name,
    required this.type,
    required this.value,
    required this.status,
    required this.timestamp,
  });
  ///
  /// Returns a string representation of this point.
  @override
  String toString() {
    return 'Point(name: $name, type: $type, value: $value, status: $status, timestamp: $timestamp)';
  }
}
