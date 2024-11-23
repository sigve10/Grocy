import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/provider/product_provider.dart';
import 'package:grocy/widget/product_tile.dart';
import 'package:grocy/widget/search_widget.dart';
import '../models/product.dart';

/// Displays a list of products with search functionality through [SearchWidget].
class ProductList extends ConsumerStatefulWidget {
  const ProductList({super.key});

  @override
  ProductListState createState() => ProductListState();
}

/// The state of the ProductList widget.
class ProductListState extends ConsumerState<ProductList> {
  // Holds a list from supabase that updates (through queries etc)

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).fetchProducts();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Product> products = ref.watch(productProvider);
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 35),
          SearchWidget(),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                // Will change Rating name to Review shortly.
                // Connects review's EAN to the product EAN to check which product the review belongs to 🤓
                return ProductTile(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}
