import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/ui/about_us.dart';
import 'package:flashcardstudyapplication/core/ui/admin_management_screen.dart';
import 'package:flashcardstudyapplication/core/ui/study_screen.dart';
import 'package:flashcardstudyapplication/core/ui/pricing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/ui/deck_screen.dart';
import 'package:flashcardstudyapplication/core/ui/user_profile_screen.dart';
import 'package:flashcardstudyapplication/core/ui/login_screen.dart';
import 'package:flashcardstudyapplication/core/ui/home_screen.dart';
import 'package:flashcardstudyapplication/core/ui/my_deck_screen.dart';


class RouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Handle routes that need arguments
    if (settings.name == '/study') {
      // Extract the deck ID from arguments
      final Deck? deck = settings.arguments as Deck?;
      if (deck == null) {
        throw ArgumentError('Deck ID is required for study screen');
      }
      return MaterialPageRoute(
        builder: (context) => StudyScreen(deck: deck),
        settings: settings,
      );
    }
    
    switch (settings.name) {
      case '/':
        return _noAnimationRoute(const HomeScreen());
      case '/deck':
        return _noAnimationRoute(const FlashcardPreviewScreen());
      case '/aboutUs':
        return _noAnimationRoute(const AboutUsScreen());
      case '/userProfile':
        return _noAnimationRoute(UserProfileScreen());
      case '/prices':
        return _noAnimationRoute(PricingScreen());
      case '/login':
        return _noAnimationRoute(LoginScreen());
      case '/myDecks':
        return _noAnimationRoute(const MyDeckScreen());
      case '/admin':
        return _noAnimationRoute(AdminManagementScreen());
      default:
        return _noAnimationRoute(const HomeScreen());  // Default route
    }
  }

  // Function to create route without animation
  static PageRouteBuilder _noAnimationRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // No transition (just a fade-out)
        return child;
      },
    );
  }

  // Optional: If you need static routes as a map for navigation or deep linking.
  static Map<String, Widget Function(BuildContext)> get routes {
    return {
      '/': (_) => const HomeScreen(),
      '/deck': (_) => const FlashcardPreviewScreen(),
      '/userProfile': (_) => UserProfileScreen(),
      '/login': (_) => LoginScreen(),
      '/mydecks': (_) => const MyDeckScreen(),
      '/prices': (_) => PricingScreen(),
      '/aboutUs': (_) => const AboutUsScreen(),
      '/admin': (_) => AdminManagementScreen(),

    };
  }
}
