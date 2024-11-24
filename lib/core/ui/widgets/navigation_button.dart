import 'package:flashcardstudyapplication/core/ui/study_screen_controller.dart';
import 'package:flutter/material.dart';

class NavigationButtonsWidget extends StatelessWidget {
  final StudyScreenController controller;

  const NavigationButtonsWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flashcardState = controller.flashcardState;
    final flashcards = controller.flashcards;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: flashcardState.currentCardIndex > 0
                ? () => controller.previousCard()  // Pass required arguments
                : null,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Previous Card',
          ),
          IconButton(
            onPressed: flashcardState.currentCardIndex < flashcards.length - 1
                ? () => controller.nextCard(context)  // Pass context here
                : () => controller.nextCard(context),
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'Next Card',
          ),
        ],
      ),
    );
  }
}
