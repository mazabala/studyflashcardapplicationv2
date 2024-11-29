// lib/modules/deck/deck_screen.dart

import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flutter/material.dart';
//import 'package:flashcardstudyapplication/core/ui/widgets/app_bar.dart';  // Reusable AppBar


class DeckScreen extends StatelessWidget {
  const DeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/deck';

    return CustomScaffold(
      currentRoute: currentRoute,  // Pass the current route to customize the AppBar
      body: const Center(
        child: Text('Welcome to the Deck Screen'),
      ),
    );
  }
}