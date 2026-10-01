import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

typedef PageRequestListener<PageKeyType> = void Function(PageKeyType pageKey);

class PagingController<PageKeyType, ItemType> extends ChangeNotifier {
  final PageKeyType? firstPageKey;

  /// Public state
  List<ItemType> itemList = [];
  String? error;

  /// Flags
  bool isFirstPageLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;

  /// Internal page state
  PageKeyType? _nextPageKey;

  /// Makes this controller safe globally after dispose.
  bool _disposed = false;

  bool get isDisposed => _disposed;

  bool get canUse => !_disposed;

  final List<PageRequestListener<PageKeyType>> _pageRequestListeners = [];

  PagingController({
    required this.firstPageKey,
    PageKeyType? initialNextPageKey,
  }) : _nextPageKey = initialNextPageKey ?? firstPageKey;

  void _safeNotifyListeners() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    if (_disposed) return;
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    if (_disposed) return;
    super.removeListener(listener);
  }

  void addPageRequestListener(PageRequestListener<PageKeyType> listener) {
    if (_disposed) return;
    _pageRequestListeners.add(listener);
  }

  void removePageRequestListener(PageRequestListener<PageKeyType> listener) {
    if (_disposed) return;
    _pageRequestListeners.remove(listener);
  }

  void _callPageRequestListeners(PageKeyType pageKey) {
    if (_disposed) return;

    final listeners = List<PageRequestListener<PageKeyType>>.from(
      _pageRequestListeners,
    );

    for (final listener in listeners) {
      if (_disposed) return;

      try {
        listener(pageKey);
      } catch (_) {
        /// Keep the controller safe from listener errors.
      }
    }
  }

  /// Called by the view to request the first page or refresh.
  void refresh() {
    if (_disposed) return;

    error = null;
    isFirstPageLoading = true;
    isLoadingMore = false;
    hasMore = true;
    itemList = [];
    _nextPageKey = firstPageKey;

    _safeNotifyListeners();

    final pageKey = _nextPageKey;
    if (pageKey != null && !_disposed) {
      _callPageRequestListeners(pageKey);
    }
  }

  void clearOldController() {
    if (_disposed) return;

    itemList = [];
    isFirstPageLoading = false;
    isLoadingMore = false;
    hasMore = true;
    error = null;
    _nextPageKey = firstPageKey;

    _safeNotifyListeners();
  }

  void switchAndRefresh() {
    if (_disposed) return;

    itemList = [];
    isFirstPageLoading = false;
    isLoadingMore = false;
    hasMore = true;
    error = null;

    _safeNotifyListeners();
    refresh();
  }

  void clearAndRefresh() {
    if (_disposed) return;

    itemList = [];
    isFirstPageLoading = false;
    isLoadingMore = false;
    hasMore = true;
    error = null;
    _nextPageKey = firstPageKey;

    _safeNotifyListeners();
    refresh();
  }

  /// Called by the view to request the next page.
  void requestNextPage() {
    if (_disposed) return;
    if (!hasMore || isLoadingMore || isFirstPageLoading) return;

    isLoadingMore = true;
    error = null;

    _safeNotifyListeners();

    final pageKey = _nextPageKey;
    if (pageKey != null && !_disposed) {
      _callPageRequestListeners(pageKey);
    }
  }

  /// Append a page and provide the next page key.
  void appendPage(List<ItemType> newItems, PageKeyType? nextPageKey) {
    if (_disposed) return;

    isFirstPageLoading = false;
    isLoadingMore = false;
    error = null;

    itemList.addAll(newItems);
    _nextPageKey = nextPageKey;
    hasMore = nextPageKey != null;

    _safeNotifyListeners();
  }

  /// Append last page.
  void appendLastPage(List<ItemType> newItems) {
    if (_disposed) return;

    isFirstPageLoading = false;
    isLoadingMore = false;
    error = null;

    itemList.addAll(newItems);
    _nextPageKey = null;
    hasMore = false;

    _safeNotifyListeners();
  }

  /// Set error for first page or next page.
  void setError(String err, {bool isFirstPage = false}) {
    if (_disposed) return;

    error = err;
    isFirstPageLoading = false;
    isLoadingMore = false;

    _safeNotifyListeners();
  }

  /// Retry last failed request.
  void retryLastFailed() {
    if (_disposed) return;

    if (itemList.isEmpty) {
      refresh();
    } else {
      requestNextPage();
    }
  }

  bool get isEmpty => itemList.isEmpty;

  @override
  void dispose() {
    if (_disposed) return;

    _disposed = true;

    _pageRequestListeners.clear();
    itemList = [];
    error = null;
    isFirstPageLoading = false;
    isLoadingMore = false;
    hasMore = false;
    _nextPageKey = null;

    super.dispose();
  }
}

