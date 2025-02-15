import 'dart:math';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'dart:io' show Platform;


class CustomScaffold extends ConsumerStatefulWidget {
  final String currentRoute;
  final Widget body;
  final bool useScroll;
  final bool showBottomNav;

  const CustomScaffold({
    Key? key,
    required this.currentRoute,
    required this.body,
    this.useScroll = true,
    this.showBottomNav = true,
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
    
    final authNotifier = ref.watch(authStateProvider.notifier);
    final bool isLoggedIn = ref.watch(authStateProvider).isAuthenticated;
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
                : _buildWebHeader(isLoggedIn, ref),
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
      endDrawer: isSmallScreen ? _buildDrawer(isLoggedIn, ref) : null,
      floatingActionButton: widget.showBottomNav ? FloatingActionButton(
        onPressed: () {
          // Show create deck dialog
          Navigator.pushNamed(context, '/createDeck');
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, size: 32),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: widget.showBottomNav ? BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Left side of FAB
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNavItem(
                      context: context,
                      icon: Icons.style,
                      label: 'Decks',
                      route: '/myDecks',
                      isSelected: widget.currentRoute == '/myDecks',
                    ),
                  ],
                ),
              ),
              // Space for FAB
              const SizedBox(width: 80),
              // Right side of FAB
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNavItem(
                      context: context,
                      icon: Icons.person,
                      label: 'Profile',
                      route: '/userProfile',
                      isSelected: widget.currentRoute == '/userProfile',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ) : null,
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

  Widget _buildWebHeader(bool isLoggedIn, WidgetRef ref) {
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
                _buildNavButton('Logout', null, ref),
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

  Widget _buildNavButton(String label, String? route, WidgetRef ref) {
    return TextButton(
      onPressed: () async {
        if (route != null) {
          _navigateWithoutAnimation(context, route);
        } else {
          await ref.read(authStateProvider.notifier).signOut();
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

  Widget _buildDrawer(bool isLoggedIn, WidgetRef ref) {
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
                await ref.read(authStateProvider.notifier).signOut();
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

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : Colors.grey;

    return InkWell(
      onTap: () {
        if (route != widget.currentRoute) {
          _navigateWithoutAnimation(context, route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}