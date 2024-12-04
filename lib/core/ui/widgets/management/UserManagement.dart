// user_management_page.dart
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/themes/app_theme.dart';

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: Column(
        children: [
          UserActions(),
          if (userState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                userState.errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          Expanded(child: UserListView()),
        ],
      ),
    );
  }
}

class UserActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () async {
              final userNotifier = ref.read(userProvider.notifier);
              final isAdmin = await userNotifier.isUserAdmin();
              if (isAdmin) {
                _navigateTo(context, CreateUserPage());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Only admins can create users')),
                );
              }
            },
            child: Text('Create User'),
          ),
          ElevatedButton(
            onPressed: () => _navigateTo(context, ReviewMembershipPage()),
            child: Text('Review Membership'),
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

class UserListView extends ConsumerStatefulWidget {
  @override
  _UserListViewState createState() => _UserListViewState();
}

class _UserListViewState extends ConsumerState<UserListView> {
  @override
  void initState() {
    super.initState();
    // Fetch user details when the widget is initialized
    ref.read(userProvider.notifier).fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    if (userState.errorMessage != null) {
      return Center(child: Text('Error: ${userState.errorMessage}'));
    }

    return ListView.builder(
      itemCount: 3, // Replace with actual user count
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            'User ${index + 1}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            'Subscription: ${userState.subscriptionPlan ?? "None"}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: userState.isExpired == true
            ? Icon(Icons.warning, color: Colors.red)
            : null,
          onTap: () => _navigateToDetails(context, index),
        );
      },
    );
  }

  void _navigateToDetails(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsView(user: 'User ${index + 1}'),
      ),
    );
  }
}

class UserDetailsView extends ConsumerWidget {
  final String user;

  UserDetailsView({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit $user', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Text(
              'Subscription Plan: ${userState.subscriptionPlan ?? "None"}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 8),
            if (userState.isExpired == true)
              Text(
                'Subscription Expired',
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement upgrade subscription logic
                ref.read(userProvider.notifier).upgradeSubscription('premium');
              },
              child: Text('Upgrade Subscription'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewMembershipPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Membership', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Plan: ${userState.subscriptionPlan ?? "None"}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            if (userState.isExpired == true)
              Text(
                'Your subscription has expired',
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(userProvider.notifier).upgradeSubscription('premium');
              },
              child: Text('Upgrade to Premium'),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateUserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Create User', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(userProvider.notifier)
                      .updateUserProfile(nameController.text, emailController.text);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }
}