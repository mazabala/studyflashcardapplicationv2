import 'package:flashcardstudyapplication/core/providers/deck_provider.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/themes/app_theme.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';

class DeckManagementPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckState = ref.watch(deckProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Deck Management', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Column(
        children: [
          DeckActions(),
          if (deckState.error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                deckState.error,
                style: TextStyle(color: Colors.red),
              ),
            ),
          if (deckState.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(child: DeckListView()),
        ],
      ),
    );
  }
}

class DeckActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => _navigateTo(context, CreateDeckPage()),
            child: Text('Create Deck'),
          ),
          ElevatedButton(
            onPressed: () => _navigateTo(context, AddCategoryPage()),
            child: Text('Add Category'),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class DeckListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckState = ref.watch(deckProvider);
    final decks = deckState.decks;

    if (decks.isEmpty) {
      return Center(child: Text('No decks available'));
    }

    return ListView.builder(
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final deck = decks[index];
        return ListTile(
          title: Text(deck.title, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            'Difficulty: ${deck.difficultyLevel} • Category: ${deck.categoryid}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context, ref, deck),
          ),
          onTap: () => _navigateTo(context, DeckDetailsView(deck: deck)),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Deck deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Deck'),
        content: Text('Are you sure you want to delete ${deck.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(deckProvider.notifier).deleteDeck(deck.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${deck.title} deleted')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting deck: $e')),
                );
              }
            },
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class DeckDetailsView extends ConsumerStatefulWidget {
  final Deck deck;

  DeckDetailsView({required this.deck});

  @override
  _DeckDetailsViewState createState() => _DeckDetailsViewState();
}

class _DeckDetailsViewState extends ConsumerState<DeckDetailsView> {
  late TextEditingController _titleController;
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.deck.title);
    _selectedDifficulty = widget.deck.difficultyLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.deck.title}', 
          style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Deck Title'),
            ),
            SizedBox(height: 16),
            FutureBuilder<List<String>>(
              future: ref.read(deckProvider.notifier)
                  .getDeckDifficulty(widget.deck.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration: InputDecoration(labelText: 'Difficulty Level'),
                    items: snapshot.data!.map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedDifficulty = value);
                    },
                  );
                }
                return CircularProgressIndicator();
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(deckProvider.notifier).updateDeck(
                    widget.deck.id,
                    _titleController.text,
                    _selectedDifficulty ?? widget.deck.difficultyLevel,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deck updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating deck: $e')),
                  );
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

class CreateDeckPage extends ConsumerStatefulWidget {
  @override
  _CreateDeckPageState createState() => _CreateDeckPageState();
}

class _CreateDeckPageState extends ConsumerState<CreateDeckPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _selectedDifficulty;
  final _cardCountController = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    final userSubPlan = ref.read(userServiceProvider).getUserSubscriptionPlan;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Deck', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Deck Title'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              FutureBuilder<List<String>>(
                future: ref.read(deckProvider.notifier).getDeckCategory(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(labelText: 'Category'),
                      items: snapshot.data!.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                    );
                  }
                  return CircularProgressIndicator();
                },
              ),
              SizedBox(height: 16),
              FutureBuilder<List<String>>(
                future: ref.read(deckProvider.notifier)
                    .getDeckDifficulty(userSubPlan as String),  // Replace with actual subscription ID
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return DropdownButtonFormField<String>(
                      value: _selectedDifficulty,
                      decoration: InputDecoration(labelText: 'Difficulty Level'),
                      items: snapshot.data!.map((difficulty) {
                        return DropdownMenuItem(
                          value: difficulty,
                          child: Text(difficulty),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedDifficulty = value);
                      },
                    );
                  }
                  return CircularProgressIndicator();
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _cardCountController,
                decoration: InputDecoration(labelText: 'Number of Cards'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedCategory == null || _selectedDifficulty == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }
                  
                  try {
                    final userId = ref.read(userServiceProvider).getCurrentUserId();
                    await ref.read(deckProvider.notifier).createDeck(
                      _titleController.text,
                      _selectedCategory!,
                      _descriptionController.text,
                      _selectedDifficulty!,
                      userId ?? '',
                      int.parse(_cardCountController.text),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deck created successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error creating deck: $e')),
                    );
                  }
                },
                child: Text('Create Deck'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cardCountController.dispose();
    super.dispose();
  }
}

class AddCategoryPage extends ConsumerStatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends ConsumerState<AddCategoryPage> {
  final _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Category', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category Name'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(deckProvider.notifier)
                      .addDeckCategory(_categoryController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Category added successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding category: $e')),
                  );
                }
              },
              child: Text('Add Category'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }
}