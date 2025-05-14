import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:transparent_image/transparent_image.dart';
import 'models/recipe.dart';
import 'providers/recipe_provider.dart';
import 'widgets/recipe_card.dart';
import 'widgets/cuisine_card.dart';
import 'widgets/true3d_hex_globe.dart';
import 'widgets/cuisine_globe_controller.dart';

class CuisinesScreen extends StatefulWidget {
  const CuisinesScreen({Key? key}) : super(key: key);

  @override
  State<CuisinesScreen> createState() => _CuisinesScreenState();
}

class _CuisinesScreenState extends State<CuisinesScreen> {
  String? _selectedRegion;
  bool _animateGlobe = false;
  // Map cuisine types to flag emojis
  final Map<String, String> _cuisineFlags = {
    'American': '🇺🇸',
    'Italian': '🇮🇹',
    'Indian': '🇮🇳',
    'Thai': '🇹🇭',
    'Mexican': '🇲🇽',
    'Chinese': '🇨🇳',
    'Japanese': '🇯🇵',
    'Korean': '🇰🇷',
    'Vietnamese': '🇻🇳',
    'French': '🇫🇷',
    'Greek': '🇬🇷',
    'Spanish': '🇪🇸',
    'Turkish': '🇹🇷',
    'British': '🇬🇧',
    'Russian': '🇷🇺',
    'Middle Eastern': '🌍',
    'Moroccan': '🇲🇦',
    'Colombian': '🇨🇴',
    'Nepalese': '🇳🇵',
    'Brazilian': '🇧🇷',
    'Swedish': '🇸🇪',
    'Hungarian': '🇭🇺',
    'Romanian': '🇷🇴',
    'Chilean': '🇨🇱',
    'Israeli': '🇮🇱',
    'Cuban': '🇨🇺',
    'Asian-Fusion': '🌏',
    'Italian-American': '🇺🇸',
    'New Zealand': '🇳🇿',
    'Iranian': '🇮🇷',
    'Indonesian/Thai': '🌏',
    'Canadian': '🇨🇦',
  };

  Set<Recipe> _favoriteRecipes = {};

