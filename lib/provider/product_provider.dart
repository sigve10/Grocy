import 'package:flutter/material.dart';import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/main.dart';
import 'package:grocy/models/product.dart';
import 'package:grocy/provider/search_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// https://www.youtube.com/watch?v=5RoCKuJaYPU

// The flutter-supabase docs, the Database section has decent documentation on how to do get/insert/delete requests via database.
// https://supabase.com/docs/reference/dart/introduction

final productProvider = StateNotifierProvider<ProductProvider, List<Product>>(
  (ref) => ProductProvider(ref)
);

class ProductProvider extends StateNotifier<List<Product>> {
  final Ref ref;
  ProductProvider(this.ref) : super(const []) {
    ref.listen(searchProvider, (oldValue, newValue) {
      fetchProducts();
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
}