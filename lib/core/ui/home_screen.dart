import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/navigation/router_manager.dart';

import 'package:flashcardstudyapplication/core/ui/deck_screen.dart';
import 'package:flashcardstudyapplication/core/ui/user_profile_screen.dart';
import 'package:flashcardstudyapplication/core/ui/login_screen.dart';



class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Getting the current route to pass to the CustomAppBar
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

    return CustomScaffold(
      currentRoute: currentRoute,  // Pass the current route to customize the AppBar
      body: Center(
        child: Text('This is the Home page'),
      ),
    );
  }
}