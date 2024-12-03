import 'package:flashcardstudyapplication/core/themes/app_theme.dart';
import 'package:flutter/material.dart';


// Main User Management Page
class UserManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: Column(
        children: [
          UserActions(),
          Expanded(child: UserListView()),
        ],
      ),
    );
  }
}

// User Actions Widget
class UserActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => _navigateTo(context, CreateUserPage()),
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

// User List View
class UserListView extends StatelessWidget {
  final List<String> users = ['User 1', 'User 2', 'User 3']; // Mock data

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(users[index], style: Theme.of(context).textTheme.labelLarge),
          onTap: () => _navigateTo(context, UserDetailsView(user: users[index])),
        );
      },
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

// User Details View (Edit/View User)
class UserDetailsView extends StatelessWidget {
  final String user;

  UserDetailsView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit $user', 
        style: Theme.of(context).textTheme.labelLarge,),
      ),
      body: Center(child: Text('Edit details for $user', style: Theme.of(context).textTheme.bodyLarge)),
    );
  }
}

// Review Membership Page
class ReviewMembershipPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Membership', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Center(child: Text('Membership details here', style: Theme.of(context).textTheme.bodyMedium)),
    );
  }
}

// Mock CreateUserPage for navigation
class CreateUserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create User', style: Theme.of(context).textTheme.labelLarge)),
      body: Center(child: Text('Form to create a user', style: Theme.of(context).textTheme.titleMedium)),
    );
  }
}
