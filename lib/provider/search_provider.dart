import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/models/tag.dart';
import 'package:grocy/models/tag_category.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  void setSearchTerm(String newTerm) {
    state = state.copyWith(searchText: newTerm);
  }

  void setMainTag(TagCategory newTag) {
    state = state.copyWith(mainTag: newTag);
  }

  void addUserTag(Tag tagToAdd) {
    state = state.copyWith(
      userTags: state.userTags..add(tagToAdd)
    );
  }

  void removeUserTag(Tag tagToRemove) {
    state = state.copyWith(
      userTags: state.userTags..remove(tagToRemove)
    );
  }

  void resetUserTags() {
    state = state.copyWith(
      userTags: {}
    );
  }

  void reset() {
    state = const SearchState();
  }
}

class SearchState {
  final String searchText;
  final TagCategory? mainTag;
  final Set<Tag> userTags;

  const SearchState({
    this.searchText = "",
    this.mainTag,
    this.userTags = const {}
  });

  SearchState copyWith({
    String? searchText,
    TagCategory? mainTag,
    Set<Tag>? userTags
  }) {
    return SearchState(
      searchText: searchText ?? this.searchText,
      mainTag: mainTag ?? this.mainTag,
      userTags: userTags ?? this.userTags
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SearchState) return false;

    return other.mainTag == mainTag
      && other.searchText == searchText
      // list equality
      && other.userTags.length == userTags.length
      && other.userTags.containsAll(userTags);
  }

  @override
  int get hashCode => Object.hash(
    searchText,
    mainTag,
    Object.hashAllUnordered(userTags)
  );
}