import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/domain/homepage_product_sections.dart';

void main() {
  test('old published homepage configuration falls back to real products', () async {
    final payload = jsonDecode(File('test/fixtures/customer_homepage_20261012.json').readAsStringSync()) as Map<String, dynamic>;
    final latest = jsonDecode(File('test/fixtures/customer_products_20261012.json').readAsStringSync()) as Map<String, dynamic>;
    final sections = await readHomepageProductSections(payload, () async => latest);
    expect(sections.first['products'], hasLength(7));
    for (final section in sections) {
      for (final row in section['products'] as List) {
        expect(Product.fromJson(Map<String, dynamic>.from(row)).name, isNotEmpty);
      }
    }
  });
  test('explicit empty sections are preserved', () async {
    expect(await readHomepageProductSections({'product_sections': []}, () async => throw StateError('must not fetch')), isEmpty);
  });
  test('reads the real guest product response without losing products', () {
    final payload = jsonDecode(File('test/fixtures/customer_products_20261012.json').readAsStringSync()) as Map<String, dynamic>;
    final products = ProductModel.fromJson(payload);
    expect(products.products!.length, (payload['products'] as List).length);
    expect(products.products!.first.name, isNotEmpty);
  });
}
