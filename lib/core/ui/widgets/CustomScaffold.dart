import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'dart:io' show Platform;

class CustomScaffold extends ConsumerWidget {
  final String currentRoute;
  final Widget body;
  final bool useScroll;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CustomScaffold({
    required this.currentRoute,
    required this.body,
    this.useScroll = true,
    super.key,
  });

  void _navigateWithoutAnimation(BuildContext context, String route) {
  if (ModalRoute.of(context)?.settings.name != route) {
    if (Platform.isAndroid || Platform.isIOS) {
      // Use animation for mobile platforms
      Navigator.of(context).pushReplacementNamed(
        route,
        arguments: RouteSettings(name: route),
      );
    } else {
      // No animation for other platforms
      Navigator.of(context).pushReplacementNamed(
        route,
        arguments: RouteSettings(name: route),
      );
    }
  }
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final bool isLoggedIn = authState.isAuthenticated;
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // New Header Design
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 48,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSmallScreen 
                ? _buildMobileHeader(context,isLoggedIn)
                : _buildWebHeader(context, isLoggedIn),
            ),

            // Content Area
            Expanded(
              child: useScroll
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: body,
                      ),
                    )
                  : body,
            ),
          ],
        ),
      ),
      endDrawer: isSmallScreen ? _buildDrawer(context, isLoggedIn) : null,
    );
  }

  Widget _buildWebHeader(BuildContext context, bool isLoggedIn) {
    return Row(
      children: [
        // Logo
        Image.asset(
          'assets/images/logo.png',
          height: 32,
        ),
        const SizedBox(width: 48),
        
        // Navigation Links
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavLink(context, 'Home', '/'),
              _buildNavLink(context, 'Decks & Flashcards', '/deck'),
              _buildNavLink(context, 'Pricing', '/prices'),
             //TODO: Maybe move this to the profile page?  _buildNavLink(context, 'Contact Us', '/contactUs'),
             //TODO: Maybe move this to the profile page? _buildNavLink(context, 'About Us', '/aboutUs'),
              if (isLoggedIn)
                _buildNavLink(context, 'My Decks', '/myDecks')
              else
                _buildNavLink(context, 'Login', '/login'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context ,bool isLoggedIn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Image.asset(
          'assets/images/logo.png',
          height: 24,
        ),
        
        // Menu Button
        IconButton(
          icon: const Icon(Icons.menu),
          color: Theme.of(context).scaffoldBackgroundColor,
          onPressed: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, bool isLoggedIn) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Deck Focus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _buildDrawerItem(context, 'Home', '/', Icons.home),
          _buildDrawerItem(context, 'Decks & Flashcards', '/deck', Icons.library_books),
          _buildDrawerItem(context, 'Pricing', '/prices', Icons.monetization_on),
          _buildDrawerItem(context, 'Contact Us', '/contactUs', Icons.phone),
          _buildDrawerItem(context, 'About Us', '/aboutUs', Icons.info),
          if (isLoggedIn)
            _buildDrawerItem(context, 'My Decks', '/myDecks', Icons.folder)
          else
            _buildDrawerItem(context, 'Login', '/login', Icons.login),
        ],
      ),
    );
  }

  Widget _buildNavLink(BuildContext context, String label, String route) {
    final bool isSelected = currentRoute == route;
    
    return TextButton(
      onPressed: () => _navigateWithoutAnimation(context, route),
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? Colors.black : Colors.black54,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(label),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String label, String route, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: currentRoute == route,
      onTap: () {
        Navigator.pop(context); // Close drawer
        _navigateWithoutAnimation(context, route);
      },
    );
  }
}