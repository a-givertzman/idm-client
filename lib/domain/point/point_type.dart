///
/// A container for specified types of the [Point] value.
enum PointType {
  bool,
  int,
  real,
  double,
  string;
  ///
  /// Returns [PointType] instance parsed from the incoming [value].
  static PointType fromStr(String value) {
    switch (value.toLowerCase()) {
      case 'bool':
        return PointType.bool;
      case 'int':
        return PointType.int;
      case 'real':
        return PointType.real;
      case 'double':
        return PointType.double;
      case 'string':
        return PointType.string;
      default:
        return PointType.string;
    }
  }
  ///
  /// Returns a string representation of this type.
  String toStr() {
    return switch (this) {
      PointType.bool => 'bool',
      PointType.int => 'int',
      PointType.real => 'real',
      PointType.double => 'double',
      PointType.string => 'string',
    };
  }
}
