import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../storage/token_storage.dart';

class ApiClient {
  final Dio dio = Dio();
  final TokenStorage tokenStorage;

  /// Called when the token is expired or revoked (401).
  final void Function()? onUnauthorized;

  /// Called when the server refuses the action (403). The user's permissions
  /// may have changed, so the app reloads them and hides what's gone.
  final void Function()? onForbidden;

  ApiClient({
    required this.tokenStorage,
    this.onUnauthorized,
    this.onForbidden,
  }) {
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.options.connectTimeout = AppConstants.connectTimeout;
    dio.options.receiveTimeout = AppConstants.receiveTimeout;
    dio.options.headers['Content-Type'] = 'application/json';

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add the token to every request (if we have one).
          final token = await tokenStorage.read();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // 401 on sign-in means "wrong password", not "session expired".
          final path = error.requestOptions.path;
          final isLoginRequest =
              path.startsWith('/auth/signin') ||
              path.startsWith('/auth/activate');

          if (error.response?.statusCode == 401 && !isLoginRequest) {
            await tokenStorage.clear();
            onUnauthorized?.call();
          }
          if (error.response?.statusCode == 403) {
            onForbidden?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<dynamic> get(String path) async {
    try {
      final response = await dio.get(path);
      return response.data['data'];
    } on DioException catch (error) {
      throw _toAppException(error);
    }
  }

  Future<dynamic> post(String path, {Object? data}) async {
    try {
      final response = await dio.post(path, data: data);
      return response.data['data'];
    } on DioException catch (error) {
      throw _toAppException(error);
    }
  }

  Future<dynamic> put(String path, {Object? data}) async {
    try {
      final response = await dio.put(path, data: data);
      return response.data['data'];
    } on DioException catch (error) {
      throw _toAppException(error);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await dio.delete(path);
      return response.data['data'];
    } on DioException catch (error) {
      throw _toAppException(error);
    }
  }

  /// Turns any Dio error into an AppException the UI can show.
  AppException _toAppException(DioException error) {
    final response = error.response;

    // No response at all: no internet, timeout, server down.
    if (response == null) {
      return const AppException('تحقق من اتصالك بالإنترنت وحاول مرة أخرى');
    }

    // The server replied with an error: use its message.
    String message = 'حدث خطأ ما، حاول مرة أخرى';
    if (response.data is Map && response.data['message'] != null) {
      message = response.data['message'];
    }
    return AppException(message, statusCode: response.statusCode);
  }
}
