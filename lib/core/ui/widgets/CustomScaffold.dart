import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'dart:io' show Platform;

class CustomScaffold extends ConsumerStatefulWidget {
  final String currentRoute;
  final Widget body;
  final bool useScroll;

  const CustomScaffold({
    Key? key,
    required this.currentRoute,
    required this.body,
    this.useScroll = true,
  }) : super(key: key);

  @override
  _CustomScaffoldState createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends ConsumerState<CustomScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigateWithoutAnimation(BuildContext context, String route) {
    if (!mounted) return;
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.of(context).pushReplacementNamed(
        route,
        arguments: RouteSettings(name: route),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    final authNotifier = ref.watch(authProvider.notifier);
    final bool isLoggedIn = ref.watch(authProvider).isAuthenticated;
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 48,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSmallScreen 
                ? _buildMobileHeader()
                : _buildWebHeader(isLoggedIn, authNotifier),
            ),
            Expanded(
              child: widget.useScroll
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: widget.body,
                    ),
                  )
                : widget.body,
            ),
          ],
        ),
      ),
      endDrawer: isSmallScreen ? _buildDrawer(isLoggedIn, authNotifier) : null,
    );
  }

  Widget _buildMobileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 24,
        ),
        IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.white,
          onPressed: () {
            if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
              Navigator.of(context).pop();
            } else {
              _scaffoldKey.currentState?.openEndDrawer();
            }
          },
        ),
      ],
    );
  }

  Widget _buildWebHeader(bool isLoggedIn, AuthNotifier authNotifier) {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 32,
        ),
        const SizedBox(width: 48),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavLink('Home', '/'),
              _buildNavLink('Decks & Flashcards', '/deck'),
              _buildNavLink('Pricing', '/prices'),
              if (isLoggedIn) ...[
               
                _buildNavLink('My Decks', '/myDecks'),
                _buildNavButton('Logout', null, authNotifier),
              ] else ...[
                _buildNavLink('Login', '/login'),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavLink(String label, String route) {
    final bool isSelected = widget.currentRoute == route;
    return TextButton(
      onPressed: () => _navigateWithoutAnimation(context, route),
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(label),
    );
  }

  Widget _buildNavButton(String label, String? route, AuthNotifier auth) {
    return TextButton(
      onPressed: () async {
        if (route != null) {
          _navigateWithoutAnimation(context, route);
        } else {
          await auth.signOut();
          if (mounted) {
            _navigateWithoutAnimation(context, '/');
          }
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(label),
    );
  }

  Widget _buildDrawer(bool isLoggedIn, AuthNotifier auth) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Deck Focus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _buildDrawerItem('Home', '/', Icons.home),
          _buildDrawerItem('Decks & Flashcards', '/deck', Icons.library_books),
          _buildDrawerItem('Pricing', '/prices', Icons.monetization_on),
          _buildDrawerItem('Contact Us', '/contactUs', Icons.phone),
          _buildDrawerItem('About Us', '/aboutUs', Icons.info),
          if (isLoggedIn) ...[
            _buildDrawerItem('My Decks', '/myDecks', Icons.folder),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await auth.signOut();
                if (mounted) {
                  _navigateWithoutAnimation(context, '/');
                }
              },
            ),
          ] else ...[
            _buildDrawerItem('Login', '/login', Icons.login),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String label, String route, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: widget.currentRoute == route,
      onTap: () {
        Navigator.pop(context); // Close drawer
        Future.delayed(Duration.zero, () {
          if (mounted) {
            _navigateWithoutAnimation(context, route);
          }
        });
      },
    );
  }
}