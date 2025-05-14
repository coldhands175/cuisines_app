class Recipe {
  final String name;
  final String cuisineType;
  final String originLocation;
  final String imageUrl;
  final String recipeUrl;
  final List<String> ingredientsPerServing;
  final List<String> suitableDiets;
  final List<String> allergens;
  final String easeOfCooking;

  Recipe({
    required this.name,
    required this.cuisineType,
    required this.originLocation,
    required this.imageUrl,
    required this.recipeUrl,
    required this.ingredientsPerServing,
    required this.suitableDiets,
    required this.allergens,
    required this.easeOfCooking,
  });

  factory Recipe.fromCsvRow(Map<String, dynamic> map) {
    return Recipe(
      name: map['name'] ?? '',
      cuisineType: map['cuisine_type'] ?? '',
      originLocation: map['origin_location'] ?? '',
      imageUrl: map['image_url'] ?? '',
      recipeUrl: map['recipe_url'] ?? '',
      ingredientsPerServing: _parseList(map['ingredients_per_serving'] ?? ''),
      suitableDiets: _parseList(map['suitable_diets'] ?? ''),
      allergens: _parseList(map['allergens'] ?? ''),
      easeOfCooking: map['ease_of_cooking'] ?? '',
    );
  }

  static List<String> _parseList(String data) {
    if (data.isEmpty) return [];
    return data.split(';').map((item) => item.trim()).toList();
  }
}
