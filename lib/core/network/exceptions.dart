/// Base exception for the app
class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => 'AppException: $message';
}

/// Exception for API errors
class ApiException extends AppException {
  final int? statusCode;
  ApiException(super.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

/// Exception for network errors
class NetworkException extends AppException {
  NetworkException(super.message);
}
