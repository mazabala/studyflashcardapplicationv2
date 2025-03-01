import 'package:flashcardstudyapplication/core/models/collection.dart';
import 'package:flashcardstudyapplication/core/models/user_collection.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/providers/collection_provider.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/collection/collection_deck_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen>
    with SingleTickerProviderStateMixin {
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
      // Initialize first page of collections
      await Future.wait([
        ref.read(userStateProvider.notifier).loadUserCollections(),
        ref.read(publicCollectionsProvider(0).future),
      ]);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
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
        final collection = await service.createCollection(
          name: name,
          subject: subject,
          description: description,
          deckIds: [],
          isPublic: isPublic,
        );

        // Add collection to user state
        await ref.read(userStateProvider.notifier).addCollection(collection);

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

  Future<void> _showAddDecksDialog(Collection collection) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Decks to ${collection.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: CollectionDeckManager(collection: collection),
                ),
              ],
            ),
          ),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    final userState = ref.watch(userStateProvider);
    final publicCollections = ref.watch(publicCollectionsProvider(0));

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
                        AsyncValue.data(userState.collections),
                        emptyMessage:
                            'No collections yet. Create one or add from public collections.',
                        itemBuilder: (UserCollection userCollection) =>
                            Consumer(
                          builder: (context, ref, child) {
                            final collectionFuture = ref
                                .read(collectionServiceProvider)
                                .getCollection(userCollection.collectionId);

                            print(
                                'amount of decks: ${userCollection.decks.length}');
                            return ListTile(
                              title: FutureBuilder<Collection>(
                                future: collectionFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      snapshot.data!.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text(
                                      'Error loading collection: ${snapshot.error}',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    );
                                  }
                                  return const Text(
                                    'Loading...',
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                              subtitle: Text(
                                '${userCollection.decks.length} decks - ${(userCollection.completionRate * 100).toStringAsFixed(1)}% complete',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              trailing: SizedBox(
                                width: 80,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () async {
                                        final collection =
                                            await collectionFuture;
                                        if (mounted) {
                                          _showAddDecksDialog(collection);
                                        }
                                      },
                                      tooltip: 'Add decks',
                                    ),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                try {
                                  final collection = await collectionFuture;

                                  if (mounted) {
                                    Navigator.pushNamed(
                                      context,
                                      '/collection_study',
                                      arguments: {
                                        'collection': collection,
                                        'userCollection': userCollection,
                                      },
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Error loading collection: $e')),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                      _buildCollectionList<Collection>(
                        publicCollections,
                        emptyMessage: 'No public collections available.',
                        itemBuilder: (Collection collection) => ListTile(
                          title: Text(
                            collection.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Text(
                            '${collection.decks.length} decks - ${collection.subject}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          trailing: const Icon(Icons.add),
                          onTap: () async {
                            try {
                              await ref
                                  .read(userStateProvider.notifier)
                                  .addCollection(collection);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Collection added to your collections')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error adding collection: $e')),
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
}
