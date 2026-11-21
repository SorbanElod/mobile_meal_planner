import 'package:dio/dio.dart';

/// Central HTTP client (deck p. 59): base URL, timeouts and headers live in
/// exactly one place, so a backend change means editing this file only.
/// Screens/services never construct their own `Dio`.
abstract final class DioClient {
  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: 'https://www.themealdb.com/api/json/v1/1/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );
}
