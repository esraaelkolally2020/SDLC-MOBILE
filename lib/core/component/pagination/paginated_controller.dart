// paginated_controller.dart (FIXED)
import 'package:flutter/material.dart';

enum PaginationStatus {
  initial,
  loading,
  success,
  error,
  loadingMore,
  refreshing,
}

class PaginationState<T> {
  final List<T> items;
  final PaginationStatus status;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  const PaginationState({
    this.items = const [],
    this.status = PaginationStatus.initial,
    this.errorMessage,
    this.hasMore = true,
    this.currentPage = 1,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    PaginationStatus? status,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
    bool clearError = false,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  bool get isLoading => status == PaginationStatus.loading;
  bool get isLoadingMore => status == PaginationStatus.loadingMore;
  bool get isRefreshing => status == PaginationStatus.refreshing;
  bool get hasError => status == PaginationStatus.error;
  bool get isEmpty => items.isEmpty && status == PaginationStatus.success;
  bool get isInitial => status == PaginationStatus.initial;
}

typedef FetchPageCallback<T> = Future<List<T>> Function(int page, int pageSize);
typedef OnRefreshCallback = Future<void> Function();

class PaginatedController<T> extends ValueNotifier<PaginationState<T>> {
  final FetchPageCallback<T> fetchPage;
  final int pageSize;
  final OnRefreshCallback? onRefreshCallback;

  PaginatedController({
    required this.fetchPage,
    this.pageSize = 10,
    this.onRefreshCallback,
  }) : super(const PaginationState());

  bool _isDisposed = false;
  bool _isFetching = false;

  /// Load initial data
  Future<void> loadInitialData() async {
    if (_isDisposed || _isFetching) return;

    try {
      _isFetching = true;

      // ✅ Set loading state IMMEDIATELY before any async work
      value = value.copyWith(
        status: PaginationStatus.loading,
        currentPage: 1,
        hasMore: true,
        clearError: true,
      );

      final items = await fetchPage(1, pageSize);

      if (_isDisposed) return;

      value = PaginationState<T>(
        items: items,
        status: PaginationStatus.success,
        hasMore: items.length >= pageSize,
        currentPage: items.length >= pageSize ? 2 : 1,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      if (_isDisposed) return;

      debugPrint('Error loading initial data: $e');
      debugPrintStack(stackTrace: stackTrace);

      value = value.copyWith(
        status: PaginationStatus.error,
        errorMessage: _extractErrorMessage(e),
      );
    } finally {
      _isFetching = false;
    }
  }

  /// Load next page
  Future<void> loadNextPage() async {
    // ✅ Check both _isFetching AND isLoadingMore to prevent race conditions
    if (_isDisposed || _isFetching || !value.hasMore || value.isLoadingMore) {
      return;
    }

    try {
      _isFetching = true;

      // ✅ Set loadingMore state IMMEDIATELY before any async work
      value = value.copyWith(
        status: PaginationStatus.loadingMore,
        clearError: true,
      );

      final newItems = await fetchPage(value.currentPage, pageSize);

      if (_isDisposed) return;

      final allItems = List<T>.from(value.items)..addAll(newItems);

      value = PaginationState<T>(
        items: allItems,
        status: PaginationStatus.success,
        hasMore: newItems.length >= pageSize,
        currentPage: newItems.length >= pageSize
            ? value.currentPage + 1
            : value.currentPage,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      if (_isDisposed) return;

      debugPrint('Error loading next page: $e');
      debugPrintStack(stackTrace: stackTrace);

      value = value.copyWith(
        status: PaginationStatus.error,
        errorMessage: _extractErrorMessage(e),
      );
    } finally {
      _isFetching = false;
    }
  }

  /// Refresh data (pull-to-refresh)
  Future<void> refresh() async {
    if (_isDisposed || _isFetching) return;

    try {
      // Reset data before Refresh,
      // you can comment it if you don't wanna to clear data before refreshing
      reset();

      _isFetching = true;

      // ✅ Set refreshing/loading state IMMEDIATELY
      if (value.items.isNotEmpty) {
        value = value.copyWith(
          status: PaginationStatus.refreshing,
          currentPage: 1,
          hasMore: true,
          clearError: true,
        );
      } else {
        value = value.copyWith(
          status: PaginationStatus.loading,
          currentPage: 1,
          hasMore: true,
          clearError: true,
        );
      }

      // Call custom refresh callback if provided
      if (onRefreshCallback != null) {
        await onRefreshCallback!();
      }

      final items = await fetchPage(1, pageSize);

      if (_isDisposed) return;

      value = PaginationState<T>(
        items: items,
        status: PaginationStatus.success,
        hasMore: items.length >= pageSize,
        currentPage: items.length >= pageSize ? 2 : 1,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      if (_isDisposed) return;

      debugPrint('Error refreshing data: $e');
      debugPrintStack(stackTrace: stackTrace);

      value = value.copyWith(
        status: PaginationStatus.error,
        errorMessage: _extractErrorMessage(e),
      );
    } finally {
      _isFetching = false;
    }
  }

  /// Retry after error
  Future<void> retryLastRequest() async {
    if (value.items.isEmpty) {
      await loadInitialData();
    } else {
      await loadNextPage();
    }
  }

  /// Update a single item
  void updateItem(int index, T item) {
    if (index >= 0 && index < value.items.length) {
      final updatedItems = List<T>.from(value.items);
      updatedItems[index] = item;
      value = value.copyWith(items: updatedItems);
    }
  }

  /// Remove an item
  void removeItem(int index) {
    if (index >= 0 && index < value.items.length) {
      final updatedItems = List<T>.from(value.items);
      updatedItems.removeAt(index);
      value = value.copyWith(items: updatedItems);
    }
  }

  /// Add an item at the beginning
  void prependItem(T item) {
    final updatedItems = [item, ...value.items];
    value = value.copyWith(items: updatedItems);
  }

  /// Add an item at the end
  void appendItem(T item) {
    final updatedItems = [...value.items, item];
    value = value.copyWith(items: updatedItems);
  }

  /// Replace all items
  void replaceItems(List<T> items) {
    value = value.copyWith(items: items);
  }

  /// Reset to initial state
  void reset() {
    if (_isDisposed) return;
    _isFetching = false;
    value = const PaginationState();
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
