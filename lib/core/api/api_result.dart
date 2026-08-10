import 'api_error_model.dart';

sealed class ApiResult<T> {
  const ApiResult();

  factory ApiResult.success(T data) = Success<T>;
  factory ApiResult.failure(ApiErrorModel failure) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiErrorModel error) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else {
      return failure((this as Failure<T>).apiErrorModel);
    }
  }

  R? whenOrNull<R>({
    R Function(T data)? success,
    R Function(ApiErrorModel error)? failure,
  }) {
    if (this is Success<T>) {
      return success?.call((this as Success<T>).data);
    } else {
      return failure?.call((this as Failure<T>).apiErrorModel);
    }
  }
}

class Success<T> extends ApiResult<T> {
  final T data;

  const Success(this.data);
}

class Failure<T> extends ApiResult<T> {
  final ApiErrorModel apiErrorModel;

  const Failure(this.apiErrorModel);
}
