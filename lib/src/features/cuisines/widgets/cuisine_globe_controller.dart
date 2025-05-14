import 'package:flutter/material.dart';

class CuisineGlobeController {
  // Map of regions to their colors
  static final Map<String, Color> regionColors = {
    'European': const Color(0xFF5B8CFF),          // Blue
    'Asian': const Color(0xFFFF5B5B),             // Red
    'North American': const Color(0xFF5BFF5B),    // Green
    'South American': const Color(0xFFFFD85B),    // Yellow
    'African': const Color(0xFFFF9D5B),           // Orange
    'Oceanian': const Color(0xFFB05BFF),          // Purple
    'Middle Eastern': const Color(0xFFFFB05B),    // Amber
  };

  // Cuisine types by region
  static const Map<String, List<String>> regionToCuisines = {
    'European': ['Italian', 'French', 'Spanish', 'Greek', 'German', 'British', 'Polish', 'Russian'],
    'Asian': ['Chinese', 'Japanese', 'Thai', 'Indian', 'Korean', 'Vietnamese'],
    'North American': ['American', 'Mexican', 'Canadian'],
    'South American': ['Brazilian', 'Argentinian', 'Peruvian', 'Colombian'],
    'African': ['Moroccan', 'Ethiopian', 'Nigerian', 'Egyptian', 'South African'],
    'Oceanian': ['Australian', 'New Zealand'],
    'Middle Eastern': ['Turkish', 'Lebanese', 'Israeli', 'Iranian', 'Saudi Arabian'],
  };

  // Get region for a cuisine type
  static String getRegionForCuisine(String cuisineType) {
    for (final entry in regionToCuisines.entries) {
      if (entry.value.any((cuisine) => 
        cuisine.toLowerCase() == cuisineType.toLowerCase())) {
        return entry.key;
      }
    }
    
    // Default region if not found
    return 'Other';
  }

  // Get cuisines for a region
  static List<String> getCuisinesForRegion(String region) {
    return regionToCuisines[region] ?? [];
  }

  // Get all regions
  static List<String> getAllRegions() {
    return regionToCuisines.keys.toList();
  }
}
