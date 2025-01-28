import 'package:flutter/material.dart';

class CardCountSlider extends StatelessWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;  // The onChanged callback

  const CardCountSlider({
    Key? key,
    this.initialValue = 10.0,  // Default value
    required this.onChanged,    // Require an onChanged function
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Number of Cards:'),
        Slider(
          value: initialValue,
          min: 1.0,
          max: 50.0,
          divisions: 99,
          label: initialValue.round().toString(),
          onChanged: onChanged,  // Call the passed onChanged callback
        ),
      ],
    );
  }
}