  // Method to highlight and animate the region associated with a selected recipe
  void _highlightRecipeRegionOnGlobe(Recipe recipe) {
    // Get the region for this cuisine type
    final region = CuisineGlobeController.getRegionForCuisine(recipe.cuisineType);
    
    // Update state to highlight and animate this region on the globe
    setState(() {
      _selectedRegion = region;
      _animateGlobe = true;
    });
    
    // After some time, stop the continuous animation but keep the highlight
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _animateGlobe = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Cuisines', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
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

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isDesktop = constraints.maxWidth >= 900;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildMainContent(context, recipeProvider)),
                          const SizedBox(width: 32),
                          Expanded(flex: 1, child: _buildSideContent(context, recipeProvider)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMainContent(context, recipeProvider),
                          const SizedBox(height: 24),
                          _buildSideContent(context, recipeProvider),
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, RecipeProvider recipeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title section with interactive globe icon
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.public, color: Theme.of(context).colorScheme.primary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interactive World Cuisines',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore global cuisines through our interactive map',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // True 3D Interactive Hexagonal Earth Globe Visualization
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
          ),
          child: True3DHexGlobe(
            regionColors: CuisineGlobeController.regionColors,
            highlightedRegion: _selectedRegion,
            animateHighlight: _animateGlobe,
            onRegionSelected: (region) {
              // When a region is selected, filter to show related cuisines
              final cuisinesInRegion = CuisineGlobeController.getCuisinesForRegion(region);
              if (cuisinesInRegion.isNotEmpty) {
                // Pick the first cuisine from that region to show recipes
                recipeProvider.filterByCuisineType(cuisinesInRegion.first);
                
                // Set the selected region and trigger animation
                setState(() {
                  _selectedRegion = region;
                  _animateGlobe = true;
                });
                
                // Show a message about the selected region
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Exploring $region cuisines'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.7),
                Theme.of(context).colorScheme.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            return constraints.maxWidth > 600
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatCard(title: 'Total Recipes', value: '${recipeProvider.allRecipes.length}', isLight: true),
                      _StatCard(title: 'Cuisine Types', value: '${recipeProvider.cuisineTypes.length}', isLight: true),
                      _StatCard(title: 'Saved Recipes', value: '${_favoriteRecipes.length}', isLight: true),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StatCard(title: 'Total Recipes', value: '${recipeProvider.allRecipes.length}', isLight: true),
                      const SizedBox(height: 8),
                      _StatCard(title: 'Cuisine Types', value: '${recipeProvider.cuisineTypes.length}', isLight: true),
                      const SizedBox(height: 8),
                      _StatCard(title: 'Saved Recipes', value: '${_favoriteRecipes.length}', isLight: true),
                    ],
                  );
          }),
        ),
        const SizedBox(height: 24),
        _SectionHeading(title: 'Cuisines', icon: Icons.language),
        const SizedBox(height: 12),
        SizedBox(
          height: 125,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recipeProvider.cuisineTypes.length,
            itemBuilder: (context, index) {
              final cuisineType = recipeProvider.cuisineTypes[index];
              final flagEmoji = _cuisineFlags[cuisineType] ?? '🌍';
              return CuisineCard(
                name: cuisineType,
                flagEmoji: flagEmoji,
                isSelected: cuisineType == recipeProvider.selectedCuisineType,
                onTap: () {
                  if (cuisineType == recipeProvider.selectedCuisineType) {
                    recipeProvider.filterByCuisineType(null);
                  } else {
                    recipeProvider.filterByCuisineType(cuisineType);
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeading(
          title: recipeProvider.selectedCuisineType != null
              ? '${recipeProvider.selectedCuisineType} Recipes'
              : 'All Recipes',
          icon: Icons.restaurant_menu,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: recipeProvider.filteredRecipes.isEmpty
              ? const Center(
                  child: Text('No recipes found. Try selecting a different cuisine type.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: recipeProvider.filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipeProvider.filteredRecipes[index];
                    final isFavorite = _favoriteRecipes.contains(recipe);
                    return RecipeCard(
                      recipe: recipe,
                      isFavorite: isFavorite,
                      onTap: () {
                        // Show recipe details
                        _showRecipeDetails(context, recipe);
                        
                        // Highlight and animate the recipe's region on the globe
                        _highlightRecipeRegionOnGlobe(recipe);
                      },
                      onFavoriteToggle: () {
                        setState(() {
                          if (_favoriteRecipes.contains(recipe)) {
                            _favoriteRecipes.remove(recipe);
                          } else {
                            _favoriteRecipes.add(recipe);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
        const SizedBox(height: 24),
        _SectionHeading(title: 'Popular Dietary Options', icon: Icons.restaurant),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(builder: (context, constraints) {
              // Get unique diets from recipes
              final List<String> allDiets = [];
              for (final recipe in recipeProvider.allRecipes) {
                allDiets.addAll(recipe.suitableDiets);
              }
              
              final Map<String, int> dietCounts = {};
              for (final diet in allDiets) {
                if (diet.isNotEmpty) {
                  dietCounts[diet] = (dietCounts[diet] ?? 0) + 1;
                }
              }
              
              // Create dietary option widgets
              final dietItems = dietCounts.entries.take(4).map((entry) => 
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: _DietaryOption(
                    label: entry.key, 
                    count: entry.value,
                  ),
                )
              ).toList();
              
              return constraints.maxWidth > 500
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: dietItems,
                  )
                : Wrap(
                    alignment: WrapAlignment.spaceAround,
                    spacing: 16,
                    runSpacing: 20,
                    children: dietItems,
                  );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSideContent(BuildContext context, RecipeProvider recipeProvider) {
    // Get recipes by difficulty
    final easyRecipes = recipeProvider.allRecipes.where((r) => r.easeOfCooking.toLowerCase() == 'easy').take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(title: 'Quick & Easy Recipes', icon: Icons.access_time),
        const SizedBox(height: 12),
        ...easyRecipes.map((recipe) => _SideRecipeItem(
          recipe: recipe,
          isFavorite: _favoriteRecipes.contains(recipe),
          onFavoriteToggle: () {
            setState(() {
              if (_favoriteRecipes.contains(recipe)) {
                _favoriteRecipes.remove(recipe);
              } else {
                _favoriteRecipes.add(recipe);
              }
            });
          },
          onTap: () => _showRecipeDetails(context, recipe),
        )),
        
        const SizedBox(height: 24),
        _SectionHeading(title: 'Recipe Statistics', icon: Icons.bar_chart),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStatisticRow('Easy Recipes', recipeProvider.allRecipes.where((r) => r.easeOfCooking.toLowerCase() == 'easy').length),
                const Divider(),
                _buildStatisticRow('Medium Recipes', recipeProvider.allRecipes.where((r) => r.easeOfCooking.toLowerCase() == 'medium').length),
                const Divider(),
                _buildStatisticRow('Hard Recipes', recipeProvider.allRecipes.where((r) => r.easeOfCooking.toLowerCase() == 'hard').length),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showRecipeDetails(BuildContext context, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
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
                              children: recipe.suitableDiets.isEmpty
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
                              children: recipe.allergens.isEmpty
                                  ? [const Chip(label: Text('None'))]
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
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...recipe.ingredientsPerServing.map(
                    (ingredient) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.circle, size: 8),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(ingredient),
                          ),
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
                          setState(() {
                            if (_favoriteRecipes.contains(recipe)) {
                              _favoriteRecipes.remove(recipe);
                            } else {
                              _favoriteRecipes.add(recipe);
                            }
                          });
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          _favoriteRecipes.contains(recipe)
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        label: Text(
                          _favoriteRecipes.contains(recipe)
                              ? 'Saved'
                              : 'Save Recipe',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _favoriteRecipes.contains(recipe)
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey.shade200,
                          foregroundColor: _favoriteRecipes.contains(recipe)
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
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

class _SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeading({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isLight;

  const _StatCard({
    required this.title,
    required this.value,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isLight ? Colors.white : Theme.of(context).colorScheme.primary;

    return Card(
      color: isLight ? Colors.transparent : Colors.white,
      elevation: isLight ? 0 : 2,
      shadowColor: isLight ? Colors.transparent : Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideRecipeItem extends StatelessWidget {
  final Recipe recipe;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const _SideRecipeItem({
    required this.recipe,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: recipe.imageUrl.isNotEmpty
                      ? Image.network(
                          recipe.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.restaurant, size: 32, color: Color(0xFF3D5A80)),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.restaurant, size: 32, color: Color(0xFF3D5A80)),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.cuisineType} • ${recipe.easeOfCooking}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            recipe.originLocation,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: const Color(0xFFEE6C4D),
                ),
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DietaryOption extends StatelessWidget {
  final String label;
  final int count;

  const _DietaryOption({
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getDietIcon(label),
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$count recipes',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  IconData _getDietIcon(String diet) {
    switch (diet.toLowerCase()) {
      case 'vegetarian':
        return Icons.spa;
      case 'vegan':
        return Icons.grass;
      case 'gluten-free':
        return Icons.no_food;
      case 'dairy-free':
        return Icons.no_drinks;
      case 'keto':
        return Icons.fitness_center;
      case 'paleo':
        return Icons.egg_alt;
      case 'low-carb':
        return Icons.rice_bowl;
      default:
        return Icons.restaurant;
    }
  }
}
