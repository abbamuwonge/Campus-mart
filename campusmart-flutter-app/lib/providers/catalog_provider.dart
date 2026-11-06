import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../models/category.dart';
import '../models/item.dart';
import '../services/api_client.dart';
import '../services/category_service.dart';
import '../services/favorite_service.dart';
import '../services/item_service.dart';

/// The marketplace feed on the Home page (search, category chips, paging) and the saved-item ids.
class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._items, this._categories, this._favorites);

  static const int _pageSize = 20; // the backend's page size

  final ItemService _items;
  final CategoryService _categories;
  final FavoriteService _favorites;

  List<Category> categories = [];
  int? categoryId; // null means "All"
  String query = '';

  List<Item> items = [];
  bool loading = false;
  bool loadingMore = false;
  bool hasMore = true;
  String? error;
  final Set<int> favoriteIds = {};

  int _page = 1;
  int _serial = 0; // ignores answers that arrive after a newer request was started
  Timer? _debounce;

  Future<void> init() async {
    await Future.wait([loadFavoriteIds(), refresh()]); // refresh() also loads the categories
  }

  Future<void> loadCategories() async {
    try {
      categories = await _categories.list();
      notifyListeners();
    } on ApiException {
      // The chips then show only "All"; pull to refresh on the Home page tries again.
    }
  }

  Future<void> loadFavoriteIds() async {
    try {
      final saved = await _favorites.list();
      favoriteIds
        ..clear()
        ..addAll(saved.map((i) => i.id));
      notifyListeners();
    } on ApiException {
      // Hearts stay empty until the next refresh.
    }
  }

  Future<void> refresh() async {
    final serial = ++_serial;
    loading = true;
    error = null;
    notifyListeners();
    if (categories.isEmpty) {
      unawaited(loadCategories());
    }
    try {
      final result = await _items.list(query: query, categoryId: categoryId, page: 1);
      if (serial != _serial) return;
      items = result;
      _page = 1;
      hasMore = result.length >= _pageSize;
    } on ApiException catch (e) {
      if (serial != _serial) return;
      error = e.message;
    }
    if (serial == _serial) {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || loading || loadingMore) return;
    final serial = _serial;
    loadingMore = true;
    notifyListeners();
    try {
      final result = await _items.list(query: query, categoryId: categoryId, page: _page + 1);
      if (serial == _serial) {
        _page += 1;
        items = [...items, ...result];
        hasMore = result.length >= _pageSize;
      }
    } on ApiException {
      // Keep what is already shown.
    }
    loadingMore = false;
    notifyListeners();
  }

  void selectCategory(int? id) {
    categoryId = id;
    refresh();
  }

  /// Called on every keystroke of the search box; waits a moment before asking the server.
  void search(String text) {
    query = text;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), refresh);
  }

  bool isFavorite(int itemId) => favoriteIds.contains(itemId);

  /// Returns an error message, or null when it worked.
  Future<String?> toggleFavorite(int itemId) async {
    final wasSaved = favoriteIds.contains(itemId);
    if (wasSaved) {
      favoriteIds.remove(itemId);
    } else {
      favoriteIds.add(itemId);
    }
    notifyListeners();
    try {
      if (wasSaved) {
        await _favorites.remove(itemId);
      } else {
        await _favorites.add(itemId);
      }
      return null;
    } on ApiException catch (e) {
      if (wasSaved) {
        favoriteIds.add(itemId);
      } else {
        favoriteIds.remove(itemId);
      }
      notifyListeners();
      return e.message;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
