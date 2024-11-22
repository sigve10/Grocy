import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/main.dart';
import 'package:grocy/models/product.dart';
import 'package:grocy/provider/search_provider.dart';
import '../models/tag.dart';

// https://www.youtube.com/watch?v=5RoCKuJaYPU

// The flutter-supabase docs, the Database section has decent documentation on how to do get/insert/delete requests via database.
// https://supabase.com/docs/reference/dart/introduction

final productProvider = StateNotifierProvider<ProductProvider, List<Product>>(
    (ref) => ProductProvider(ref));

class ProductProvider extends StateNotifier<List<Product>> {
  final Ref ref;
  ProductProvider(this.ref) : super(const []) {
    ref.listen(searchProvider, (oldValue, newValue) {
      print("Provider updated");
      fetchProducts();
    });
  }

  Future<Product> fetchProduct(String barcode, context) async {
    final res = await supabase.functions.invoke("fetch-product",
        body: {"ean": barcode},
        headers: {"Content-Type": "application/json"},
        method: HttpMethod.post);

    final productJson = res.data as Map<String, dynamic>;
    Product product = Product.fromJson(productJson);

    if (product.ean.isEmpty) {
      throw FunctionException(status: 404, details: {"error": "Product not found"});
    }

    return product;
  }

  void addProduct(Product product) async {
    await supabase.from('products').insert({
      'ean': product.ean,
      'name': product.name,
      'description': product.description,
      'imageurl': product.imageUrl,
      'primary_tag': product.primaryTag
    });
  }

  void fetchProducts() async {
    SearchState searchState = ref.read(searchProvider);

    print(searchState.userTags.map((e) => e.name).toList());

    Map<String, dynamic> queryParams = {
      "i_search_term": searchState.searchText,
      "i_primary_tag": searchState.mainTag?.name,
      "i_user_tags": searchState.userTags.isNotEmpty ?
        searchState.userTags.map((e) => e.name).toList() : null
    };

    var query = supabase.rpc(
      "get_products_by_search",
      params: queryParams
    );

    try {
      List<dynamic> response = await query;
      List<Product> products = response
        .map((item) => Product.fromJson(item))
        .toList();

      state = products;
    } catch(error) {
      debugPrint("Error fetching products: $error");
      debugPrintStack();
    }
  }

  Future<List<Tag>> fetchTagsForProduct(String productEan) async {
    final response = await supabase
        .from('product_tags')
        .select()
        .eq('product_ean', productEan);

    final result = (response as List)
        .map((tagData) => Tag(name: tagData['tag_name'] as String))
        .toList();
    return result;
  }
}