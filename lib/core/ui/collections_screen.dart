import 'package:flashcardstudyapplication/core/models/collection.dart';
import 'package:flashcardstudyapplication/core/models/user_collection.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> with SingleTickerProviderStateMixin {
  bool _isInitialized = false;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeCollections();
    }
  }

  Future<void> _initializeCollections() async {
    try {
      // Trigger loading of collections
      ref.read(userCollectionsProvider);
      ref.read(publicCollectionsProvider);
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading collections: $e')),
        );
      }
    }
  }

  Future<void> _showCreateCollectionDialog() async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String subject = '';
    String description = '';
    bool isPublic = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Collection'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter collection name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    onSaved: (value) => name = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      hintText: 'Enter collection subject',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a subject';
                      }
                      return null;
                    },
                    onSaved: (value) => subject = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter collection description',
                    ),
                    maxLines: 3,
                    onSaved: (value) => description = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return SwitchListTile(
                        title: const Text('Make Public'),
                        value: isPublic,
                        onChanged: (bool value) {
                          setState(() {
                            isPublic = value;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        final service = ref.read(collectionServiceProvider);
        await service.createCollection(
          name: name,
          subject: subject,
          description: description,
          deckIds: [],
          isPublic: isPublic,
        );
        ref.invalidate(userCollectionsProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Collection created successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating collection: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    final userCollections = ref.watch(userCollectionsProvider);
    final publicCollections = ref.watch(publicCollectionsProvider);

    if (!_isInitialized) {
      return CustomScaffold(
        currentRoute: currentRoute,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return CustomScaffold(
      currentRoute: currentRoute,
      useScroll: false,
      body: Stack(
        children: [
          DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'My Collections'),
                    Tab(text: 'Public Collections'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildCollectionList(
                        userCollections,
                        emptyMessage: 'No collections yet. Create one or add from public collections.',
                        itemBuilder: (collection) => ListTile(
                          title: Text(collection.collectionId),
                          subtitle: Text('${collection.decks.length} decks - ${(collection.completionRate * 100).toStringAsFixed(1)}% complete'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Navigate to collection details
                          },
                        ),
                      ),
                      _buildCollectionList(
                        publicCollections,
                        emptyMessage: 'No public collections available.',
                        itemBuilder: (collection) => ListTile(
                          title: Text(collection.name),
                          subtitle: Text('${collection.decks.length} decks - ${collection.subject}'),
                          trailing: const Icon(Icons.add),
                          onTap: () async {
                            try {
                              final service = ref.read(collectionServiceProvider);
                              await service.addCollectionToUser(collection.id);
                              ref.invalidate(userCollectionsProvider);
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Collection added to your collections')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error adding collection: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _showCreateCollectionDialog,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionList<T>(
    AsyncValue<List<T>> collections, {
    required String emptyMessage,
    required Widget Function(T) itemBuilder,
  }) {
    return collections.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text(emptyMessage));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          itemBuilder: (context, index) => Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: itemBuilder(items[index]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: SelectableText.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Error loading collections: '),
              TextSpan(
                text: error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 