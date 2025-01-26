import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/ui/study_screen_controller.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomButton.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/navigation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/flashcard_provider.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/flashcard_display.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/progress_indicator.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/progress_button.dart';


class StudyScreen extends ConsumerWidget {
  final Deck deck;

  const StudyScreen({Key? key, required this.deck}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize the controller, passing in deckId
     final deckId = deck.id;
     final deckTitle = deck.title;
     final deckDescription = deck.description;
     final deckDifficulty = deck.difficultyLevel;

    final controller = StudyScreenController(ref: ref, deckId: deckId);
   
    final flashcardState = ref.watch(flashcardProvider);
    final flashcards = flashcardState.flashcardsByDeck[deckId] ?? [];
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    return CustomScaffold(
      currentRoute: currentRoute,
      body: Column(
        children: [
          // Progress Indicator - Shows progress based on current index
          ProgressIndicatorWidget(deckId: deckId),  // Pass deckId here

          // Flashcard Display - Displays current card
          FlashcardDisplay(deckTitle, deckDescription, deckDifficulty, deckId: deckId),
           // Pass deckId here

          // Navigation Buttons (Next, Previous)
          NavigationButtonsWidget(controller: controller),
          
          CustomButton(text: 'Go back',isLoading: false,icon: Icons.transit_enterexit, onPressed: () { Navigator.pushNamed(context, '/myDecks');}),  // Pass controller here

          // Progress Button (Correct / Incorrect)
          if (flashcardState.isFlipped)
            ProgressButtonWidget(controller: controller),  // Pass controller here
        ],
      ),
    );
  }
}
