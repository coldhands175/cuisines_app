import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cuisines/models/recipe.dart';
import '../cuisines/providers/recipe_provider.dart';
import '../cuisines/widgets/recipe_card.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({Key? key}) : super(key: key);

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String _searchQuery = '';
  String _selectedDifficulty = 'All';
  String _selectedCuisine = 'All';
  
  final List<String> _difficulties = ['All', 'Easy', 'Medium', 'Hard'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Recipes', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => _showSearchDialog()),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () => _showFilterDialog()),
        ],
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          if (recipeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (recipeProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(recipeProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => recipeProvider.refreshData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Apply filters to recipes
          List<Recipe> filteredRecipes = recipeProvider.allRecipes.where((recipe) {
            // Apply search filter
            if (_searchQuery.isNotEmpty && 
                !recipe.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
                !recipe.cuisineType.toLowerCase().contains(_searchQuery.toLowerCase())) {
              return false;
            }
            
            // Apply difficulty filter
            if (_selectedDifficulty != 'All' && recipe.easeOfCooking != _selectedDifficulty) {
              return false;
            }
            
            // Apply cuisine filter
            if (_selectedCuisine != 'All' && recipe.cuisineType != _selectedCuisine) {
              return false;
            }
            
            return true;
          }).toList();

          // Get available cuisines for filter
          List<String> availableCuisines = ['All'];
          for (var recipe in recipeProvider.allRecipes) {
            if (!availableCuisines.contains(recipe.cuisineType)) {
              availableCuisines.add(recipe.cuisineType);
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active filters display
              if (_searchQuery.isNotEmpty || _selectedDifficulty != 'All' || _selectedCuisine != 'All')
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (_searchQuery.isNotEmpty)
                        Chip(
                          label: Text('Search: $_searchQuery'),
                          onDeleted: () => setState(() => _searchQuery = ''),
                        ),
                      if (_selectedDifficulty != 'All')
                        Chip(
                          label: Text('Difficulty: $_selectedDifficulty'),
                          onDeleted: () => setState(() => _selectedDifficulty = 'All'),
                        ),
                      if (_selectedCuisine != 'All')
                        Chip(
                          label: Text('Cuisine: $_selectedCuisine'),
                          onDeleted: () => setState(() => _selectedCuisine = 'All'),
                        ),
                    ],
                  ),
                ),
                
              // Results count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Showing ${filteredRecipes.length} recipes',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              
              // Recipe grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      onTap: () => _showRecipeDetails(context, recipe),
                      isFavorite: false, // You can implement favorites functionality
                      onFavoriteToggle: () {
                        // Implement favorite toggle
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempQuery = _searchQuery;
        return AlertDialog(
          title: const Text('Search Recipes'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter recipe name or cuisine',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              tempQuery = value;
            },
            controller: TextEditingController(text: _searchQuery),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = tempQuery;
                });
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempDifficulty = _selectedDifficulty;
        String tempCuisine = _selectedCuisine;
        
        // Get available cuisines
        final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
        List<String> availableCuisines = ['All'];
        for (var recipe in recipeProvider.allRecipes) {
          if (!availableCuisines.contains(recipe.cuisineType)) {
            availableCuisines.add(recipe.cuisineType);
          }
        }
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Recipes'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Difficulty:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: _difficulties.map((difficulty) => 
                        ChoiceChip(
                          label: Text(difficulty),
                          selected: tempDifficulty == difficulty,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                tempDifficulty = difficulty;
                              });
                            }
                          },
                        )
                      ).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Cuisine:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 200,
                      child: ListView(
                        children: availableCuisines.map((cuisine) => 
                          RadioListTile<String>(
                            title: Text(cuisine),
                            value: cuisine,
                            groupValue: tempCuisine,
                            onChanged: (value) {
                              setState(() {
                                tempCuisine = value!;
                              });
                            },
                          )
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    this.setState(() {
                      _selectedDifficulty = tempDifficulty;
                      _selectedCuisine = tempCuisine;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showRecipeDetails(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recipe image
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                            ),
                            child: recipe.imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      recipe.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Center(
                                        child: Icon(Icons.restaurant, size: 64, color: Color(0xFF3D5A80)),
                                      ),
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.restaurant, size: 64, color: Color(0xFF3D5A80)),
                                  ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Recipe title and origin
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.name,
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${recipe.cuisineType} • ${recipe.originLocation}',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(recipe.easeOfCooking).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  recipe.easeOfCooking,
                                  style: TextStyle(
                                    color: _getDifficultyColor(recipe.easeOfCooking),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Dietary info and allergens
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Suitable For:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: recipe.suitableDiets.isEmpty || recipe.suitableDiets.first == 'None'
                                          ? [const Chip(label: Text('No specific diet'))]
                                          : recipe.suitableDiets
                                              .map((diet) => Chip(
                                                    label: Text(diet),
                                                    backgroundColor: Colors.green.withOpacity(0.2),
                                                    labelStyle: const TextStyle(color: Colors.green),
                                                  ))
                                              .toList(),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Contains Allergens:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: recipe.allergens.isEmpty || recipe.allergens.first == 'None'
                                          ? [const Chip(label: Text('No allergens'))]
                                          : recipe.allergens
                                              .map((allergen) => Chip(
                                                    label: Text(allergen),
                                                    backgroundColor: Colors.red.withOpacity(0.2),
                                                    labelStyle: const TextStyle(color: Colors.red),
                                                  ))
                                              .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Ingredients
                          const Text(
                            'Ingredients:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...recipe.ingredientsPerServing.map(
                            (ingredient) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Expanded(child: Text(ingredient)),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final Uri url = Uri.parse(recipe.recipeUrl);
                                  try {
                                    // Launch the URL in the browser
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    } else {
                                      // Show error if URL can't be launched
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Could not open recipe URL')),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    // Show error message if there's an exception
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error opening URL: $e')),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.open_in_new),
                                label: const Text('View Full Recipe'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Implement favorite functionality
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Recipe saved to your favorites')),
                                  );
                                },
                                icon: const Icon(Icons.bookmark_border),
                                label: const Text('Save Recipe'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.secondary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
