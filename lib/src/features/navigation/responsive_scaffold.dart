import 'package:flutter/material.dart';
import '../cuisines/cuisines_screen.dart';
import '../recipes/recipes_screen.dart';

class ResponsiveScaffold extends StatefulWidget {
  const ResponsiveScaffold({Key? key}) : super(key: key);

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const CuisinesScreen(),
    const RecipesScreen(),
    const PlaceholderWidget('Restaurants'),
    const PlaceholderWidget('Community'),
    const PlaceholderWidget('Saved'),
    const PlaceholderWidget('Settings'),
  ];

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(icon: Icon(Icons.public), label: 'Cuisines'),
    NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Recipes'),
    NavigationDestination(icon: Icon(Icons.location_city), label: 'Restaurants'),
    NavigationDestination(icon: Icon(Icons.people), label: 'Community'),
    NavigationDestination(icon: Icon(Icons.bookmark), label: 'Saved'),
    NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    return isDesktop
        ? Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: _destinations
                      .map((d) => NavigationRailDestination(
                            icon: d.icon,
                            label: Text(d.label),
                          ))
                      .toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
          )
        : Scaffold(
            body: _pages[_selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: _destinations,
            ),
          );
  }
}


class PlaceholderWidget extends StatelessWidget {
  final String title;
  const PlaceholderWidget(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
