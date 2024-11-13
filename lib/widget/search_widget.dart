import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/data/dummy_data.dart';
import 'package:grocy/models/tag.dart';

class SearchWidget extends ConsumerStatefulWidget {
  const SearchWidget({super.key});

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
        title: TextField(
          decoration: InputDecoration(
            hintText: "Search products...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: null,
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
      runSpacing: 0.0,
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
  String tagSearch = "";
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
    return Column(
      children: [
        Autocomplete<Tag>(
          optionsBuilder: getTagsBySearch,
          displayStringForOption: (Tag option) => option.name,
        ),
        Wrap(

        )
      ]
    );
  }

}