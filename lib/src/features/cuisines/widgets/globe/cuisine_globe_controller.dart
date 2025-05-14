import 'package:flutter/material.dart';

/// Maps cuisine types to geographical regions and colors
class CuisineGlobeController {
  // Predefined cuisine regions and their mapping to cuisines
  static const Map<String, List<String>> regionToCuisines = {
    'European': ['Italian', 'French', 'Spanish', 'Greek', 'German', 'British', 'Polish', 'Russian'],
    'Asian': ['Chinese', 'Japanese', 'Thai', 'Indian', 'Korean', 'Vietnamese'],
    'North American': ['American', 'Mexican', 'Canadian'],
    'South American': ['Brazilian', 'Argentinian', 'Peruvian', 'Colombian'],
    'African': ['Moroccan', 'Ethiopian', 'Nigerian', 'Egyptian', 'South African'],
    'Oceanian': ['Australian', 'New Zealand'],
    'Middle Eastern': ['Turkish', 'Lebanese', 'Israeli', 'Iranian', 'Saudi Arabian'],
  };

  // Colors for each region
  static final Map<String, Color> regionColors = {
    'European': const Color(0xFF5B8CFF),          // Blue
    'Asian': const Color(0xFFFF5B5B),             // Red
    'North American': const Color(0xFF5BFF5B),    // Green
    'South American': const Color(0xFFFFD85B),    // Yellow
    'African': const Color(0xFFFF9D5B),           // Orange
    'Oceanian': const Color(0xFFB05BFF),          // Purple
    'Middle Eastern': const Color(0xFFFFB05B),    // Amber
  };

  // Get the region for a given cuisine type
  static String getRegionForCuisine(String cuisineType) {
    return getCuisineRegion(cuisineType);
  }

  // Get the region for a given cuisine type (original implementation)
  static String getCuisineRegion(String cuisineType) {
    for (var entry in regionToCuisines.entries) {
      if (entry.value.any((cuisine) => cuisine.toLowerCase() == cuisineType.toLowerCase())) {
        return entry.key;
      }
    }
    
    // If not found in our mapping, make a best guess
    if (cuisineType.contains('Asian') || 
        cuisineType.contains('Chinese') || 
        cuisineType.contains('Japanese')) {
      return 'Asian';
    } else if (cuisineType.contains('American')) {
      return 'North American';
    } else if (cuisineType.contains('African')) {
      return 'African';
    } else if (cuisineType.contains('European') || 
               cuisineType.contains('Italian') || 
               cuisineType.contains('French')) {
      return 'European';
    } else if (cuisineType.contains('Middle') || 
               cuisineType.contains('Eastern') || 
               cuisineType.contains('Arab')) {
      return 'Middle Eastern';
    }
    
    // Default region
    return 'Other';
  }

  // Get all unique regions from a list of cuisine types
  static List<String> getRegionsFromCuisineTypes(List<String> cuisineTypes) {
    final Set<String> regions = {};
    
    for (var cuisine in cuisineTypes) {
      regions.add(getCuisineRegion(cuisine));
    }
    
    return regions.toList();
  }

  // Get a color for a specific cuisine type
  static Color getColorForCuisine(String cuisineType) {
    final region = getCuisineRegion(cuisineType);
    return regionColors[region] ?? Colors.grey;
  }

  // Get a map of cuisine types to colors
  static Map<String, Color> getCuisineColors(List<String> cuisineTypes) {
    final Map<String, Color> colors = {};
    
    for (var cuisine in cuisineTypes) {
      colors[cuisine] = getColorForCuisine(cuisine);
    }
    
    return colors;
  }
}
