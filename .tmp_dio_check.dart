import 'package:dio/dio.dart';

Future<void> main() async {
  // Exact copy of DioClient.instance config.
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.themealdb.com/api/json/v1/1/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );
  final sw = Stopwatch()..start();
  try {
    final r = await dio.get('search.php', queryParameters: {'s': ''});
    final meals = r.data is Map ? r.data['meals'] : null;
    print(
      'OK in ${sw.elapsedMilliseconds}ms status=${r.statusCode} '
      'meals=${meals is List ? meals.length : meals}',
    );
  } catch (e) {
    print('ERR in ${sw.elapsedMilliseconds}ms: ${e.runtimeType}: $e');
  }
}
