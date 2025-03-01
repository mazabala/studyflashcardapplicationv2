import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
import 'package:flashcardstudyapplication/core/themes/app_theme.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';
import 'package:flashcardstudyapplication/core/navigation/router_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/ui/home_screen.dart';
import 'package:flashcardstudyapplication/core/services/api/api_manager.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Add a loading state provider
final initializationProvider = StateProvider<bool>((ref) => false);

// Add a theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

// Theme mode notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    state = ThemeMode.values[themeIndex];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  Future<void> toggleThemeMode() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app immediately with ProviderScope
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _initializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize API client first
      final apiClient = ApiClient();
      await apiClient.initialize();

      // Get Supabase credentials
      final supabaseUrl = apiClient.getSupabaseUrl();
      final supabaseAnonKey = apiClient.getSupabaseAnonKey();

      // Initialize Supabase with session persistence
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );

      // Initialize ApiManager
      await ApiManager.instance.initialize();

      // // Initialize PostHog
      final posthogService = ref.read(posthogServiceProvider);
      await posthogService.initialize();
      log('PostHog initialized');

      final response = await Supabase.instance.client
          .from('api_resources')
          .select('*')
          .eq('name', 'ChatGPT')
          .single();
      final baseKey = response['api_key'];
      final baseUrl = response['Other'];

      await apiClient.setupOpenAI(baseUrl, baseKey);

      // Reset analytics on sign out
      Supabase.instance.client.auth.signOut();
      // ref.read(analyticsProvider.notifier).reset();

      // Mark initialization as complete
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
      print('App initialization complete');
    } catch (e) {
      print('Error initializing app: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _initializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error: $_error'),
          ),
        ),
      );
    }

    // Get the current theme mode from the provider
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      onGenerateRoute: RouteManager.generateRoute,
      title: 'Deck Focus',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: _initializing ? const _LoadingScreen() : const HomeScreen(),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/logos/dark mode/logo-darkmode.png'
                    : 'assets/logos/light mode/logo-lightmode.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback when image fails to load
                  return Container(
                    height: 120,
                    width: 240,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Deck Focus',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'DECK FOCUS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const Text(
                'STUDY ON THE GO',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
