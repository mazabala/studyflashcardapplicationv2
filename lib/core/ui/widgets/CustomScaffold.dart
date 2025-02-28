import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/theme_toggle.dart';
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
  late final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    // Create a unique key for each instance
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

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
    final brightness = theme.brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    final authNotifier = ref.watch(authStateProvider.notifier);
    final bool isLoggedIn = ref.watch(authStateProvider).isAuthenticated;

    // Responsive breakpoints
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600;
    final bool isMediumScreen = size.width >= 600 && size.width < 900;
    final bool isLargeScreen = size.width >= 900;

    // Padding based on screen size
    final EdgeInsets contentPadding =
        isSmallScreen ? const EdgeInsets.all(16) : const EdgeInsets.all(24);

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
                color: theme.colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSmallScreen
                  ? _buildMobileHeader(isDarkMode)
                  : _buildWebHeader(isLoggedIn, ref, isDarkMode),
            ),
            Expanded(
              child: widget.useScroll
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: contentPadding,
                        child: widget.body,
                      ),
                    )
                  : widget.body,
            ),
          ],
        ),
      ),
      endDrawer:
          isSmallScreen ? _buildDrawer(isLoggedIn, ref, isDarkMode) : null,
      bottomNavigationBar: widget.showBottomNav && isSmallScreen
          ? _buildBottomNavBar(context, theme)
          : null,
    );
  }

  Widget _buildMobileHeader(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Image.asset(
            isDarkMode
                ? 'assets/images/logo_dark.png'
                : 'assets/images/logo.png',
            height: 24,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback when image fails to load
              return Text(
                'Deck Focus',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              );
            },
          ),
        ),
        Row(
          children: [
            const ThemeToggle(
              isSmall: true,
              iconColor: Colors.white,
            ),
            const SizedBox(width: 8),
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
        ),
      ],
    );
  }

  Widget _buildWebHeader(bool isLoggedIn, WidgetRef ref, bool isDarkMode) {
    return Row(
      children: [
        Image.asset(
          isDarkMode ? 'assets/images/logo_dark.png' : 'assets/images/logo.png',
          height: 32,
          errorBuilder: (context, error, stackTrace) {
            // Fallback when image fails to load
            return Text(
              'Deck Focus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            );
          },
        ),
        const SizedBox(width: 16),
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
        const ThemeToggle(
          showLabel: true,
          iconColor: Colors.white,
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

  Widget _buildDrawer(bool isLoggedIn, WidgetRef ref, bool isDarkMode) {
    final theme = Theme.of(context);

    return Drawer(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo_dark.png',
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback when image fails to load
                      return Text(
                        'Deck Focus',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Deck Focus',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Study on the Go',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.home,
              title: 'Home',
              route: '/',
              isSelected: widget.currentRoute == '/',
            ),
            _buildDrawerItem(
              icon: Icons.style,
              title: 'Decks & Flashcards',
              route: '/deck',
              isSelected: widget.currentRoute == '/deck',
            ),
            _buildDrawerItem(
              icon: Icons.attach_money,
              title: 'Pricing',
              route: '/prices',
              isSelected: widget.currentRoute == '/prices',
            ),
            if (isLoggedIn) ...[
              _buildDrawerItem(
                icon: Icons.library_books,
                title: 'My Decks',
                route: '/myDecks',
                isSelected: widget.currentRoute == '/myDecks',
              ),
              _buildDrawerItem(
                icon: Icons.person,
                title: 'Profile',
                route: '/userProfile',
                isSelected: widget.currentRoute == '/userProfile',
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                onTap: () async {
                  await ref.read(authStateProvider.notifier).signOut();
                  if (mounted) {
                    Navigator.pop(context); // Close drawer
                    _navigateWithoutAnimation(context, '/');
                  }
                },
              ),
            ] else ...[
              _buildDrawerItem(
                icon: Icons.login,
                title: 'Login',
                route: '/login',
                isSelected: widget.currentRoute == '/login',
              ),
            ],
            const Divider(),
            _buildDrawerItem(
              icon: Icons.info,
              title: 'About Us',
              route: '/aboutUs',
              isSelected: widget.currentRoute == '/aboutUs',
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ThemeToggleSwitch(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? theme.colorScheme.secondary
            : theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onBackground,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.secondary.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context); // Close drawer
        _navigateWithoutAnimation(context, route);
      },
    );
  }

  Widget _buildBottomNavBar(BuildContext context, ThemeData theme) {
    return BottomAppBar(
      color: theme.colorScheme.primary,
      elevation: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              icon: Icons.home,
              label: 'Home',
              route: '/',
              isSelected: widget.currentRoute == '/',
            ),
            _buildBottomNavItem(
              icon: Icons.style,
              label: 'Decks',
              route: '/deck',
              isSelected: widget.currentRoute == '/deck',
            ),
            if (ref.watch(authStateProvider).isAuthenticated) ...[
              _buildBottomNavItem(
                icon: Icons.library_books,
                label: 'My Decks',
                route: '/myDecks',
                isSelected: widget.currentRoute == '/myDecks',
              ),
              _buildBottomNavItem(
                icon: Icons.person,
                label: 'Profile',
                route: '/userProfile',
                isSelected: widget.currentRoute == '/userProfile',
              ),
            ] else ...[
              _buildBottomNavItem(
                icon: Icons.login,
                label: 'Login',
                route: '/login',
                isSelected: widget.currentRoute == '/login',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required String route,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _navigateWithoutAnimation(context, route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
