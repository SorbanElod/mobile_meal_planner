import 'package:dio/dio.dart';

/// Application-level error (deck p. 104–105): the repository maps technical
/// `DioException`s to these, so the UI only ever shows [userMessage] —
/// never a raw stack trace or status code.
sealed class AppException implements Exception {
  final String userMessage;

  const AppException(this.userMessage);

  /// Maps a Dio error to its application-level meaning (deck p. 104 table).
  factory AppException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        if (status == 401 || status == 403) return const AuthException();
        return ServerException(status);
      case DioExceptionType.cancel:
        return const CancelledException();
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return UnknownException(e.message ?? 'unknown');
    }
  }

  /// Wraps malformed JSON / unexpected response shapes (deck p. 100: a 200
  /// with a broken body is still a failure from the app's point of view).
  factory AppException.parse() => const ParseException();
}

class NetworkException extends AppException {
  const NetworkException()
    : super("You're offline. Check your connection and try again.");
}

class TimeoutException extends AppException {
  const TimeoutException()
    : super('The server is taking too long. Please try again.');
}

class ServerException extends AppException {
  ServerException(int status)
    : super('Server error ($status). Please try again later.');
}

class AuthException extends AppException {
  const AuthException() : super('Your session expired. Please sign in again.');
}

class ParseException extends AppException {
  const ParseException() : super("We couldn't process the server's response.");
}

class CancelledException extends AppException {
  const CancelledException() : super('The request was cancelled.');
}

class UnknownException extends AppException {
  UnknownException(String detail) : super('Something went wrong. ($detail)');
}
