import 'package:flutter/material.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<StatefulWidget> createState() => CreateProductScreenState();

}

class CreateProductScreenState extends State<CreateProductScreen> {
  final String autofillName = "Apple";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController eanController = TextEditingController();

  void onSubmit() {
    // Empy!!
  }

  void onCancel() {
    // Also empy :((
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add a Product",
            style: Theme.of(context).textTheme.titleLarge
          ),
          const SizedBox(height: 16.0),
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
              helperText: "Auto-filled"
            ),
          ),
          const SizedBox(height: 24.0),
          TextField(
            controller: descController,
            minLines: 5,
            maxLines: 6,
            expands: false,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              label: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "Description "),
                    TextSpan(text: "(optional)")
                  ]
                ),
              )
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
          const Spacer(),
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
    );
  }
}