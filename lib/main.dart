import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/providers/revenuecat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
import 'package:flashcardstudyapplication/core/themes/app_theme.dart';
import 'package:flashcardstudyapplication/core/navigation/router_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/ui/home_screen.dart';
import 'package:flashcardstudyapplication/core/services/api/api_manager.dart';

// Add a loading state provider
final initializationProvider = StateProvider<bool>((ref) => false);

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
      print('API client initialized');
      
      // Get Supabase credentials
      final supabaseUrl = apiClient.getSupabaseUrl();
      final supabaseAnonKey = apiClient.getSupabaseAnonKey();
      
      // Initialize Supabase with session persistence
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );

      print('Supabase initialized');

      // Initialize ApiManager
      await ApiManager.instance.initialize();
      print('ApiManager initialized');

      // Initialize RevenueCat
      await ref.read(revenueCatClientProvider.notifier).initialize();
      print('RevenueCat initialized');
      
      final response = await Supabase.instance.client.from('api_resources').select('*').eq('name', 'ChatGPT').single();
      final baseKey = response['api_key'];
      final baseUrl = response['Other'];

      print('baseKey: $baseKey');
      print('baseUrl: $baseUrl');

      await apiClient.setupOpenAI(baseUrl, baseKey);

      print('OpenAI initialized');
      
      Supabase.instance.client.auth.signOut();

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

    return MaterialApp(
      onGenerateRoute: RouteManager.generateRoute,
      title: 'Deck Focus',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: _initializing
          ? const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      )
          : const HomeScreen(),
    );
  }
}