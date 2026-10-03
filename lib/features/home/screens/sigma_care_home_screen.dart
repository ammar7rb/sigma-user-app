import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/banners_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/widgets/category_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/screens/home_screens.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/search_home_page_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/favourite_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';

class SigmaCareHomeScreen extends StatefulWidget {
  const SigmaCareHomeScreen({super.key});
  @override
  State<SigmaCareHomeScreen> createState() => _SigmaCareHomeScreenState();
}

class _SigmaCareHomeScreenState extends State<SigmaCareHomeScreen> {
  List<Map<String, dynamic>>? _sections;
  bool _failed = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response =
          await di.sl<DioClient>().get('/api/v1/banners/homepage-layout');
      final data = response.data['product_sections'] as List;
      if (mounted) {
        setState(() {
          _sections = data.map((e) => Map<String, dynamic>.from(e)).toList();
          _failed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arabic = Directionality.of(context) == TextDirection.rtl;
    const labels = {
      'latest_products': ['أحدث المنتجات', 'Latest Products'],
      'featured_products': ['المنتجات المميزة', 'Featured Products'],
      'featured_deals': ['اشتري ووفر', 'Shop & Save'],
      'savings_offers': ['عروض التوفير', 'Savings Offers'],
    };
    return SafeArea(
        child: RefreshIndicator(
            onRefresh: () async {
              await HomePage.loadData(true);
              await _load();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text('SIGMA',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).primaryColor))),
                InkWell(
                    onTap: () =>
                        RouterHelper.getSearchRoute(action: RouteAction.push),
                    child: const SearchHomePageWidget()),
                BannersWidget(),
                const CategoryListWidget(isHomePage: true),
                if (_sections == null && !_failed)
                  const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator())),
                if (_failed)
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextButton(
                          onPressed: _load,
                          child: Text(arabic
                              ? 'تعذر تحميل المنتجات. إعادة المحاولة'
                              : 'Could not load products. Retry'))),
                for (final section in _sections ?? <Map<String, dynamic>>[])
                  if ((section['products'] as List).isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text(
                                      labels[section['key']]?[arabic ? 0 : 1] ??
                                          section['title'] as String,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700))),
                              const SizedBox(height: 12),
                              _CareProductRail(
                                  products: (section['products'] as List)
                                      .map((p) => Product.fromJson(p))
                                      .toList()),
                            ])),
                const SizedBox(height: 28),
              ],
            )));
  }
}

class _CareProductRail extends StatefulWidget {
  final List<Product> products;
  const _CareProductRail({required this.products});
  @override
  State<_CareProductRail> createState() => _CareProductRailState();
}

class _CareProductRailState extends State<_CareProductRail>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  late final AnimationController _clock;
  Duration? _previous;
  bool _paused = false;
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
    final seconds =
        _previous == null ? 0.0 : (now - _previous!).inMicroseconds / 1000000;
    _previous = now;
    if (_paused ||
        !_scroll.hasClients ||
        widget.products.length < 2 ||
        MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    final cycle = widget.products.length * 232.0;
    final next = _scroll.offset + seconds.clamp(0.0, .1) * 22;
    _scroll.jumpTo(next >= cycle * 2
        ? next - cycle
        : next.clamp(0.0, _scroll.position.maxScrollExtent));
  }

  @override
  void dispose() {
    _clock.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
      onEnter: (_) => _paused = true,
      onExit: (_) => _paused = false,
      child: Listener(
        onPointerDown: (_) => _paused = true,
        onPointerUp: (_) => _paused = false,
        onPointerCancel: (_) => _paused = false,
        child: SizedBox(
            height: 310,
            child: ListView.separated(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.products.length < 2
                  ? widget.products.length
                  : widget.products.length * 3,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (_, index) => SizedBox(
                  width: 220,
                  child: _CareProductCard(
                      product:
                          widget.products[index % widget.products.length])),
            )),
      ));
}

class _CareProductCard extends StatelessWidget {
  final Product product;
  const _CareProductCard({required this.product});
  @override
  Widget build(BuildContext context) {
    final discounted = (product.discount ?? 0) > 0;
    return Material(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: .15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => RouterHelper.getProductDetailsRoute(
            action: RouteAction.push,
            productId: product.id,
            slug: product.slug ?? ''),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Stack(children: [
            Padding(
                padding: const EdgeInsets.all(12),
                child: CustomImageWidget(
                    image: product.thumbnailFullUrl?.path ?? '',
                    height: 176,
                    width: double.infinity,
                    fit: BoxFit.contain)),
            PositionedDirectional(
                top: 10,
                end: 10,
                child: SizedBox(
                    width: 34,
                    height: 34,
                    child: FavouriteButtonWidget(productId: product.id))),
          ]),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(product.name ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, height: 1.4, fontWeight: FontWeight.w600))),
          const Spacer(),
          Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (discounted)
                      Text(
                          PriceConverter.convertPrice(
                              context, product.unitPrice),
                          style: TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color)),
                    Text(
                        PriceConverter.convertPrice(context, product.unitPrice,
                            discount: product.discount,
                            discountType: product.discountType),
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor)),
                  ])),
        ]),
      ),
    );
  }
}
