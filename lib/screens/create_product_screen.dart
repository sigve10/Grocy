import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/models/tag.dart';
import 'package:grocy/provider/tag_provider.dart';

class CreateProductScreen extends ConsumerStatefulWidget {
  const CreateProductScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CreateProductScreenState();
}

class CreateProductScreenState extends ConsumerState<CreateProductScreen> {
  final String autofillName = "Apple";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController eanController = TextEditingController();
  Tag? selectedPrimaryTag;

  void onSubmit() {
    // Empy!!
  }

  void onCancel() {
    // Also empy :((
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(primaryTagProvider.notifier).fetchPrimaryTags();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Tag> primaryTags = ref.watch(primaryTagProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add a Product",
                style: Theme.of(context).textTheme.titleLarge
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField(
                hint: Text("Select a primary tag"),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  helper: selectedPrimaryTag == null ? Text(
                    "Required",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error
                    )
                  ) : null
                ),
                value: selectedPrimaryTag,
                items: [
                  for (Tag tag in primaryTags)
                    DropdownMenuItem<Tag>(
                      value: tag,
                      child: Text(tag.name),
                    )
                ],
                onChanged: (tag) => setState( () =>
                  selectedPrimaryTag = tag
                ),
              ),
              const SizedBox(height: 24.0),
              const Divider(),
              const SizedBox(height: 24.0),
              TextField(
                style: TextStyle(
                  backgroundColor: Theme.of(context).colorScheme.surfaceBright
                ),
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
                  hintText: "Product has no description"
                ),
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
                  floatingLabelBehavior: FloatingLabelBehavior.always
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      child: const Text(
                        "Cancel"
                      )
                    ),
                  ),
                  const SizedBox(width: 24.0),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary
                      ),
                      onPressed: onSubmit,
                      child: const Text("Submit")
                    ),
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