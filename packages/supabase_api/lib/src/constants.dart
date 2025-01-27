class NotFoundException implements Exception {
  final String message;

  NotFoundException([this.message = 'Value not found']);

  @override
  String toString() => 'NotFoundException: $message';
}