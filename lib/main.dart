import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/providers/revenuecat_provider.dart';

import 'package:flashcardstudyapplication/core/services/revenuecat/revenuecat_service.dart';
import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart'; // Import ApiClient and the provider
import 'package:flashcardstudyapplication/core/themes/app_theme.dart';
import 'package:flashcardstudyapplication/core/navigation/router_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  // Add this line to initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize API client first
    final apiClient = ApiClient();
    await apiClient.initialize();
    print('API client initialized');
    // Get Supabase credentials
    final supabaseUrl = apiClient.getSupabaseUrl();
    final supabaseAnonKey = apiClient.getSupabaseAnonKey();
    
    // Initialize Supabase with session persistence
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    
    final supabaseClient = Supabase.instance.client;
    print('Supabase initialized');
    // Add runApp call here
    runApp(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(apiClient),
        ],
        child: MyApp(
          apiClient: apiClient,
          supabaseClient: supabaseClient,
        ),
      ),
    );
    
  } catch (e) {
    print('Failed to initialize services: $e');
    return;
  }
}

class MyApp extends ConsumerStatefulWidget {
  final ApiClient apiClient;
  final SupabaseClient supabaseClient;

  const MyApp({
    super.key, 
    required this.apiClient, 
    required this.supabaseClient,
  });

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize auth state when app starts
      await ref.read(authProvider.notifier).initializeAuth();
    } catch (e) {
      print('Error initializing app: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Flashcard Study App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: authState.isAuthenticated ? '/home' : '/', // Adjust initial route based on auth state
      onGenerateRoute: RouteManager.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
