///
/// Error container
class Failure {
  final String message;
  final Failure? child;
  ///
  /// Creates Failure new instance
  Failure(this.message, {this.child});
}