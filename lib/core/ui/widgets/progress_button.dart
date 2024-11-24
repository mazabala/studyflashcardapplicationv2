import 'package:flashcardstudyapplication/core/ui/study_screen_controller.dart';
import 'package:flutter/material.dart';


class ProgressButtonWidget extends StatelessWidget {
  final StudyScreenController controller;

  const ProgressButtonWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => controller.handleIncorrect(),  // Correct answer
          child: const Text('Incorrect'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => controller.handleCorrect(),  // Incorrect answer
          child: const Text('Correct'),
        ),
      ],
    );
  }
}
