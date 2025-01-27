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
      child: Stack(
        alignment: Alignment.center, // Align everything to center
        children: [
          if (!flashcardState.isFlipped)
          Column(
            // This will contain the original navigation buttons vertically
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
              
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: flashcardState.currentCardIndex > 0
                        ? () => controller.previousCard()
                        : null,
                    child: const Row(
                      children: [Icon(Icons.skip_previous), Text('Previous Card')],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: flashcardState.currentCardIndex < flashcards.length - 1
                        ? () => controller.nextCard(context)
                        : () => controller.nextCard(context),
                    child: const Row(
                      children: [Text('Next Card'), Icon(Icons.skip_next)],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


          // Positioned(
          //   top: 25,  // Position from the top edge
          //   right: 25, // Position from the right edge
          //   child: GestureDetector(
          //     onTap: () async {
          //             await ref.read(flashcardProvider.notifier).reportCard(currentFlashcard);
          //     },
          //     child: Container(
          //       height: 30,  // Circle diameter
          //       width: 30,   // Circle diameter
          //       decoration: const BoxDecoration(
          //         color: Colors.redAccent,  // Circle color
          //         shape: BoxShape.circle,  // Makes it a circle
          //       ),
          //       child: const Icon(
          //         Icons.report,
          //         size: 15,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // ),