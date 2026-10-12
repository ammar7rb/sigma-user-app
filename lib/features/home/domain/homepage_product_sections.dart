import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';

/// Older published layout responses contain configuration only. Load the real
/// catalogue in that case; an explicitly empty sections list stays empty.
Future<List<Map<String, dynamic>>> readHomepageProductSections(
    Map<String, dynamic> layout,
    Future<Map<String, dynamic>> Function() loadLatest) async {
  final sections = layout['product_sections'];
  if (sections is List) {
    return sections.map((row) => Map<String, dynamic>.from(row)).toList();
  }
  final latest = await loadLatest();
  final parsed = ProductModel.fromJson(latest);
  return [
    {
      'key': 'latest_products',
      'products': parsed.products?.map((p) => p.toJson()).toList() ?? []
    }
  ];
}
