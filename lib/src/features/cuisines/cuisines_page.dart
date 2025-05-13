import 'package:flutter/material.dart';

class CuisinesPage extends StatelessWidget {
  const CuisinesPage({Key? key}) : super(key: key);

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
      body: LayoutBuilder(builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildMainContent(context)),
                    const SizedBox(width: 32),
                    Expanded(flex: 1, child: _buildSideContent(context)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainContent(context),
                    const SizedBox(height: 24),
                    _buildSideContent(context),
                  ],
                ),
        );
      }),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  Text('Asian Cuisines', 
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Exploring 5 unique culinary traditions from East Asia',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
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
                  children: const [
                    _StatCard(title: 'Saved Recipes', value: '14', isLight: true),
                    _StatCard(title: 'Restaurants Visited', value: '27', isLight: true),
                    _StatCard(title: 'Dishes Made', value: '8', isLight: true),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    _StatCard(title: 'Saved Recipes', value: '14', isLight: true),
                    SizedBox(height: 8),
                    _StatCard(title: 'Restaurants Visited', value: '27', isLight: true),
                    SizedBox(height: 8),
                    _StatCard(title: 'Dishes Made', value: '8', isLight: true),
                  ],
                );
          }),
        ),
        const SizedBox(height: 24),
        const _SectionHeading(title: 'Top Cuisines', icon: Icons.star),
        const SizedBox(height: 12),
        SizedBox(
          height: 125,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _CuisineCard(name: 'Chinese', flagEmoji: '🇨🇳', imageAsset: null),
              _CuisineCard(name: 'Japanese', flagEmoji: '🇯🇵', imageAsset: null),
              _CuisineCard(name: 'Korean', flagEmoji: '🇰🇷', imageAsset: null),
              _CuisineCard(name: 'Thai', flagEmoji: '🇹🇭', imageAsset: null),
              _CuisineCard(name: 'Vietnamese', flagEmoji: '🇻🇳', imageAsset: null),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionHeading(title: 'Popular Recipes', icon: Icons.restaurant_menu),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            scrollDirection: Axis.horizontal,
            children: const [
              _RecipeCard(title: 'Pad Thai', subtitle: 'Noodles', imageAsset: null),
              _RecipeCard(title: 'Sushi', subtitle: 'Seafood', imageAsset: null),
              _RecipeCard(title: 'Dim Sum', subtitle: 'Dumplings', imageAsset: null),
              _RecipeCard(title: 'Bibimbap', subtitle: 'Rice Bowl', imageAsset: null),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionHeading(title: 'Meals Shared', icon: Icons.people),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(builder: (context, constraints) {
              return constraints.maxWidth > 500
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: _MealIcon(label: 'Breakfast', count: 1, color: Color(0xFFF9C74F)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: _MealIcon(label: 'Lunch', count: 1, color: Color(0xFF90BE6D)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: _MealIcon(label: 'Dinner', count: 2, color: Color(0xFF43AA8B)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: _MealIcon(label: 'Dessert', count: 1, color: Color(0xFFEE6C4D)),
                      ),
                    ],
                  )
                : Wrap(
                    alignment: WrapAlignment.spaceAround,
                    spacing: 16,
                    runSpacing: 20,
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: _MealIcon(label: 'Breakfast', count: 1, color: Color(0xFFF9C74F)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: _MealIcon(label: 'Lunch', count: 1, color: Color(0xFF90BE6D)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: _MealIcon(label: 'Dinner', count: 2, color: Color(0xFF43AA8B)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: _MealIcon(label: 'Dessert', count: 1, color: Color(0xFFEE6C4D)),
                      ),
                    ],
                  );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSideContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3D5A80),
                  const Color(0xFF98C1D9),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Global Explorer',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Asia',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 180,
                            height: 180,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0FBFC),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Globe base
                          const Icon(
                            Icons.public,
                            size: 120,
                            color: Color(0xFF3D5A80),
                          ),
                          // Decorative dots representing countries
                          Positioned(
                            top: 70,
                            left: 70,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF90BE6D),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF90BE6D).withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 55,
                            left: 90,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9C74F),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF9C74F).withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Main highlight circle showing Asian cuisines
                          Positioned(
                            top: 60,
                            right: 50,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEE6C4D),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEE6C4D).withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('5', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          // Additional smaller marker for secondary region
                          Positioned(
                            bottom: 80,
                            left: 50,
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: const Color(0xFF98C1D9),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Center(
                                child: Text('2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const _SectionHeading(title: 'Recommended Restaurants', icon: Icons.restaurant),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 4),
                _RestaurantItem(
                  name: 'Dim Sum House',
                  cuisine: 'Chinese',
                  rating: 4.8,
                  distance: '1.2 mi',
                  imageAsset: null,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(),
                ),
                _RestaurantItem(
                  name: 'Sakura Sushi',
                  cuisine: 'Japanese',
                  rating: 4.6,
                  distance: '0.8 mi',
                  imageAsset: null,
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEE6C4D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.flash_on, color: Color(0xFFEE6C4D)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join a Cooking Class!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Learn authentic Asian cooking techniques from expert chefs',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE6C4D),
                ),
                child: const Text('Explore'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;
  
  const _SectionHeading({required this.title, required this.icon});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: const Text('See All'),
        ),
      ],
    );
  }
}

class _CuisineCard extends StatelessWidget {
  final String name;
  final String flagEmoji;
  final String? imageAsset;
  
  const _CuisineCard({required this.name, required this.flagEmoji, this.imageAsset});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 80,
            width: 110,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                flagEmoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RestaurantItem extends StatelessWidget {
  final String name;
  final String cuisine;
  final double rating;
  final String distance;
  final String? imageAsset;
  
  const _RestaurantItem({
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.distance,
    this.imageAsset,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.restaurant, color: Color(0xFF3D5A80)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cuisine,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFF9C74F), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                distance,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLight ? Colors.white.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isLight ? Colors.white : Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isLight ? Colors.white.withOpacity(0.9) : Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageAsset;
  
  const _RecipeCard({
    required this.title,
    required this.subtitle,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageAsset != null
                    ? Image.asset(imageAsset!, fit: BoxFit.cover)
                    : const Center(child: Icon(Icons.fastfood, size: 40, color: Color(0xFF3D5A80))),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, size: 18, color: Color(0xFFEE6C4D)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealIcon extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  
  const _MealIcon({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
