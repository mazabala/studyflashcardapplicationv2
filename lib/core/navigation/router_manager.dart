
import 'package:flashcardstudyapplication/core/ui/study_screen.dart';
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
      final String? deckId = settings.arguments as String?;
      if (deckId == null) {
        throw ArgumentError('Deck ID is required for study screen');
      }
      return _noAnimationRoute(StudyScreen(deckId: deckId));
    }
    
    
    switch (settings.name) {
      case '/':
        return _noAnimationRoute (const HomeScreen());
      case '/deck':
        return _noAnimationRoute (DeckScreen());
      case '/userProfile':
        return _noAnimationRoute (UserProfileScreen());
      case '/login':
        
        return _noAnimationRoute (LoginScreen());
      case '/myDecks':
        return _noAnimationRoute(const MyDeckScreen());
      default:
        return _noAnimationRoute (const HomeScreen());  // Default route
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
      '/deck': (_) => DeckScreen(),
      '/userProfile': (_) => UserProfileScreen(),
      '/login': (_) => LoginScreen(),
      '/mydecks': (_) =>MyDeckScreen(),
    };
  }
}
