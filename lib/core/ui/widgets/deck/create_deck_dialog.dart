import 'package:flashcardstudyapplication/core/providers/deck_provider.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CardCountSlider.dart';  // Make sure to import the slider widget

class CreateDeckDialog extends ConsumerStatefulWidget {
  final Function(String title, String description, String category, String difficultyLevel, int cardcount) onSubmit;

  const CreateDeckDialog({required this.onSubmit});

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

  // Declare TextEditingController for the deck title and description
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  double _cardCount = 10.0;  // Initial slider value

  // Function to fetch categories (replace with your actual fetching logic)
  Future<void> _fetchCategories() async {
    try {
      final deckReader = ref.read(deckServiceProvider);
      final categoriesFromDb = await deckReader.getDeckCategory(); // Assuming `getDeckCategories` exists in your service

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
      final subscriptionId = await userReader.getUserSubscriptionPlan();
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

  // Call both fetch methods when the dialog is shown
  @override
  void initState() {
    super.initState();
    _fetchCategories();  // Fetch categories
    _fetchDeckDifficulty();  // Fetch difficulty levels
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create New Deck'),
      content: categories.isEmpty || difficultyLevels.isEmpty
          ? Center(child: CircularProgressIndicator())  // Show loading spinner while fetching data
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Deck Title TextField
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Deck Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Deck Description'),
                ),

                // Replace the TextField with the CardCountSlider widget
                CardCountSlider(
                  initialValue: _cardCount,  // Set the initial value for the slider
                  onChanged: (value) {
                    setState(() {
                      _cardCount = value;  // Update the card count based on slider value
                    });
                  },
                ),

                // Category Dropdown
                DropdownButton<String>(
                  value: _selectedCategory,
                  hint: Text('Select Category'),
                  onChanged: (newValue) {
                    if (mounted) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                  items: categories.map<DropdownMenuItem<String>>((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ),

                // Difficulty Level Dropdown
                DropdownButton<String>(
                  value: _selectedDifficulty,
                  hint: Text('Select Difficulty Level'),
                  onChanged: (newValue) {
                    if (mounted) {
                      setState(() {
                        _selectedDifficulty = newValue;
                      });
                    }
                  },
                  items: difficultyLevels.map<DropdownMenuItem<String>>((String level) {
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
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text;
            final category = _selectedCategory ?? '';  // Default to empty string if no category selected
            final difficultyLevel = _selectedDifficulty ?? ''; // Default to empty string if no difficulty selected
            final description = _descriptionController.text;
            final cardcount = _cardCount.toInt();  // Convert the slider value to an integer

            if (category.isEmpty || difficultyLevel.isEmpty) {
              // You can show a warning or error here if category or difficulty is not selected
              print('Please select both category and difficulty level.');
              return;
            }

            // Call the onSubmit callback with the values entered
            widget.onSubmit(title, description, category, difficultyLevel, cardcount);

            // Close the dialog after submitting
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: Text('Create'),
        ),
      ],
    );
  }
}
