import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/providers/revenuecat_provider.dart';
import 'package:flashcardstudyapplication/core/providers/subscription_provider.dart';
import 'package:flashcardstudyapplication/core/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
import 'package:flashcardstudyapplication/core/themes/app_theme.dart';
import 'package:flashcardstudyapplication/core/navigation/router_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
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
    
    runApp(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(apiClient),
          supabaseClientProvider.overrideWithValue(supabaseClient),
        ],
        child: const MyApp(),
      ),
    );
    
  } catch (e) {
    print('Failed to initialize services: $e');
    return;
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

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
      // 2. Initialize auth state
      await ref.read(authProvider.notifier).initializeAuth();
      
      // 3. Initialize RevenueCat
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        print('user is authenticated');
          final revenueCatService = await ref.read(revenueCatClientProvider.future);
          await revenueCatService.initialize();
          print('RevenueCat initialized');
          
          // 4. Finally initialize subscription service
          await ref.read(subscriptionProvider.notifier).initialize();
          print('Subscription service initialized');
      }
    } catch (e) {
      print('Error initializing app: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    //final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Flashcard Study App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute:  '/',
      onGenerateRoute: RouteManager.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
