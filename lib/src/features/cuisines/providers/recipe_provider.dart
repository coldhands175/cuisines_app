import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  List<String> _cuisineTypes = [];
  String? _selectedCuisineType;
  bool _isLoading = true;
  String? _error;

  RecipeProvider() {
    _initializeData();
  }

  // Getters
  List<Recipe> get allRecipes => _allRecipes;
  List<Recipe> get filteredRecipes => _filteredRecipes;
  List<String> get cuisineTypes => _cuisineTypes;
  String? get selectedCuisineType => _selectedCuisineType;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize data
  Future<void> _initializeData() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load all recipes
      _allRecipes = await _recipeService.loadRecipes();
      _filteredRecipes = List.from(_allRecipes);

      // Get unique cuisine types
      _cuisineTypes = await _recipeService.getUniqueCuisineTypes();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load recipes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter recipes by cuisine type
  void filterByCuisineType(String? cuisineType) {
    _selectedCuisineType = cuisineType;
    
    if (cuisineType == null) {
      _filteredRecipes = List.from(_allRecipes);
    } else {
      _filteredRecipes = _allRecipes
          .where((recipe) => recipe.cuisineType == cuisineType)
          .toList();
    }
    
    notifyListeners();
  }

  // Get recipes by cuisine type (returns a new list, doesn't update state)
  List<Recipe> getRecipesByCuisineType(String cuisineType) {
    return _allRecipes
        .where((recipe) => recipe.cuisineType == cuisineType)
        .toList();
  }

  // Refresh data
  Future<void> refreshData() async {
    await _initializeData();
  }
}
