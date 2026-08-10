import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../common/app/app_loading_indicator.dart';
import '../theme/theme_manager/theme_extensions.dart';
import 'app_logger.dart';
import 'dimensions_helper.dart';

class AppPaginatedScroll<T> extends StatefulWidget {
  const AppPaginatedScroll({
    super.key,
    this.enabled = true,
    required this.items,
    required this.getPaginatedItems,
    required this.builder,
    this.onRefresh,
    this.onPagesFinished,
    this.initialPage = 1,
    this.paginationThreshold = 300,
    this.controller,
  });

  final bool enabled;
  final List<T> items;
  final Future<List<T>> Function(int page) getPaginatedItems;
  final Future<void> Function()? onRefresh;
  final void Function(int lastPage)? onPagesFinished;
  final int initialPage;
  final double paginationThreshold;
  final ScrollController? controller;
  final Widget Function(BuildContext context, ScrollController controller)
  builder;

  @override
  State<AppPaginatedScroll<T>> createState() => _AppPaginatedScrollState<T>();
}

class _AppPaginatedScrollState<T> extends State<AppPaginatedScroll<T>> {
  late final ScrollController _controller;

  int _page = 1;

  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();

    _page = widget.initialPage;
    _controller = widget.controller ?? ScrollController();

    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);

    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  void _onScroll() {
    if (!widget.enabled) return;
    if (!_controller.hasClients) return;

    if (_isLoadingMore || _isRefreshing || !_hasMore) return;

    final remaining =
        _controller.position.maxScrollExtent - _controller.position.pixels;

    if (remaining <= widget.paginationThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _isRefreshing || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _page + 1;
      final result = await widget.getPaginatedItems(nextPage);

      if (!mounted) return;

      if (result.isEmpty) {
        _hasMore = false;
        widget.onPagesFinished?.call(_page);
      } else {
        _page = nextPage;

        widget.items.addAll(result);
      }
    } catch (error, stackTrace) {
      AppLogger.log(
        'Pagination load error: $error - Stack Trace: $stackTrace',
        name: 'APP_PAGINATED_SCROLL',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _page = widget.initialPage;
      _hasMore = true;
      widget.items.clear();
    });

    try {
      if (widget.onRefresh != null) {
        await widget.onRefresh!();
      } else {
        final result = await widget.getPaginatedItems(widget.initialPage);

        widget.items.addAll(result);
      }
    } catch (error, stackTrace) {
      AppLogger.log(
        'Refresh error: $error - Stack Trace: $stackTrace',
        name: 'APP_PAGINATED_SCROLL',
      );
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: context.customAppColors.primary600,
      backgroundColor: context.customAppColors.primary50,
      child: Stack(
        children: [
          widget.builder(context, _controller),

          if (_isLoadingMore && !_isRefreshing)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    height: 70,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          context.customAppColors.primary600.withValues(
                            alpha: 0.35,
                          ),
                          context.customAppColors.primary600.withValues(
                            alpha: 0.10,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.radius),
                      child: AppLoadingIndicator(
                        color: context.customAppColors.primary600,
                        size: 22.radius,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
