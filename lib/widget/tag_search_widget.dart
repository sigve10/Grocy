import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tag.dart';
import '../provider/tag_provider.dart';

class TagSearchWidget extends ConsumerStatefulWidget {
  final Function(Tag) onTagSelected;
  final bool allowCreateNewTag;
  final String? primaryTag;
  final String? productEan;

  const TagSearchWidget({
    super.key,
    required this.onTagSelected,
    this.allowCreateNewTag = true,
    required this.primaryTag,
    required this.productEan,
  });

  @override
  ConsumerState<TagSearchWidget> createState() => _TagSearchWidgetState();
}

class _TagSearchWidgetState extends ConsumerState<TagSearchWidget> {
  TextEditingController tagSearchController = TextEditingController();
  Set<Tag> selectedUserTags = {};

  void addUserTag(Tag tag) {
    setState(() {
      selectedUserTags.add(tag);
      tagSearchController.clear();
    });
    widget.onTagSelected(tag);
  }

  void removeUserTag(Tag tag) {
    setState(() => selectedUserTags.remove(tag));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tagProvider.notifier).fetchTags();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(tagProvider);

    return Column(
      children: [
        Autocomplete<Tag>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Tag>.empty();
            }
            return tags.where((Tag tag) {
              return tag.name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          displayStringForOption: (Tag option) => option.name,
          onSelected: (tag) => addUserTag(tag),
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            tagSearchController = controller;
            return TextField(
              focusNode: focusNode,
              controller: tagSearchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.tag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                hintText: "Find tags...",
              ),
            );
          },
        ),
        const SizedBox(height: 16.0),
        Wrap(
          spacing: 4.0,
          runSpacing: 4.0,
          alignment: WrapAlignment.center,
          children: selectedUserTags.map((tag) {
            return Chip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tag,
                    size: 20,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tag.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              onDeleted: () => removeUserTag(tag),
            );
          }).toList(),
        ),
        if (widget.allowCreateNewTag) ...[
          const SizedBox(height: 16.0),
          ElevatedButton.icon(
            onPressed: () {
              _showCreateTagDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text("Create New Tag"),
          ),
        ],
      ],
    );
  }

  void _showCreateTagDialog() {
    final primaryTag = widget.primaryTag;
    final productEan = widget.productEan;

    if (primaryTag == null || primaryTag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primary tag is not set.')),
      );
      return;
    }

    String newTagName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Tag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    newTagName = value;
                  },
                  decoration: const InputDecoration(
                    labelText: "Tag Name",
                    hintText: "fruit",
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Primary Tag',
                    hintText: primaryTag,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (newTagName.trim().isNotEmpty) {
                  _createNewTag(newTagName.trim(), productEan!);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tag name cannot be empty')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _createNewTag(String name, String productEan) async {
    if (productEan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product EAN is missing.')),
      );
      return;
    }

    Tag newTag = Tag(name: name, primaryTag: widget.primaryTag);
    bool success = await ref
        .read(tagProvider.notifier)
        .addTagToProduct(newTag, productEan);

    if (success) {
      widget.onTagSelected(newTag);
      ref.read(tagProvider.notifier).fetchTags();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tag created successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create tag')),
      );
    }
  }

}