typedef ItemBuilder<ItemType> = Widget Function(
  BuildContext context,
  ItemType item,
  int index,
);

typedef IndicatorBuilder = Widget Function(BuildContext context);

class PagedChildBuilderDelegate<PageKeyType, ItemType> {
  final ItemBuilder<ItemType> itemBuilder;

  /// Builders for different states.
  final IndicatorBuilder? noItemsFoundIndicatorBuilder;
  final IndicatorBuilder? firstPageErrorIndicatorBuilder;
  final IndicatorBuilder? newPageErrorIndicatorBuilder;
  final IndicatorBuilder? newPageProgressIndicatorBuilder;
  final IndicatorBuilder? firstPageProgressIndicatorBuilder;

  /// Optional footer.
  final WidgetBuilder? footerBuilder;

  const PagedChildBuilderDelegate({
    required this.itemBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.footerBuilder,
  });
}

/// Highly customizable PagedListView which listens to PagingController.
class PagedListView<PageKeyType, ItemType> extends StatefulWidget {
  final PagingController<PageKeyType, ItemType> pagingController;
  final PagedChildBuilderDelegate<PageKeyType, ItemType> builderDelegate;

  /// Called when view needs the next offset/page key.
  /// NOT necessary if your controller registers a page request listener.
  final double fetchThreshold;

  /// Layout options.
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool reverse;
  final bool useGrid;
  final SliverGridDelegate? gridDelegate;
  final ScrollController? externalScrollController;
  final bool showScrollBar;
  final Widget? separator;
  final bool allowImplicitScroll;

  const PagedListView({
    super.key,
    required this.pagingController,
    required this.builderDelegate,
    this.fetchThreshold = 0.9,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.reverse = false,
    this.useGrid = false,
    this.gridDelegate,
    this.externalScrollController,
    this.showScrollBar = false,
    this.separator,
    this.allowImplicitScroll = false,
  });

  @override
  State<PagedListView<PageKeyType, ItemType>> createState() =>
      _PagedListViewState<PageKeyType, ItemType>();
}

class _PagedListViewState<PageKeyType, ItemType>
    extends State<PagedListView<PageKeyType, ItemType>> {
  late PagingController<PageKeyType, ItemType> _controller;
  late ScrollController _scrollController;

  bool get _ownsScrollController => widget.externalScrollController == null;

  @override
  void initState() {
    super.initState();

    _controller = widget.pagingController;
    _scrollController = widget.externalScrollController ?? ScrollController();

    _scrollController.addListener(_onScroll);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(
    covariant PagedListView<PageKeyType, ItemType> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pagingController != widget.pagingController) {
      oldWidget.pagingController.removeListener(_onControllerChanged);

      _controller = widget.pagingController;
      _controller.addListener(_onControllerChanged);
    }

    if (oldWidget.externalScrollController != widget.externalScrollController) {
      _scrollController.removeListener(_onScroll);

      if (oldWidget.externalScrollController == null) {
        _scrollController.dispose();
      }

      _scrollController = widget.externalScrollController ?? ScrollController();
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);

    if (_ownsScrollController) {
      _scrollController.dispose();
    }

    _controller.removeListener(_onControllerChanged);

    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onScroll() {
    if (!mounted) return;
    if (_controller.isDisposed) return;
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll <= 0) return;

    if (currentScroll >= maxScroll * widget.fetchThreshold) {
      _controller.requestNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final delegate = widget.builderDelegate;
    final error = _controller.error;
    final isFirstPageLoading = _controller.isFirstPageLoading;
    final isLoadingMore = _controller.isLoadingMore;
    final items = _controller.itemList;

    /// First page error.
    if (items.isEmpty && error != null) {
      return delegate.firstPageErrorIndicatorBuilder?.call(context) ??
          Center(child: Text('something_went_wrong'.tr()));
    }

    /// First page loading.
    if (items.isEmpty && isFirstPageLoading) {
      return delegate.firstPageProgressIndicatorBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }

    /// No items.
    if (items.isEmpty && !isFirstPageLoading && error == null) {
      return delegate.noItemsFoundIndicatorBuilder?.call(context) ??
          Center(child: Text('no_data_available'.tr()));
    }

    final itemCount = items.length + ((isLoadingMore || error != null) ? 1 : 0);

    final Widget listView;

    if (widget.useGrid) {
      final gridDelegate =
          widget.gridDelegate ??
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2);

      listView = GridView.builder(
        controller: _scrollController,
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        reverse: widget.reverse,
        gridDelegate: gridDelegate,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return _itemBuilder(index, items, delegate, error, isLoadingMore);
        },
      );
    } else {
      if (widget.separator != null) {
        listView = ListView.separated(
          controller: _scrollController,
          padding: widget.padding,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          reverse: widget.reverse,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return _itemBuilder(index, items, delegate, error, isLoadingMore);
          },
          separatorBuilder: (context, index) => widget.separator!,
        );
      } else {
        listView = ListView.builder(
          controller: _scrollController,
          padding: widget.padding,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          reverse: widget.reverse,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return _itemBuilder(index, items, delegate, error, isLoadingMore);
          },
        );
      }
    }

    return widget.showScrollBar ? Scrollbar(child: listView) : listView;
  }

  Widget _itemBuilder(
    int index,
    List<ItemType> items,
    PagedChildBuilderDelegate<PageKeyType, ItemType> delegate,
    String? error,
    bool isLoadingMore,
  ) {
    if (index < items.length) {
      return delegate.itemBuilder(context, items[index], index);
    }

    /// Bottom slot: loader or error.
    if (isLoadingMore) {
      return delegate.newPageProgressIndicatorBuilder?.call(context) ??
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
    }

    if (error != null) {
      return delegate.newPageErrorIndicatorBuilder?.call(context) ??
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(child: Text('something_went_wrong'.tr())),
          );
    }

    return const SizedBox.shrink();
  }
}

