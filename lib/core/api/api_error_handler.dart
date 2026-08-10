import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import 'api_error_model.dart';

class ApiErrorHandler {
  static ApiErrorModel handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionError:
          return ApiErrorModel(message: 'connection_to_server_failed'.tr());

        case DioExceptionType.cancel:
          return ApiErrorModel(message: 'request_to_server_was_cancelled'.tr());

        case DioExceptionType.connectionTimeout:
          return ApiErrorModel(message: 'connection_timeout_with_server'.tr());

        case DioExceptionType.sendTimeout:
          return ApiErrorModel(
            message: 'send_timeout_in_connection_with_server'.tr(),
          );

        case DioExceptionType.receiveTimeout:
          return ApiErrorModel(
            message: 'receive_timeout_in_connection_with_server'.tr(),
          );

        case DioExceptionType.unknown:
          return ApiErrorModel(
            message: 'connection_to_server_failed_due_to_internet_connection'
                .tr(),
          );

        case DioExceptionType.badResponse:
          return _handleBadResponse(error);

        default:
          return ApiErrorModel(message: 'something_went_wrong'.tr());
      }
    }

    return ApiErrorModel(
      message: 'unknown_error_occurred'.tr(),
      errors: {
        'error': [error.toString()],
      },
    );
  }

  static ApiErrorModel _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (statusCode == 401) {
      return ApiErrorModel(message: 'unauthorized_access'.tr());
    }

    if (statusCode != null && statusCode >= 500) {
      return ApiErrorModel(message: 'server_error_occurred'.tr());
    }

    if (data is Map<String, dynamic>) {
      return ApiErrorModel(
        message: data['message']?.toString() ?? 'something_went_wrong'.tr(),
        errors: (data['errors'] as Map?)?.map(
          (key, value) =>
              MapEntry(key.toString(), List<String>.from(value ?? [])),
        ),
      );
    }

    return ApiErrorModel(message: 'something_went_wrong'.tr());
  }
}
