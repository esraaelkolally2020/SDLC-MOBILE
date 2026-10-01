import 'package:equatable/equatable.dart';

/// Base class for every Cubit state in the app.
///
/// Features emit these generic states (or their own subclasses) so UI code
/// can rely on a shared vocabulary: initial → loading → loaded/empty/error.
abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];
}

class InitialState extends BaseState {
  const InitialState({this.count});
  final int? count;

  @override
  List<Object?> get props => [count];
}

class LoadingState extends BaseState {
  final DateTime timestamp;
  LoadingState() : timestamp = DateTime.now();
  @override
  List<Object> get props => [timestamp]; // always unique
}

class ErrorState extends BaseState {
  const ErrorState(this.data);
  final dynamic data;

  @override
  List<Object?> get props => [data];
}

class LoadedState<T> extends BaseState {
  const LoadedState(
    this.data, {
    this.mappedData,
    this.canPop = false,
    this.isHidden = true,
  });

  final T? data;
  final bool? canPop;
  final dynamic mappedData;
  final bool isHidden;

  @override
  List<Object?> get props => [data, mappedData, canPop, isHidden];

  LoadedState<T> copyWith({
    T? data,
    bool? canPop,
    dynamic mappedData,
    bool? isHidden,
  }) {
    return LoadedState<T>(
      data ?? this.data,
      mappedData: mappedData ?? this.mappedData,
      canPop: canPop ?? this.canPop,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}

class EmptyState<T> extends BaseState {
  const EmptyState(this.data);

  final T? data;

  @override
  List<Object?> get props => [data];
}

class ButtonEnabledState extends BaseState {
  final DateTime timestamp;
  ButtonEnabledState() : timestamp = DateTime.now();
  @override
  List<Object> get props => [timestamp]; // always unique
}

class ButtonDisabledState extends BaseState {
  final DateTime timestamp;
  ButtonDisabledState() : timestamp = DateTime.now();
  @override
  List<Object> get props => [timestamp]; // always unique
}

class ButtonLoadingState extends BaseState {
  final bool isFirstButtonLoading;
  const ButtonLoadingState({this.isFirstButtonLoading = true});

  @override
  List<Object?> get props => [isFirstButtonLoading];
}

/// Validation failed; [errors] maps field keys to messages.
class FormInvalidState extends BaseState {
  final Map<String, String> errors;
  const FormInvalidState(this.errors);

  @override
  List<Object?> get props => [errors];
}

class DataHiddenState extends BaseState {
  final bool isHidden;
  const DataHiddenState(this.isHidden);

  @override
  List<Object> get props => [isHidden];
}

/// A one-shot action (submit, delete, ...) completed successfully.
class RequestDoneState extends BaseState {
  const RequestDoneState();
}
