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

  Future<List<String>> _getDeckDifficulty() async {
    final deckReader = ref.read(deckServiceProvider);
    final userReader = ref.read(userServiceProvider);
    final subscriptionId = await userReader.getUserSubscriptionPlan();
    return await deckReader.getDeckDifficulty(subscriptionId);
  }

  Future<void> _createSystemDecks(List<String> categories, List<String> descriptions) async {
    try {
      final cardCount = int.tryParse(_cardCountController.text) ?? 10;

      if (categories.length != descriptions.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categories and descriptions must match in number')),
        );
        return;
      }

      final configs = List<SystemDeckConfig>.generate(
        categories.length,
        (index) => SystemDeckConfig(
          category: categories[index],
          description: descriptions[index],
          difficultyLevel: _selectedDifficulty ?? '',
          cardCount: cardCount
        )
      );

      await ref.read(deckProvider.notifier).systemCreateDecks(configs);

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
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _getDeckDifficulty(),
        ref.read(deckProvider.notifier).getDeckCategory(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final deckDifficulty = snapshot.data?[0] as List<String>;
        final categories = snapshot.data?[1] as List<String>;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final formWidth = isSmallScreen ? constraints.maxWidth : constraints.maxWidth * 0.7;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: formWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create System Decks',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                value: _selectedDifficulty,
                                decoration: const InputDecoration(
                                  labelText: 'Difficulty Level',
                                  border: OutlineInputBorder(),
                                ),
                                items: deckDifficulty.map((difficulty) {
                                  return DropdownMenuItem(
                                    value: difficulty,
                                    child: Text(difficulty),
                                  );
                                }).toList(),
                                onChanged: (difficulty) {
                                  setState(() {
                                    _selectedDifficulty = difficulty;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _cardCountController,
                                decoration: const InputDecoration(
                                  labelText: 'Number of Cards',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Select Categories',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: categories.map((category) {
                                  final isSelected = _selectedCategories?.contains(category) ?? false;
                                  return FilterChip(
                                    label: Text(category),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedCategories?.add(category);
                                          descriptionControllers[category] = TextEditingController();
                                        } else {
                                          _selectedCategories?.remove(category);
                                          descriptionControllers.remove(category);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                              ..._selectedCategories?.map((category) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: TextField(
                                  controller: descriptionControllers[category],
                                  decoration: InputDecoration(
                                    labelText: 'Description for $category',
                                    border: const OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                              )) ?? [],
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final descriptions = descriptionControllers.values
                                        .map((controller) => controller.text)
                                        .toList();
                                    _createSystemDecks(_selectedCategories!, descriptions);
                                  },
                                  child: const Text('Create System Decks'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}