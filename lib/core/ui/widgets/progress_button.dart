import 'package:flashcardstudyapplication/core/ui/study_screen_controller.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomButton.dart';
import 'package:flutter/material.dart';


class ProgressButtonWidget extends StatelessWidget {
  final StudyScreenController controller;

  const ProgressButtonWidget({Key? key, required this.controller}) : super(key: key);

  @override //TODO: This is getting pushed when the flashcard is long.
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButton(
          text: 'Incorrect',
          isLoading: false,
          icon: Icons.close,
          onPressed: () => controller.handleIncorrect(),  // Correct answer
          
        ),
        const SizedBox(width: 16),
        CustomButton(
          text: 'Correct',
          isLoading: false,
          icon: Icons.check,
          onPressed: () => controller.handleCorrect(),  // Incorrect answer
          
        ),
      ],
    );
  }
}
