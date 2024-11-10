import 'package:flutter/material.dart';
import 'package:grocy/main.dart';
import '../data/dummy_data.dart';
import '../models/product.dart';
import 'product_screen.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  ProductListState createState() => ProductListState();
}

// The state of the ProductList widget.
class ProductListState extends State<ProductList> {
  // final List<Product> products = DummyData.getProducts();

  List<Product> supabaseProducts = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    //filteredProducts = products;
    fetchProducts();
  }

  Future<void> fetchProducts() async {
  try {

    // Fetch the data from the 'products' table
    final List<dynamic> data = await supabase.from('products').select();

    // Print the fetched data for debugging
    print('Fetched products: $data');

    // Used for debugging while figuring out how to fetch.
    if (data == null || data.isEmpty) {
      print('No data fetched from Supabase.');
    } else {
      print('Number of products fetched: ${data.length}');
    }

    // Parse the data from the database into a list of products.
    List<Product> productsFromSupabase = data
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();

    // Print the parsed products
    productsFromSupabase.forEach((product) {
      print('Product: ${product.name}, Image URL: ${product.imageUrl}');
    });

    setState(() {
      supabaseProducts = productsFromSupabase;
      filteredProducts = supabaseProducts;
      isLoading = false;
    });
  } catch (error, stackTrace) {
    // Very default prints for debugging
    print('Error fetching products: $error');
    print('Stack trace: $stackTrace');
    setState(() {
      isLoading = false;
    });
  }
}

  void _filterProducts(String query) {
    setState(() {
      //filteredProducts = products
      filteredProducts = supabaseProducts
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _filterProducts,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
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
                            product.imageUrl ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
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
                                  Icon(Icons.star,
                                      size: 16, color: Colors.yellow[700]),
                                  Text(
                                    " ${product.reviewCount} reviews",
                                    style: TextStyle(color: Colors.grey[600]),
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
