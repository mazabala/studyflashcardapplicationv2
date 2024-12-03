import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';

class CustomScaffold extends ConsumerWidget {
  final String currentRoute;
  final Widget body;  // This is where we'll pass the unique content of each screen
  final bool useScroll;

  const CustomScaffold({required this.currentRoute, required this.body,this.useScroll = true,super.key});

  void _navigateWithoutAnimation(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.of(context).pushReplacementNamed(route); // No animation
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    bool isLoggedIn = authState.isAuthenticated;

    // Get screen size for responsive layout
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double headerHeight = screenHeight * 0.25; // 25% of screen height for the header
    double navBarHeight = screenHeight * 0.06; // 6% of screen height for the navbar

    // Check if the screen is small (e.g., width < 600 for mobile screens)
    bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Image
            Container(
              height: headerHeight,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/medical_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    'BDeck Focus',
                    style: theme.textTheme.displayLarge!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Navigation Bar
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
              height: navBarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(context, 'Home', '/', isSmallScreen ? Icons.home : 'Home'),
                  _buildNavItem(context, 'Decks & Flashcards', '/deck', isSmallScreen ? Icons.library_books : 'Decks & Flashcards'),
                  _buildNavItem(context, 'Pricing', '/prices', isSmallScreen ? Icons.monetization_on : 'Pricing'),
                  _buildNavItem(context, 'Contact Us', '/contactUs', isSmallScreen ? Icons.phone : 'Contact Us'),
                  _buildNavItem(context, 'About Us', '/aboutUs', isSmallScreen ? Icons.info : 'About Us'),

                  // Conditional navigation item based on login status
                  if (isLoggedIn)
                    _buildNavItem(context, 'My Decks', '/myDecks', isSmallScreen ? Icons.folder : 'My Decks')
                  else
                    _buildNavItem(context, 'Login', '/login', isSmallScreen ? Icons.login : 'Login'),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: useScroll ? SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width for padding
                  child: body,
                  ) 
                  
                ): body,
              ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String label, String route, dynamic icon) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = currentRoute == route;
    final ThemeData theme = Theme.of(context);

    // Use icon for small screens, text for larger screens
    if (icon is IconData) {
      return GestureDetector(
        onTap: () => _navigateWithoutAnimation(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.2)
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onPrimary,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _navigateWithoutAnimation(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.2)
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            icon,  // Here, icon is a label string
            style: isSelected
                ? theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
          ),
        ),
      );
    }
  }
}
