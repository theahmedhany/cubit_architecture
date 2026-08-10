import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

import '../helpers/app_logger.dart';
import 'api_error_handler.dart';
import 'api_error_model.dart';
import 'api_result.dart';

abstract class NetworkStatusInfo {
  Future<bool> get isConnected;

  Future<ApiResult<T>> safeRequest<T>(
    Future<T> Function() request, {
    bool checkNet = true,
    int retryCount = 0,
    Duration retryDelay = const Duration(seconds: 1),
    bool logRequest = false,
  });
}

class NetworkStatusInfoImpl implements NetworkStatusInfo {
  final Connectivity _connectivity;
  final Dio _dio;

  NetworkStatusInfoImpl(this._connectivity, this._dio);

  final List<String> _pingUrls = [
    'https://clients3.google.com/generate_204',
    'https://connectivitycheck.gstatic.com/generate_204',
    'https://www.cloudflare.com/cdn-cgi/trace',
  ];

  DateTime? _lastConnectionCheck;
  bool _lastConnectionStatus = false;

  bool _isChecking = false;
  Completer<bool>? _pendingCheck;

  @override
  Future<bool> get isConnected async {
    if (_lastConnectionCheck != null &&
        _lastConnectionCheck!
            .add(const Duration(seconds: 5))
            .isAfter(DateTime.now())) {
      return _lastConnectionStatus;
    }

    if (_isChecking) {
      return _pendingCheck!.future;
    }

    _isChecking = true;
    _pendingCheck = Completer<bool>();

    try {
      final results = await _connectivity.checkConnectivity();

      if (results.every((r) => r == ConnectivityResult.none)) {
        _completeCheck(false);

        return false;
      }

      final hasInternet = await _tryPingUrls();

      _completeCheck(hasInternet);

      return hasInternet;
    } catch (e) {
      AppLogger.log('Connection check failed: $e', name: 'NETWORK_STATUS_INFO');

      _completeCheck(false);

      return false;
    }
  }

  Future<bool> _tryPingUrls() async {
    for (final url in _pingUrls) {
      try {
        final response = await _dio.get(
          url,
          options: Options(
            receiveTimeout: const Duration(seconds: 3),
            sendTimeout: const Duration(seconds: 3),
          ),
        );

        if (response.statusCode == 204 || response.statusCode == 200) {
          return true;
        }
      } catch (e) {
        AppLogger.log('Ping failed for $url: $e', name: 'NETWORK_STATUS_INFO');

        continue;
      }
    }

    return false;
  }

  void _completeCheck(bool result) {
    _updateCachedConnection(result);
    _pendingCheck?.complete(result);
    _isChecking = false;
    _pendingCheck = null;
  }

  @override
  Future<ApiResult<T>> safeRequest<T>(
    Future<T> Function() request, {
    bool checkNet = true,
    int retryCount = 0,
    Duration retryDelay = const Duration(seconds: 1),
    bool logRequest = false,
  }) async {
    // If you need to stop checking connectivity make (!checkNet).
    if (checkNet) {
      final connected = await isConnected;

      if (!connected) {
        return ApiResult.failure(
          ApiErrorModel(message: 'no_internet_connection'.tr()),
        );
      }
    }

    int currentRetry = 0;

    while (true) {
      try {
        final stopwatch = Stopwatch()..start();

        final response = await request();

        stopwatch.stop();

        if (logRequest && kDebugMode) {
          AppLogger.log(
            'Request Success (${stopwatch.elapsedMilliseconds}ms)',
            name: 'NETWORK_STATUS_INFO',
          );
        }

        return ApiResult.success(response);
      } on TimeoutException {
        return ApiResult.failure(
          ApiErrorModel(message: 'request_timeout'.tr()),
        );
      } on DioException catch (e, stackTrace) {
        if (logRequest && kDebugMode) {
          AppLogger.log(
            'Dio Error: ${e.type} - ${e.message} - Stack Trace: $stackTrace',
            name: 'NETWORK_STATUS_INFO',
          );
        }

        final shouldRetry = currentRetry < retryCount && _shouldRetry(e);

        if (shouldRetry) {
          currentRetry++;

          if (logRequest && kDebugMode) {
            AppLogger.log(
              'Retrying Request ($currentRetry/$retryCount)',
              name: 'NETWORK_STATUS_INFO',
            );
          }

          await Future.delayed(retryDelay);

          continue;
        }

        return ApiResult.failure(ApiErrorHandler.handle(e));
      } catch (e, stackTrace) {
        if (logRequest && kDebugMode) {
          AppLogger.log(
            'Unknown Error: $e - Stack Trace: $stackTrace',
            name: 'NETWORK_STATUS_INFO',
          );
        }

        return ApiResult.failure(ApiErrorHandler.handle(e));
      }
    }
  }

  bool _shouldRetry(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  void _updateCachedConnection(bool status) {
    _lastConnectionStatus = status;
    _lastConnectionCheck = DateTime.now();
  }
}
