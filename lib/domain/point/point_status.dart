///
/// A container for statuses of the [Point].
enum Status {
  ok,
  invalid;
  ///
  /// Returns [Status] instance parsed from the incoming [value].
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
  /// Returns a numerical representation of this status.
  int toInt() {
    return switch (this) {
      Status.ok => 0,
      Status.invalid => 10,
    };
  }
}
