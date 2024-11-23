import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/models/tag.dart';
import 'package:grocy/provider/tag_provider.dart';
import 'package:grocy/screens/product_screen.dart';
import '../models/product.dart';
import '../provider/product_provider.dart';

/// Screen which allows user to add a product (with associated tag) to the database.
class CreateProductScreen extends ConsumerStatefulWidget {
  const CreateProductScreen({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CreateProductScreenState();
}

/// State class for [CreateProductScreen]
/// Manages the user interaction with the create product screen.
class CreateProductScreenState extends ConsumerState<CreateProductScreen> {
  late final ProductProvider _productProvider;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController eanController = TextEditingController();
  Tag? selectedPrimaryTag;

  /// Handles the submission of a product.
  void onSubmit() async {
    if (selectedPrimaryTag != null) {
      final product = Product(
          ean: widget.product.ean,
          name: widget.product.name,
          description: widget.product.description,
          imageUrl: widget.product.imageUrl,
          primaryTag: selectedPrimaryTag!.name);
      _productProvider.addProduct(product);
      Navigator.pop(context);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductScreen(product: product),
        ),
      );
    }
  }

  /// Cancels the product creation, navigating user the back.
  void onCancel() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    _productProvider = ref.read(productProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(primaryTagProvider.notifier).fetchPrimaryTags();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = widget.product.name;
    descController.text = widget.product.description ?? "";
    eanController.text = widget.product.ean;

    final List<Tag> primaryTags = ref.watch(primaryTagProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add a Product",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16.0),
              DropdownButtonFormField(
                hint: Text("Select a primary tag"),
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    helper: selectedPrimaryTag == null
                        ? Text("Required",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))
                        : null),
                value: selectedPrimaryTag,
                items: [
                  for (Tag tag in primaryTags)
                    DropdownMenuItem<Tag>(
                      value: tag,
                      child: Text(tag.name),
                    )
                ],
                onChanged: (tag) => setState(() => selectedPrimaryTag = tag),
              ),
              const SizedBox(height: 24.0),
              const Divider(),
              const SizedBox(height: 24.0),
              TextField(
                style: TextStyle(
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceBright),
                controller: nameController,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Name",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  helperText: "Auto-filled",
                ),
              ),
              const SizedBox(height: 24.0),
              TextField(
                controller: descController,
                minLines: 5,
                maxLines: 6,
                expands: false,
                readOnly: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Description",
                    helperText: "Auto-filled",
                    hintText: "Product has no description"),
              ),
              const SizedBox(height: 24.0),
              TextField(
                controller: eanController,
                readOnly: true,
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "EAN (barcode)",
                    helperText: "Auto-filled",
                    floatingLabelBehavior: FloatingLabelBehavior.always),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: OutlinedButton(
                        onPressed: onCancel, child: const Text("Cancel")),
                  ),
                  const SizedBox(width: 24.0),
                  Expanded(
                    child: FilledButton(
                        onPressed: selectedPrimaryTag == null ? null : onSubmit,
                        child: const Text("Submit")),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
