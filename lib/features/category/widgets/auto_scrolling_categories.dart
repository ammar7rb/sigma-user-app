import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/widgets/category_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';

class AutoScrollingCategories extends StatefulWidget {
  final List<CategoryModel> categories;
  final bool automatic;
  const AutoScrollingCategories(
      {super.key, required this.categories, required this.automatic});
  @override
  State<AutoScrollingCategories> createState() =>
      _AutoScrollingCategoriesState();
}

class _AutoScrollingCategoriesState extends State<AutoScrollingCategories>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  late final AnimationController _clock;
  Duration? _last;
  bool _hovered = false;
  bool _dragging = false;
  @override
  void initState() {
    super.initState();
    _clock =
        AnimationController(vsync: this, duration: const Duration(hours: 1))
          ..addListener(_tick)
          ..repeat();
  }

  void _tick() {
    final now = _clock.lastElapsedDuration ?? Duration.zero;
    final elapsed =
        _last == null ? 0.0 : (now - _last!).inMicroseconds / 1000000;
    _last = now;
    if (!widget.automatic ||
        _hovered ||
        _dragging ||
        widget.categories.length < 2 ||
        !_scroll.hasClients ||
        MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    final cycle = widget.categories.length * 98.0;
    final offset = _scroll.offset + elapsed.clamp(0.0, .1) * 12;
    _scroll.jumpTo(offset >= cycle * 2
        ? offset - cycle
        : offset.clamp(0.0, _scroll.position.maxScrollExtent));
  }

  @override
  void dispose() {
    _clock.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
      onEnter: (_) => _hovered = true,
      onExit: (_) => _hovered = false,
      child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification &&
                notification.dragDetails != null) {
              _dragging = true;
            }
            if (notification is ScrollEndNotification) {
              _dragging = false;
            }
            return false;
          },
          child: SizedBox(
              height: 126,
              child: ListView.builder(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                itemExtent: 98,
                itemCount: widget.categories.length *
                    (widget.automatic && widget.categories.length > 1 ? 3 : 1),
                itemBuilder: (context, index) {
                  final category =
                      widget.categories[index % widget.categories.length];
                  return InkWell(
                      onTap: () => RouterHelper.getBrandCategoryRoute(
                          action: RouteAction.push,
                          isBrand: false,
                          id: category.id,
                          name: category.name),
                      child: CategoryWidget(
                          category: category,
                          index: index % widget.categories.length,
                          length: widget.categories.length));
                },
              ))));
}
