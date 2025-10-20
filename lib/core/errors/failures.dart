sealed class Failure implements Exception {
  final String message;
  const Failure(this.message);
}

class StorageFailure extends Failure {
  const StorageFailure(String message) : super(message);
}
