import 'package:flashcardstudyapplication/core/models/collection.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/models/user_collection.dart';
import 'package:flashcardstudyapplication/presentation/screens/about_us_screen.dart';
import 'package:flashcardstudyapplication/presentation/screens/admin/admin_management_screen.dart';
import 'package:flashcardstudyapplication/presentation/screens/auth/login_screen.dart';

import 'package:flashcardstudyapplication/presentation/screens/deck/collections_screen.dart';
import 'package:flashcardstudyapplication/presentation/screens/deck/deck_screen.dart';
import 'package:flashcardstudyapplication/presentation/screens/deck/my_deck_screen.dart';
import 'package:flashcardstudyapplication/presentation/screens/home_screen.dart';
import 'package:flashcardstudyapplication/presentation/screens/study/collection_study_screen.dart';
import 'package:flashcardstudyapplication/presentation/screens/study/study_screen.dart';
import 'package:flashcardstudyapplication/presentation/screens/user/pricing_screen.dart';
import 'package:flashcardstudyapplication/presentation/screens/user/user_profile_screen.dart';
import 'package:flutter/material.dart';

class RouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Handle routes that need arguments
    if (settings.name == '/study') {
      final args = settings.arguments;
      if (args is Deck) {
        return MaterialPageRoute(
          builder: (context) => StudyScreen(deck: args),
          settings: settings,
        );
      } else if (args is Map<String, dynamic>) {
        // Check if this is a collection study
        if (args.containsKey('deck') && args.containsKey('isCollectionStudy')) {
          final deck = args['deck'] as Deck;
          final collection = args['collection'] as Collection?;
          final isCollectionStudy = args['isCollectionStudy'] as bool;
          final remainingDecks = args['remainingDecks'] as List<Deck>?;

          return MaterialPageRoute(
            builder: (context) => StudyScreen(
              deck: deck,
              collection: collection,
              isCollectionStudy: isCollectionStudy,
              remainingDecks: remainingDecks,
            ),
            settings: settings,
          );
        } else if (args.containsKey('collection') &&
            args.containsKey('userCollection')) {
          final collection = args['collection'] as Collection;
          final userCollection = args['userCollection'] as UserCollection;
          return MaterialPageRoute(
            builder: (context) => CollectionStudyScreen(
              collection: collection,
              userCollection: userCollection,
            ),
            settings: settings,
          );
        }
      }
      throw ArgumentError('Invalid arguments for study screen');
    }

    if (settings.name == '/collection_study') {
      final args = settings.arguments as Map<String, dynamic>;
      final collection = args['collection'] as Collection;
      final userCollection = args['userCollection'] as UserCollection;
      return MaterialPageRoute(
        builder: (context) => CollectionStudyScreen(
          collection: collection,
          userCollection: userCollection,
        ),
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
      case '/collections':
        return _noAnimationRoute(const CollectionsScreen());
      default:
        return _noAnimationRoute(const HomeScreen()); // Default route
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
      '/collections': (_) => CollectionsScreen(),
    };
  }
}
