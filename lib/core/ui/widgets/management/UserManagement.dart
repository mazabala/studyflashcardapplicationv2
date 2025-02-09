// user_management_page.dart

import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/themes/app_theme.dart';

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    

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
                style: const TextStyle(color: Colors.red),
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
              final userNotifier = ref.read(userStateProvider.notifier);
              final isAdmin = ref.watch(userStateProvider).isAdmin;
              if (isAdmin != null && isAdmin) {
                _navigateTo(context, CreateUserPage());

              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Only admins can create users')),
                );
              }
            },
            child: Text('Create User'),
          ),
          ElevatedButton(
            onPressed: () => _navigateTo(context, ReviewMembershipPage()),
            child: const Text('Review Membership'),
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load users when the widget is initialized
    Future.microtask(() => ref.read(adminStateProvider.notifier).loadUsers());
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminStateProvider);


    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        if (adminState.isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (adminState.users.isEmpty)
          const Expanded(child: Center(child: Text('No users found')))
        else
          Expanded(
            child: ListView.builder(
              itemCount: adminState.users.where((user) {
                final searchStr = '${user['firstname']} ${user['lastname']} ${user['email']}'.toLowerCase();
                return searchStr.contains(_searchQuery);
              }).length,
              itemBuilder: (context, index) {
                final filteredUsers = adminState.users.where((user) {
                  final searchStr = '${user['firstname']} ${user['lastname']} ${user['email']}'.toLowerCase();
                  return searchStr.contains(_searchQuery);
                }).toList();
                final user = filteredUsers[index];
                return ListTile(
                  title: Text(
                    'Name: ${user['firstname']} ${user['lastname']}\nEmail: ${user['email']}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Subscription: ${user['subscription_tier'] ?? 'None'}\nUser Type: ${user['role'] ?? 'No role'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit Profile'),
                        onTap: () => editProfileDialog(context,user['id'], ref),
                      ),
                      PopupMenuItem(
                        child: const Text('Update Role'),
                        onTap: () => _showRoleUpdateDialog(context, user['id']),
                      ),
                      PopupMenuItem(
                        child: const Text('Update Subscription'),
                        onTap: () => _showSubscriptionUpdateDialog(context, user['id']),
                      ),
                      PopupMenuItem(
                        child: const Text('Delete User'),
                        onTap: () => _showDeleteConfirmation(context, user['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showRoleUpdateDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('User'),
              onTap: () {
                ref.read(adminStateProvider.notifier).updateUserRole(userId, 'user');
                Navigator.pop(context);
              },

            ),
            ListTile(
              title: const Text('Admin'),
              onTap: () {
                ref.read(adminStateProvider.notifier).updateUserRole(userId, 'admin');
                Navigator.pop(context);
              },

            ),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionUpdateDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Free'),
              onTap: () {
                ref.read(adminStateProvider.notifier).updateUserSubscription(userId, 'free');
                Navigator.pop(context);
              },

            ),
            ListTile(
              title: const Text('Premium'),
              onTap: () {
                ref.read(adminStateProvider.notifier).updateUserSubscription(userId, 'premium');
                Navigator.pop(context);
              },

            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(adminStateProvider.notifier).deleteUser(userId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),

        ],
      ),
    );
  }
}

void editProfileDialog(BuildContext context, String userId, WidgetRef ref) {

    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    final userNotifier = ref.read(userStateProvider.notifier);


    print('userId to edit: $userId');
    showDialog(
      
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController ,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: lastNameController ,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: 'Save',
              icon: Icons.save,
              onPressed: () {
                userNotifier.userService.updateUserProfile(
                   firstNameController.text,
                   lastNameController.text,
                   userId
                );

                  Navigator.pop(context);
                
              },
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }


class UserDetailsView extends ConsumerWidget {
  final String user;

  UserDetailsView({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);



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
           const  SizedBox(height: 16),
            Text(
              'Subscription Plan: ${userState.subscriptionPlan ?? "None"}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
             const SizedBox(height: 8),
            if (userState.isExpired == true)
              const Text(
                'Subscription Expired',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement upgrade subscription logic
                ref.read(userStateProvider.notifier).upgradeSubscription('premium');
              },
              child: const Text('Upgrade Subscription'),

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
    final userState = ref.watch(userStateProvider);


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
           const SizedBox(height: 8),
            if (userState.isExpired == true)
              const Text(
                'Your subscription has expired',
                style: TextStyle(color: Colors.red),
              ),
           const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(userStateProvider.notifier).upgradeSubscription('premium');
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
  const CreateUserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Create User', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(adminStateProvider.notifier)
                      .inviteUser(emailController.text);
                  Navigator.pop(context);

                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Invite User'),
            ),
          ],
        ),
      ),
    );
  }
}