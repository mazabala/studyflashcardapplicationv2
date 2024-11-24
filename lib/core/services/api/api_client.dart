import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flashcardstudyapplication/core/interfaces/i_api_service.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flashcardstudyapplication/core/error/error_handler.dart';

class ApiClient implements IApiService {
  late final String _baseUrl;
  late final String _baseKey;
  late final String _supabaseUrl;
  late final String _supabaseAnonKey;

  late final http.Client _client;
  late final Map<String, dynamic> _config;

  bool _initialized = false; 

  ApiClient() {
    print('New ApiClient instance created');
    _client = http.Client();
  }

    bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    try {
      // Load and parse YAML config
      final yamlString = await rootBundle.loadString('lib/core/config/api.config.yaml');
      final yamlMap = loadYaml(yamlString);
      _config = Map<String, dynamic>.from(yamlMap['api']);

      // Validate the required fields exist
      if (!_config.containsKey('openai') || 
          !_config['openai'].containsKey('base_url') ||
          !_config['openai'].containsKey('openai_key')) {
        throw Exception('Missing required OpenAI configuration');
      }
      
      
     

      // Set Supabase credentials
      _supabaseUrl = _config['supabase']['supabase_url'];
      _supabaseAnonKey = _config['supabase']['supabase_key'];

      // Set base URL (e.g., for OpenAI API)
      _baseUrl = _config['openai']['base_url'];
      _baseKey= _config['openai']['openai_key'];
      _initialized = true;
    } catch (e) {
      print('Error initializing ApiClient: $e');
      throw ErrorHandler.handle(e, message: 'Failed to load API configuration');
    }
  }

  @override
  String getSupabaseUrl() => _supabaseUrl;

  @override
  String getSupabaseAnonKey() => _supabaseAnonKey;

  @override
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: await _getHeaders());
      return await _handleResponse(response);
    } catch (e) {
      throw ErrorHandler.handle(e, message: 'GET request failed');
    }
  }

  @override
  Future<Map<String, dynamic>> post(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse(_baseUrl);
      final header = await _getHeaders();

      final response = await _client.post(uri, headers:  header, body: body);
      return await _handleResponse(response);
    } catch (e) {
      print (e);
      throw ErrorHandler.handle(e, message: 'POST request failed');
    }
  }

  @override
  Future<Map<String, dynamic>> put(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await _client.put(uri, headers: await _getHeaders(), body: jsonEncode(body));
      return await _handleResponse(response);
    } catch (e) {
      throw ErrorHandler.handle(e, message: 'PUT request failed');
    }
  }

  @override
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await _client.delete(uri, headers: await _getHeaders());
      return await _handleResponse(response);
    } catch (e) {
      throw ErrorHandler.handle(e, message: 'DELETE request failed');
    }
  }

  // Utility to handle response and parse it
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      print('Error response: ${response.body}');
      throw ErrorHandler.handleApiError(response.body, message: 'API returned an error');
    }
  }

  // Utility to get headers
  Future<Map<String, String>> _getHeaders() async {


    final apiKey =  _getApiKey();
   
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_baseKey',
    };
  }

  // Utility to get API key
  String _getApiKey()  {

    if(_baseKey.isEmpty || _baseKey==null){

      throw Exception ('key not found');
    }
    else{
    return _baseKey;
    }
  }
}

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('ApiClient must be initialized in main');
});
