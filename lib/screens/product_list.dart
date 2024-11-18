import 'package:flutter/material.dart';
import 'package:grocy/main.dart';
import 'package:grocy/widget/search_widget.dart';
import '../models/product.dart';
import 'product_screen.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  ProductListState createState() => ProductListState();
}

// The state of the ProductList widget.
class ProductListState extends State<ProductList> {
  // Holds a list from supabase that updates (through queries etc)
  List<Product> supabaseProducts = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  /// Fetches all the products from supabase.
  /// TODO: connect it to tags.
  Future<void> fetchProducts({String query = ''}) async {
    List<Product> productsFromSupabase = [];

    try {
      var supabaseQuery = supabase.from('products').select();

      // Add query filtering
      if (query.isNotEmpty) {
        supabaseQuery = supabaseQuery.ilike('name', '%$query%');
      }

      // Fetch product data
      final List<dynamic> data = await supabaseQuery;

      // Parse the data into Product objects
      productsFromSupabase = data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      debugPrint('Error fetching products: $error');
      // Optional: Handle the error (e.g., show a message or retry)
    }

    // Update state after fetching products
    setState(() {
      supabaseProducts = productsFromSupabase;
    });
  }

  // Filter the products based on query in the search bar.
  void _filterProducts(String query) {
    fetchProducts(query: query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SearchWidget(
            onQuery: _filterProducts,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: supabaseProducts.length,
              itemBuilder: (context, index) {
                final product = supabaseProducts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductScreen(product: product),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // ClipRRect is used to clip the image to a rounded rectangle
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            product.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 16, color: Colors.amber),
                                  Text(
                                    "50 reviews",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
