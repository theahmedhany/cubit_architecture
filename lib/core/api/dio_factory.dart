import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../cache/secure_storage_helper.dart';
import '../helpers/app_logger.dart';
import '../routing/route_manager.dart';
import '../theme/app_texts/app_language.dart';
import 'api_constants.dart';

class DioFactory {
  DioFactory._();

  static Dio? _dio;
  static CancelToken _cancelToken = CancelToken();

  static Future<void> Function()? onUnauthenticated;

  static Future<Dio> getDio() async {
    const timeout = Duration(seconds: 30);

    if (_dio != null) return _dio!;

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
        headers: _baseHeaders(),
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(),
      _LanguageInterceptor(),
      _ErrorInterceptor(),

      if (kDebugMode) _prettyLogger(),
    ]);

    _dio = dio;
    return dio;
  }

  // Call after login.
  static Future<void> setTokenAfterLogin(String token) async {
    await SecureStorageHelper.setToken(token);

    AppLogger.log('Token saved', name: 'DIO_FACTORY');
  }

  // Call on logout.
  static Future<void> clearToken() async {
    _cancelToken.cancel('Logged out');

    _cancelToken = CancelToken();

    await SecureStorageHelper.clearToken();

    AppLogger.log('Token cleared', name: 'DIO_FACTORY');
  }

  static void reset() {
    _cancelToken.cancel('Factory reset');

    _cancelToken = CancelToken();

    _dio?.close(force: true);

    _dio = null;
  }

  static CancelToken get sessionToken => _cancelToken;

  static Map<String, dynamic> _baseHeaders() {
    return {ApiConstants.accept: ApiConstants.applicationJson};
  }

  static PrettyDioLogger _prettyLogger() {
    return PrettyDioLogger(
      enabled: kDebugMode,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: true,
      maxWidth: 180,
    );
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresAuth = options.extra[ApiConstants.authHeader] != false;

    if (requiresAuth) {
      final token = await SecureStorageHelper.getToken();

      if (token.isNotEmpty) {
        options.headers[ApiConstants.authorization] =
            '${ApiConstants.bearer} $token';
      }
    } else {
      options.headers.remove(ApiConstants.authorization);
    }

    handler.next(options);
  }
}

class _LanguageInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String language;

    switch (AppLanguage.currentLanguageCode) {
      case AppLanguage.arCode:
        language = AppLanguage.arCode;
        break;

      case AppLanguage.enCode:
        language = AppLanguage.enCode;
        break;

      default:
        language = AppLanguage.enCode;
    }

    options.headers[ApiConstants.acceptLanguage] = language;

    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  static bool _isLoggingOut = false;

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    final statusCode = error.response?.statusCode;

    final message = _extractMessage(error.response?.data);

    final isUnauthorized =
        statusCode == 401 && message.contains(ApiConstants.unauthenticated);

    if (isUnauthorized) {
      _handleUnauthenticated();

      return handler.reject(
        DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          error: 'Session expired, please login again',
          type: DioExceptionType.badResponse,
        ),
      );
    }

    handler.next(error);
  }

  String _extractMessage(dynamic data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString().toLowerCase();
    }

    return '';
  }

  static Future<void> _handleUnauthenticated() async {
    if (_isLoggingOut) return;

    _isLoggingOut = true;

    try {
      AppLogger.log('Session expired', name: 'DIO_FACTORY');

      await SecureStorageHelper.clearToken();

      navigateAfterUnauthenticated();
    } finally {
      _isLoggingOut = false;
    }
  }

  static void navigateAfterUnauthenticated() {
    RouteManager.navigateAndPopAll(const OnboardingScreen());
  }
}
