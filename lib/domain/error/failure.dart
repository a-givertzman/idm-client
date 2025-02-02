///
/// Class `Failure` - error container
/// - `message` - description of the error
/// - `child` - optional child failure
class Failure {
  final String message;
  final Failure? child;
  ///
  /// Creates [Failure] new instance
  /// - `message` - description of the error
  /// - `child` - optional child failure, that provides additional info
  Failure(this.message, {this.child});
  ///
  /// Return a string representation of failure that occured
  @override
  String toString() {
    return 'Failure: $message \n\t↳$child';
  }
}