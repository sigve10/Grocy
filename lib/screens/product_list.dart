import 'package:flutter/material.dart';
import 'package:grocy/main.dart';
import 'package:grocy/models/tag.dart';
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

  /// Fetches products based on the query and selected tag.
  Future<void> fetchProducts({String query = '', Tag? selectedTag}) async {
    // Everything under can throw errors
    try {
      // Select from the product_details view function within supabase, all products that has a valid tag.
      var supabaseQuery = supabase.from('product_details').select('*');

      // Apply search filter if/when user writes in the search box.
      if (query.isNotEmpty) {
        // % match zero or more at both ends of string, $ holds the search term aka query.
        // https://supabase.com/docs/reference/dart/ilike
        // Remember to check what name you are using, Emma, so it doesn't break functionality again :)
        supabaseQuery = supabaseQuery.ilike('name', '%$query%');
      }

      // Apply filter if/when a tag is selected.
      if (selectedTag != null) {
        supabaseQuery = supabaseQuery.eq('tag_primary_tag', selectedTag.name);
      }

      // Limit the first products shown later? or limit amount of products in the query at least?
      final response = await supabaseQuery;

      // Map the response from supa to a list of products. Converts them via the fromJson factory method.
      final products = (response as List<dynamic>)
          .map((item) => Product.fromJson(item))
          .toList();

      setState(() {
        supabaseProducts = products;
      });
    } catch (error) {
      // I know the error handling isn't good :) WIP
      debugPrint('Error fetching products: $error');
    }
  }

  // Filter the products based on query in the search bar.
  void _filterProducts(String query) {
    fetchProducts(query: query);
  }

  /// Handle tag selection from SearchWidget.
  void _handleTagSelected(Tag? selectedTag) {
    fetchProducts(selectedTag: selectedTag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SearchWidget(
            onQuery: _filterProducts,
            onTagSelected: _handleTagSelected,
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
                                  ),
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
