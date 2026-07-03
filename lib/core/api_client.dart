import 'package:dio/dio.dart';
import 'api_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

/// Thin wrapper around [Dio] shared by every repository.
///
///  - Automatically attaches `Authorization: Bearer <token>` when a token
///    exists in [TokenStorage] (needed for /auth/logout and, later, any
///    endpoint behind auth).
///  - Converts every failure into an [ApiException] so cubits never have to
///    know about Dio/HTTP details.
class ApiClient {
  ApiClient({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage(),
        _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
  }) =>
      _send(() => _dio.post(
            path,
            data: body,
            options: headers != null ? Options(headers: headers) : null,
          ));

  Future<Map<String, dynamic>> get(String path) => _send(() => _dio.get(path));

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) =>
      _send(() => _dio.put(path, data: body));

  Future<Map<String, dynamic>> delete(String path) =>
      _send(() => _dio.delete(path));

  Future<Map<String, dynamic>> _send(
    Future<Response> Function() request,
  ) async {
    try {
      final response = await request();
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      // Some endpoints (e.g. logout) may return an empty/plain body.
      return <String, dynamic>{};
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final response = e.response;
    if (response == null) {
      return const ApiException(
        'Could not reach the server. Check your connection and try again.',
      );
    }

    final data = response.data;
    String message = 'Something went wrong. Please try again.';
    final fieldErrors = <String, List<String>>{};

    if (data is Map<String, dynamic>) {
      if (data['message'] is String) message = data['message'] as String;
      final errors = data['errors'];
      if (errors is Map) {
        errors.forEach((key, value) {
          if (value is List) {
            fieldErrors[key.toString()] = value.map((v) => v.toString()).toList();
          }
        });
        // Prefer the first field error as the headline message if present.
        if (fieldErrors.isNotEmpty) {
          message = fieldErrors.values.first.first;
        }
      }
    }

    return ApiException(
      message,
      statusCode: response.statusCode,
      fieldErrors: fieldErrors,
    );
  }
}
