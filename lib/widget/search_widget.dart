import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/data/dummy_data.dart';
import 'package:grocy/models/tag.dart';
import 'package:grocy/screens/account_screen.dart';

class SearchWidget extends ConsumerStatefulWidget {
  final ValueChanged<String> onQuery;

  const SearchWidget({super.key, required this.onQuery});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SearchWidgetState();
  }
}

class SearchWidgetState extends ConsumerState<SearchWidget> {
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
          onChanged: widget.onQuery,
        ),
        children: [
          _SearchWidgetMainTags(),
          _SearchWidgetUserTags()
        ],
      )
    );
  }
}

class _SearchWidgetMainTags extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchWidgetMainTagsState();
}

class _SearchWidgetMainTagsState extends ConsumerState<_SearchWidgetMainTags> {
  List<Tag> primaryTags = DummyData.getPrimaryTags();

  Tag? selectedMainTag;

  bool isTagSelected(Tag tag) {
    return selectedMainTag == tag;
  }

  void setTagCategory(Tag? selected) {
    setState(() {
      selectedMainTag = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      spacing: 4.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.center,
      children: [
        for (Tag primaryTag in primaryTags)
          ChoiceChip(
            selected: (){ return isTagSelected(primaryTag); }(),
            label: Text(primaryTag.name),
            onSelected: (bool selected) {setTagCategory(selected ? primaryTag : null);},
          )
      ],
    );
  }

}

class _SearchWidgetUserTags extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchWidgetUserTagsState();
}

class _SearchWidgetUserTagsState extends State<_SearchWidgetUserTags> {
  TextEditingController tagSearchController = TextEditingController();
  final Set<String> selectedUserTags = {};

  void addUserTag(String tag) {
    setState(() {
      selectedUserTags.add(tag);
      tagSearchController.text = "";
    });
  }

  void removeUserTag(String tag) {
    setState(() => selectedUserTags.remove(tag));
  }

  Iterable<Tag> getTagsBySearch (TextEditingValue search) {
    if (search.text == "") {
      return const Iterable<Tag>.empty();
    }
    return DummyData.getUserTags().where((Tag tag) {
      return tag.name.toLowerCase().contains(search.text.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: [
          Autocomplete<Tag>(
            optionsBuilder: getTagsBySearch,
            displayStringForOption: (Tag option) => option.name,
            onSelected: (tag) => addUserTag(tag.name),
            fieldViewBuilder: (context, controller, focus, submitted) {
              tagSearchController = controller;
              return TextField(
                focusNode: focus,
                controller: tagSearchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.tag),
                  border: OutlineInputBorder(),
                  hintText: "Find tags..."
                ),
              );
            },
          ),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.center,
            direction: Axis.horizontal,
            children: [
              for (String tag in selectedUserTags)
                Chip(
                  label: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.tag,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(128)
                          )
                        ),
                        TextSpan(text: tag)
                      ]
                    )
                  ),
                  onDeleted: () => removeUserTag(tag),
                )
            ]
          )
        ]
      ),
    );
  }

}