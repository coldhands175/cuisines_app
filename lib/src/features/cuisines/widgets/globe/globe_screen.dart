import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/recipe_provider.dart';
import 'hex_globe.dart';
import 'cuisine_globe_controller.dart';

class GlobeScreen extends StatefulWidget {
  final Function(String)? onCuisineSelected;

  const GlobeScreen({
    Key? key,
    this.onCuisineSelected,
  }) : super(key: key);

  @override
  State<GlobeScreen> createState() => _GlobeScreenState();
}

class _GlobeScreenState extends State<GlobeScreen> {
  String? _selectedRegion;

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
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

        // Get unique cuisine types
        final cuisineTypes = recipeProvider.cuisineTypes;
        
        // Create a mapping of cuisine types to colors
        final cuisineColors = CuisineGlobeController.getCuisineColors(cuisineTypes);
        
        return Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      // Background gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.blueGrey.shade900.withOpacity(0.6),
                              Colors.black,
                            ],
                            center: Alignment.center,
                            radius: 1.0,
                          ),
                        ),
                      ),
                      
                      // Interactive globe
                      Center(
                        child: HexGlobe(
                          cuisineTypes: cuisineTypes,
                          onCuisineSelected: (cuisine) {
                            setState(() {
                              _selectedRegion = cuisine;
                            });
                            
                            if (widget.onCuisineSelected != null) {
                              widget.onCuisineSelected!(cuisine);
                            }
                          },
                          size: MediaQuery.of(context).size.width > 600 ? 500 : 300,
                          cuisineColors: CuisineGlobeController.regionColors,
                        ),
                      ),
                      
                      // UI overlay
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.public, color: Colors.white70),
                              SizedBox(width: 8),
                              Text(
                                'Explore Global Cuisines',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Instructions
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'Drag to rotate • Pinch to zoom • Tap a region to explore',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Region cuisines
            if (_selectedRegion != null)
              Expanded(
                flex: 2,
                child: _buildRegionCuisines(recipeProvider, _selectedRegion!),
              ),
            
            if (_selectedRegion == null)
              Expanded(
                flex: 1,
                child: _buildCuisineRegionList(recipeProvider),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRegionCuisines(RecipeProvider recipeProvider, String region) {
    // Get cuisines for the selected region
    final cuisinesInRegion = recipeProvider.cuisineTypes.where(
      (cuisine) => CuisineGlobeController.getCuisineRegion(cuisine) == region
    ).toList();
    
    // Region color
    final regionColor = CuisineGlobeController.regionColors[region] ?? Colors.blue;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: regionColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$region Cuisines',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedRegion = null;
                  });
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Globe'),
                style: TextButton.styleFrom(
                  foregroundColor: regionColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: cuisinesInRegion.isEmpty
                ? const Center(child: Text('No cuisines available for this region'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: cuisinesInRegion.length,
                    itemBuilder: (context, index) {
                      final cuisine = cuisinesInRegion[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: regionColor.withOpacity(0.2),
                            child: Icon(Icons.restaurant_menu, color: regionColor),
                          ),
                          title: Text(cuisine),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            if (widget.onCuisineSelected != null) {
                              widget.onCuisineSelected!(cuisine);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCuisineRegionList(RecipeProvider recipeProvider) {
    // Get all unique regions from cuisine types
    final regions = CuisineGlobeController.regionToCuisines.keys.toList();
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Regions of the World',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: regions.length,
              itemBuilder: (context, index) {
                final region = regions[index];
                final regionColor = CuisineGlobeController.regionColors[region] ?? Colors.grey;
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedRegion = region;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: regionColor.withOpacity(0.2),
                      border: Border.all(color: regionColor.withOpacity(0.5), width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          region,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: regionColor.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${CuisineGlobeController.regionToCuisines[region]?.length ?? 0} cuisines',
                          style: TextStyle(
                            fontSize: 12,
                            color: regionColor.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
