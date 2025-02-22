import 'dart:developer';

import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/ui/systemDeck_Screen.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/management/DeckManagement.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/management/UserManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminManagementScreen extends ConsumerStatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  _AdminManagementScreenState createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends ConsumerState<AdminManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.watch(userStateProvider);
    });

    return CustomScaffold(
      currentRoute: currentRoute,
      useScroll: false,
      body: DefaultTabController(
        length: 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Theme.of(context).colorScheme.surface,
              elevation: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Admin Management',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const TabBar(
                    tabs: [
                      Tab(text: 'Users'),
                      Tab(text: 'Decks'),
                      Tab(text: 'Create System Decks'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: const UserManagementPage(),
                  ),
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: const DeckManagementPage(),
                  ),
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: const SystemDeckScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
