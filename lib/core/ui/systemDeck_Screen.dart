import 'package:flashcardstudyapplication/core/providers/deck_provider.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/services/deck/deck_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SystemDeckScreen extends ConsumerStatefulWidget {
  const SystemDeckScreen({super.key});

  @override
  _SystemDeckScreenState createState() => _SystemDeckScreenState();
}

class _SystemDeckScreenState extends ConsumerState<SystemDeckScreen> {
  List<String>? _selectedCategories = [];
  String? _selectedDifficulty;
  final TextEditingController _cardCountController = TextEditingController();
  final Map<String, TextEditingController> descriptionControllers = {};
  List<String> _filteredCategories = [];
  List<String> _difficulties = [];
  final TextEditingController _newCategoryController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final difficulties = await _getDeckDifficulty();
      final categories = await ref.read(deckProvider.notifier).getDeckCategory();
      
      if (mounted) {
        setState(() {
          _difficulties = difficulties;
          _filteredCategories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading initial data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<String>> _getDeckDifficulty() async {
    final deckReader = ref.read(deckServiceProvider);
    final userReader = ref.read(userServiceProvider);
    final userService = ref.read(userProvider);
    final subscriptionId = userService.subscriptionPlanID;
    return await deckReader.getDeckDifficulty(subscriptionId);
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories?.contains(category) ?? false) {
        _selectedCategories?.remove(category);
        descriptionControllers.remove(category);
      } else {
        _selectedCategories?.add(category);
        descriptionControllers[category] = TextEditingController();
      }
    });
  }

  Future<void> _addCategory(String newCategory) async {
    if (newCategory.isEmpty) return;
    
    await ref.read(deckProvider.notifier).addDeckCategory(newCategory);
    final categories = await ref.read(deckProvider.notifier).getDeckCategory();
    
    if (mounted) {
      setState(() {
        _filteredCategories = categories;
        if (!_filteredCategories.contains(newCategory)) {
          _filteredCategories.add(newCategory);
        }
      });
    }
    _newCategoryController.clear();
  }

  Future<void> _createSystemDecks() async {
    try {
      final cardCount = int.tryParse(_cardCountController.text) ?? 10;
      final descriptions = descriptionControllers.values
          .map((controller) => controller.text)
          .toList();

      if (_selectedCategories?.length != descriptions.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categories and descriptions must match in number')),
        );
        return;
      }

      final configs = List<SystemDeckConfig>.generate(
        _selectedCategories!.length,
        (index) => SystemDeckConfig(
          category: _selectedCategories![index],
          description: descriptions[index],
          difficultyLevel: _selectedDifficulty ?? '',
          cardCount: cardCount
        )
      );

     // await ref.read(deckProvider.notifier).systemCreateDecks(configs);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/myDecks');
      }
    } catch (e) {
      if (mounted) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating system decks: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final formWidth = isSmallScreen ? constraints.maxWidth : constraints.maxWidth * 0.7;

        return SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: formWidth),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create System Deck',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),

                  // Categories Section
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Categories ExpansionTile
                  Card(
                    child: ExpansionTile(
                      title: Text(_selectedCategories!.isEmpty
                          ? 'Select Categories'
                          : '${_selectedCategories!.length} selected'),
                      children: [
                        ..._filteredCategories.map(
                          (category) => CheckboxListTile(
                            title: Text(category),
                            value: _selectedCategories?.contains(category),
                            onChanged: (bool? value) {
                              _toggleCategory(category);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _newCategoryController,
                                  decoration: const InputDecoration(
                                    hintText: 'Add new category',
                                    border: OutlineInputBorder(),
                                  ),
                                  onSubmitted: _addCategory,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _addCategory(_newCategoryController.text),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description Fields
                  if (_selectedCategories!.isNotEmpty) ...[
                    Text(
                      'Deck Focus',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._selectedCategories!.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextField(
                          controller: descriptionControllers[category],
                          decoration: InputDecoration(
                            labelText: 'Description for $category',
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                  ],

                  // Difficulty Selection
                  Text(
                    'Difficulty',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select Difficulty',
                    ),
                    isExpanded: true,
                    items: _difficulties.map((difficulty) {
                      return DropdownMenuItem<String>(
                        value: difficulty,
                        child: Text(difficulty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDifficulty = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Card Count Input
                  Text(
                    'Card Count',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cardCountController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter number of cards',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),

                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _createSystemDecks,
                      child: const Text('Create System Decks'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}