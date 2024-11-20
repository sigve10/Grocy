import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/provider/product_provider.dart';
import 'package:grocy/provider/search_provider.dart';
import 'package:grocy/provider/tag_provider.dart';
import 'package:grocy/models/tag.dart';
import 'package:grocy/screens/account_screen.dart';

class SearchWidget extends ConsumerStatefulWidget {
  const SearchWidget({super.key});

  @override
  ConsumerState<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends ConsumerState<SearchWidget> {
  late final ProductProvider _productProvider;
  late final SearchProvider _searchProvider;
  
  @override
  void initState() {
    _productProvider = ref.read(productProvider.notifier);
    _searchProvider = ref.read(searchProvider.notifier);
    super.initState();
  }

  void setSearchTerm(String newTerm) {
    _searchProvider.setSearchTerm(newTerm);
    _productProvider.fetchProducts(ref);

  }

  void setMainTag(Tag? newTag) {
    _searchProvider.setMainTag(newTag);
    _productProvider.fetchProducts(ref);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ExpansionTile(
        controlAffinity: ListTileControlAffinity.leading,
        trailing: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              //TODO: after merge, fix session checks so that if you are ot logged in, you are sent to welcome screen
              //TODO: fix navigating back to home from account page, other than the "back" arrow. Home button should navigate you back
              MaterialPageRoute(builder: (context) => const AccountPage()),
            );
          },
          icon: const Icon(Icons.person),
          tooltip: "Account Page",
          iconSize: 24,
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: "Search products...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: setSearchTerm,
        ),
        children: [
          _SearchWidgetMainTags(
            onTagSelected: setMainTag
          ),
          const _SearchWidgetUserTags(),
        ],
      ),
    );
  }
}

class _SearchWidgetMainTags extends ConsumerStatefulWidget {
  final ValueChanged<Tag?> onTagSelected;

  const _SearchWidgetMainTags({
    required this.onTagSelected,
  });

  @override
  ConsumerState<_SearchWidgetMainTags> createState() =>
      _SearchWidgetMainTagsState();
}

class _SearchWidgetMainTagsState extends ConsumerState<_SearchWidgetMainTags> {
  Tag? selectedMainTag;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(primaryTagProvider.notifier).fetchPrimaryTags();
    });
  }

  bool isTagSelected(Tag tag) {
    // Changed it because the == didn't quite work with the parsing.
    return selectedMainTag?.name == tag.name;
  }

  void setTagCategory(Tag? selected) {
    setState(() {
      selectedMainTag = selected;
    });
    widget.onTagSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    final primaryTags = ref.watch(primaryTagProvider);

    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.center,
      children: primaryTags.map((tag) {
        return ChoiceChip(
          selected: isTagSelected(tag),
          label: Text(tag.name),
          onSelected: (bool selected) {
            setTagCategory(selected ? tag : null);
          },
        );
      }).toList(),
    );
  }
}

class _SearchWidgetUserTags extends ConsumerStatefulWidget {
  const _SearchWidgetUserTags();

  @override
  ConsumerState<_SearchWidgetUserTags> createState() =>
      _SearchWidgetUserTagsState();
}

class _SearchWidgetUserTagsState extends ConsumerState<_SearchWidgetUserTags> {
  TextEditingController tagSearchController = TextEditingController();
  final Set<String> selectedUserTags = {};

  void addUserTag(String tag) {
    setState(() {
      selectedUserTags.add(tag);
      tagSearchController.clear();
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tagProvider.notifier).fetchTags();
    });
    super.initState();
  }

  void removeUserTag(String tag) {
    setState(() => selectedUserTags.remove(tag));
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(tagProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(children: [
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
          onSelected: (tag) => addUserTag(tag.name),
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            tagSearchController = controller;
            return TextField(
              focusNode: focusNode,
              controller: tagSearchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.tag),
                border: OutlineInputBorder(),
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
                    tag,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              onDeleted: () => removeUserTag(tag),
            );
          }).toList(),
        ),
      ]),
    );
  }
}
