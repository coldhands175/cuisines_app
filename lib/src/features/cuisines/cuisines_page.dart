import 'package:flutter/material.dart';

class CuisinesPage extends StatelessWidget {
  const CuisinesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
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
    });
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Asian Cuisines', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Jan 18, 2024 10:47 AM\nCuisines: 5', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: const [
            _StatCard(title: 'Saved recipes', value: '14'),
            _StatCard(title: 'Restaurants visited', value: '27'),
          ],
        ),
        const SizedBox(height: 24),
        const _InfoCard(title: 'Top cuisines', content: Text('Chinese – China')),
        const SizedBox(height: 24),
        const _InfoCard(
          title: 'Popular recipes',
          content: Row(children: [
            _RecipeCard(title: 'Pad Thai', subtitle: 'Noodles'),
          ]),
        ),
        const SizedBox(height: 24),
        const _InfoCard(
          title: 'Meals shared',
          content: Row(children: [
            _MealIcon(label: 'Breakfast', count: 1),
            _MealIcon(label: 'Lunch', count: 1),
            _MealIcon(label: 'Dinner', count: 2),
          ]),
        ),
      ],
    );
  }

  Widget _buildSideContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
          child: const Center(child: Text('Globe/Map')),
        ),
        const SizedBox(height: 24),
        const _InfoCard(
          title: 'Recommended restaurant',
          content: Row(children: [
            _RecipeCard(title: 'Dim Sum House', subtitle: 'Chinese'),
            SizedBox(width: 8),
            _RecipeCard(title: 'Grocforsatar', subtitle: 'Denver, CO'),
          ]),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 140,
        height: 80,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget content;
  const _InfoCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          content,
        ]),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _RecipeCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 100,
        height: 140,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 60, height: 60, color: Colors.grey[300], child: const Icon(Icons.fastfood, size: 32)),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }
}

class _MealIcon extends StatelessWidget {
  final String label;
  final int count;
  const _MealIcon({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(children: [
        CircleAvatar(backgroundColor: Colors.deepPurple[100], child: Text('$count', style: const TextStyle(color: Colors.deepPurple))),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}
