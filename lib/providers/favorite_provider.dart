// lib/providers/favorite_provider.dart
import 'package:dappr/data/recipes_data.dart'; // To access the full list of recipes
import 'package:dappr/models/recipe.dart'; // Make sure this import is correct
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider with ChangeNotifier {
  Set<String> _favoriteRecipeIds = {}; // Stores only IDs for persistence
  List<Recipe> _favoriteRecipes = []; // Stores full Recipe objects for UI

  FavoriteProvider() {
    _loadFavorites();
  }

  List<Recipe> get favoriteRecipes => _favoriteRecipes;

  bool isFavorite(String recipeId) {
    return _favoriteRecipeIds.contains(recipeId);
  }

  void toggleFavorite(String recipeId) {
    if (_favoriteRecipeIds.contains(recipeId)) {
      _favoriteRecipeIds.remove(recipeId);
    } else {
      _favoriteRecipeIds.add(recipeId);
    }
    _updateFavoriteRecipes(); // Rebuild the list of actual Recipe objects
    _saveFavorites(); // Persist the IDs
    notifyListeners(); // Notify listeners (UI widgets) that state has changed
  }

  // Load favorite recipe IDs from shared preferences (private helper)
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList('favoriteRecipeIds');
    if (savedIds != null) {
      _favoriteRecipeIds = savedIds.toSet();
      _updateFavoriteRecipes(); // Rebuild the list after loading IDs
    }
    notifyListeners(); // Notify after initial load
  }

  // Save favorite recipe IDs to shared preferences (private helper)
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteRecipeIds', _favoriteRecipeIds.toList());
  }

  // Helper to update the list of actual Recipe objects based on IDs (private helper)
  void _updateFavoriteRecipes() {
    _favoriteRecipes = recipes // 'recipes' is your global list from recipes_data.dart
        .where((recipe) => _favoriteRecipeIds.contains(recipe.id))
        .toList();
  }

  // Public method to clear all favorites
  Future<void> clearAllFavorites() async { // <--- NEW PUBLIC METHOD
    _favoriteRecipeIds.clear(); // Clear the in-memory set
    await _saveFavorites(); // Save the empty set to SharedPreferences
    _updateFavoriteRecipes(); // Update the UI list to be empty
    notifyListeners(); // Notify widgets that favorites have changed
  }

  // You could also add a public load method if needed elsewhere, e.g.:
  // Future<void> loadFavoritesPublic() async {
  //   await _loadFavorites();
  // }
}
