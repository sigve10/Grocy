import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/extentions/snackbar_context.dart';
import '../models/tag.dart';
import '../provider/tag_provider.dart';

/// A widget that can search, select and manage tags associated with a product.
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

/// Manages the state of the widget
class _TagSearchWidgetState extends ConsumerState<TagSearchWidget> {
  TextEditingController tagSearchController = TextEditingController();
  Set<Tag> selectedUserTags = {};

  /// Adds a user tag.
  void addUserTag(Tag tag) async {
    setState(() {
      selectedUserTags.add(tag);
      tagSearchController.clear();
    });

    bool success = await ref
        .read(tagProvider.notifier)
        .addTagToProduct(tag, widget.productEan!);
    if (success) {
      widget.onTagSelected(tag);
      ref.read(tagProvider.notifier).fetchTags();
      if (mounted) {
        context.showSnackBar(
          'Tag added successfully',
        );
      }
    } else {
      if (mounted) {
        context.showSnackBar(
          'Failed to add tag',
        );
      }
    }
  }

  /// Removes a user created tag.
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
      context.showSnackBar(
        'Primary tag is not set',
      );
      return;
    }

    String newTagName = '';
    String? errorText;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create New Tag'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      newTagName = value;
                      errorText = null;
                    },
                    decoration: InputDecoration(
                      labelText: "Tag Name",
                      hintText: "fruit",
                      errorText: errorText
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Primary Tag',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: primaryTag,
                      helperText: "Auto-filled",
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
                    final tags = ref.read(tagProvider);
                    if (tags.any((element) => element.name.toLowerCase() != newTagName.toLowerCase())) {
                      _createNewTag(newTagName.trim(), productEan!);
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        errorText = 'Tag already exists';
                      });
                    }
                  } else {
                    setState(() {
                      errorText = 'Tag name cannot be empty';
                    });
                  }
                }
              ),
            ],
          );
        });
      },
    );
  }

  /// Creates a new tag.
  void _createNewTag(String name, String productEan) async {
    if (productEan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product EAN is missing.')),
      );
      return;
    }

    /// Create a new tag object
    Tag newTag = Tag(name: name, primaryTag: widget.primaryTag);
    bool success = await ref
        .read(tagProvider.notifier)
        .createTag(newTag);

    if (success) {
      widget.onTagSelected(newTag);
      ref.read(tagProvider.notifier).fetchTags();
      if (mounted) {
        context.showSnackBar(
          'Successfully created tag',
        );
      }
    } else {
      if (mounted) {
        context.showSnackBar(
          'Failed to create the tag',
        );
      }
    }
  }
}
