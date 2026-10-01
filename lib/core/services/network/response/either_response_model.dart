import '../error/network_exception.dart';

sealed class EitherResponse<T> {
  const EitherResponse();

  R fold<R>(
    R Function(NetworkException error) onError,
    R Function(T? data) onSuccess,
  ) {
    return switch (this) {
      ResponseSuccess<T>(data: final data) => onSuccess(data),
      ResponseFailure<T>(error: final error) => onError(error),
    };
  }

  Future<R> asyncFold<R>(
    Future<R> Function(NetworkException error) onError,
    Future<R> Function(T? data) onSuccess,
  ) async {
    return switch (this) {
      ResponseSuccess<T>(data: final data) => await onSuccess(data),
      ResponseFailure<T>(error: final error) => await onError(error),
    };
  }

  bool get isSuccess => this is ResponseSuccess<T>;

  bool get isFailure => this is ResponseFailure<T>;

  T? get dataOrNull {
    final current = this;

    if (current is ResponseSuccess<T>) {
      return current.data;
    }

    return null;
  }

  NetworkException? get errorOrNull {
    final current = this;

    if (current is ResponseFailure<T>) {
      return current.error;
    }

    return null;
  }
}

class ResponseSuccess<T> extends EitherResponse<T> {
  final T? data;

  const ResponseSuccess({required this.data});
}

class ResponseFailure<T> extends EitherResponse<T> {
  final NetworkException error;

  const ResponseFailure({required this.error});
}
