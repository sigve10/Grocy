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
      print("Provider updated"); 
      fetchProducts();
    });
  }

  void fetchProducts() async {
    SearchState searchState = ref.read(searchProvider);

    var query = supabase
      .from("products")
      .select("*");

    if (searchState.searchText.isNotEmpty) {
      query = query.ilike("name", "%${searchState.searchText}%");
    }

    print(searchState.mainTag);
    if (searchState.mainTag != null) {
      query = query.eq("primary_tag", searchState.mainTag!.name);
    }

    if (searchState.userTags.isNotEmpty) {
      query = query.contains("tag(name)", searchState.userTags.map((e) => e.name));
    }

    try {
      PostgrestList response = await query;
      List<Product> products = (response as List<dynamic>)
        .map((item) => Product.fromJson(item))
        .toList();

      state = products;
    } catch(error) {
      debugPrint("Error fetching products: $error");
    }
  }
}