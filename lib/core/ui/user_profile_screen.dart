import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flutter/material.dart';
 // Import CustomScaffold

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/userProfile';

    return CustomScaffold(
      currentRoute: currentRoute,  // Pass the current route to customize the AppBar
      body: Center(
        child: Text('Welcome to the User Profile Screen'),
      ),
    );
  }
}
