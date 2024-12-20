///
/// Stauses of the [Point]
enum Status {
  ok,
  invalid;
  ///
  /// Returns PointType instance parsed from corresponding string
  static Status fromInt(int value) {
    switch (value) {
      case 0:
        return Status.ok;        
      case 10:
        return Status.invalid;
      default:
        return Status.invalid;
    }
  }
  ///
  /// Returns string representation ov variant
  int toInt() {
    return switch (this) {
      Status.ok => 0,
      Status.invalid => 10,
    };
  }
}
