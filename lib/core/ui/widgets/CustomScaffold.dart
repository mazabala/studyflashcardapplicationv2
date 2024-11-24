import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/themes/app_theme.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
//import 'package:flashcardstudyapplication/core/themes/colors.dart'; // Import the AppColors class

class CustomScaffold extends StatelessWidget {
  final String currentRoute;
  final Widget body;  // This is where we'll pass the unique content of each screen
  
  
  CustomScaffold({required this.currentRoute, required this.body});

  void _navigateWithoutAnimation(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.of(context).pushReplacementNamed(route); // No animation
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme (light or dark)
  final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Use scaffold background color from the theme
      
      body: SafeArea(
        child: Column(
          children: [
            // Header Image
            Container(
              height: 300,
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
                    'Medical Flashcards',
                    style: theme.textTheme.displayLarge!.copyWith(
                      color: Colors.white, // Override text color for header
                    ),
                  ),
                ),
              ),
            ),
            
            // Navigation Bar
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary, // Use secondary color for the navigation bar
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(context, 'Home', '/'),
                  _buildNavItem(context, 'Decks & Flashcards', '/deck'),
                  _buildNavItem(context, 'Pricing', '/prices'),
                  _buildNavItem(context, 'Contact Us', '/contactUs'),
                  _buildNavItem(context, 'About Us', '/aboutUs'),
                  _buildNavItem(context, 'Login', '/login'),

                ],
              ),
              
            ),
            
            // Content Area
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildNavItem(BuildContext context, String label, String route) {
  final currentRoute = ModalRoute.of(context)?.settings.name;
  final isSelected = currentRoute == route;
  final ThemeData theme = Theme.of(context);

  return GestureDetector(
    onTap: () => _navigateWithoutAnimation(context, route),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.2) // Highlight selected item with primary color
            : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: isSelected
            ? theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface, // Ensure text color is visible on the primary background
              )
            : theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary, // Ensure text color contrasts on non-selected items
              ),
      ),
    ),
  );
}

}