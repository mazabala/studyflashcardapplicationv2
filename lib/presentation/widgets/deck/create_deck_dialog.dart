import 'package:flashcardstudyapplication/core/providers/deck_provider.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/presentation/widgets/deck/CardCountSlider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Make sure to import the slider widget

class CreateDeckDialog extends ConsumerStatefulWidget {
  final Function(String topic, String focus, String category,
      String difficultyLevel, int cardcount) onSubmit;

  const CreateDeckDialog({super.key, required this.onSubmit});

  @override
  _CreateDeckDialogState createState() => _CreateDeckDialogState();
}

class _CreateDeckDialogState extends ConsumerState<CreateDeckDialog> {
  // Declare state variables to store selected category and difficulty level
  String? _selectedCategory;
  String? _selectedDifficulty;

  // Declare state variables for category and difficulty level data
  List<String> categories = [];
  List<String> difficultyLevels = [];
  bool _isInitialized = false;

  // Declare TextEditingController for the deck title and description
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _focusController = TextEditingController();

  double _cardCount = 10.0; // Initial slider value

  // Function to fetch categories (replace with your actual fetching logic)
  Future<void> _fetchCategories() async {
    try {
      final deckReader = ref.read(deckServiceProvider);
      final categoriesFromDb = await deckReader
          .getDeckCategory(); // Assuming `getDeckCategories` exists in your service

      if (mounted) {
        setState(() {
          categories = categoriesFromDb;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  // Function to fetch deck difficulty levels (your existing function)
  Future<void> _fetchDeckDifficulty() async {
    try {
      final deckReader = ref.read(deckServiceProvider);
      final userReader = ref.read(userServiceProvider);
      final subscriptionId = ref.watch(userStateProvider).subscriptionPlanID;
      final deckDifficulty = await deckReader.getDeckDifficulty(subscriptionId);

      if (mounted) {
        setState(() {
          difficultyLevels = deckDifficulty;
        });
      }
    } catch (e) {
      print('Error fetching difficulty levels: $e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _fetchCategories();
      _fetchDeckDifficulty();
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Deck'),
      content: categories.isEmpty || difficultyLevels.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner while fetching data
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Deck Title TextField
                TextField(
                  controller: _topicController,
                  decoration: const InputDecoration(labelText: 'Topic'),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _focusController,
                  decoration: const InputDecoration(labelText: 'Key Focus'),
                ),

                // Replace the TextField with the CardCountSlider widget
                CardCountSlider(
                  initialValue:
                      _cardCount, // Set the initial value for the slider
                  onChanged: (value) {
                    setState(() {
                      _cardCount =
                          value; // Update the card count based on slider value
                    });
                  },
                ),

                // Category Dropdown
                DropdownButton<String>(
                  borderRadius: BorderRadius.circular(10),
                  value: _selectedCategory,
                  hint: const Text('Select Category'),
                  onChanged: (newValue) {
                    if (mounted) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                  items: categories
                      .map<DropdownMenuItem<String>>((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ),

                // Difficulty Level Dropdown
                DropdownButton<String>(
                  borderRadius: BorderRadius.circular(10),
                  value: _selectedDifficulty,
                  hint: const Text('Select Difficulty Level'),
                  onChanged: (newValue) {
                    if (mounted) {
                      setState(() {
                        _selectedDifficulty = newValue;
                      });
                    }
                  },
                  items: difficultyLevels
                      .map<DropdownMenuItem<String>>((String level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () {
            // Close the dialog
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final topic = _topicController.text;
            final focus = _focusController.text;
            final category = _selectedCategory ??
                ''; // Default to empty string if no category selected
            final difficultyLevel = _selectedDifficulty ??
                ''; // Default to empty string if no difficulty selected

            final cardcount =
                _cardCount.toInt(); // Convert the slider value to an integer

            if (category.isEmpty || difficultyLevel.isEmpty) {
              // You can show a warning or error here if category or difficulty is not selected
              print('Please select both category and difficulty level.');
              return;
            }

            // Call the onSubmit callback with the values entered
            widget.onSubmit(topic, focus, category, difficultyLevel, cardcount);

            // Close the dialog after submitting
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