class PagedSliverList<PageKeyType, ItemType> extends StatefulWidget {
  final PagingController<PageKeyType, ItemType> pagingController;
  final PagedChildBuilderDelegate<PageKeyType, ItemType> builderDelegate;
  final double fetchThreshold;

  const PagedSliverList({
    super.key,
    required this.pagingController,
    required this.builderDelegate,
    this.fetchThreshold = 0.9,
  });

  @override
  State<PagedSliverList<PageKeyType, ItemType>> createState() =>
      _PagedSliverListState<PageKeyType, ItemType>();
}

class _PagedSliverListState<PageKeyType, ItemType>
    extends State<PagedSliverList<PageKeyType, ItemType>> {
  late PagingController<PageKeyType, ItemType> pagingController;

  @override
  void initState() {
    super.initState();

    pagingController = widget.pagingController;
    pagingController.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(
    covariant PagedSliverList<PageKeyType, ItemType> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pagingController != widget.pagingController) {
      oldWidget.pagingController.removeListener(_onControllerChanged);

      pagingController = widget.pagingController;
      pagingController.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    pagingController.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = pagingController.itemList;
    final delegate = widget.builderDelegate;

    if (items.isEmpty) {
      if (pagingController.error != null) {
        return SliverToBoxAdapter(
          child:
              delegate.firstPageErrorIndicatorBuilder?.call(context) ??
              Center(child: Text('something_went_wrong'.tr())),
        );
      }

      if (pagingController.isFirstPageLoading) {
        return SliverToBoxAdapter(
          child:
              delegate.firstPageProgressIndicatorBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator()),
        );
      }

      return SliverToBoxAdapter(
        child:
            delegate.noItemsFoundIndicatorBuilder?.call(context) ??
            Center(child: Text('no_data_available'.tr())),
      );
    }

    final total = items.length + (pagingController.hasMore ? 1 : 0);

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index < items.length) {
          return delegate.itemBuilder(context, items[index], index);
        }

        /// Bottom loader triggers next page automatically.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (pagingController.isDisposed) return;

          if (pagingController.hasMore &&
              !pagingController.isFirstPageLoading &&
              !pagingController.isLoadingMore) {
            pagingController.requestNextPage();
          }
        });

        if (pagingController.isLoadingMore) {
          return delegate.newPageProgressIndicatorBuilder?.call(context) ??
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
        }

        if (pagingController.error != null) {
          return delegate.newPageErrorIndicatorBuilder?.call(context) ??
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: Text('something_went_wrong'.tr())),
              );
        }

        return const SizedBox.shrink();
      }, childCount: total),
    );
  }
}
