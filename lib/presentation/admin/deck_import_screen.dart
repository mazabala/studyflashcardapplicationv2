import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flashcardstudyapplication/core/models/deck_import.dart';
import 'package:flashcardstudyapplication/core/services/deck/deck_service.dart';
import 'package:flashcardstudyapplication/core/utils/file_import_utils.dart';
import 'package:flashcardstudyapplication/core/services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flashcardstudyapplication/presentation/admin/import_report_screen.dart';

class DeckImportScreen extends StatefulWidget {
  const DeckImportScreen({Key? key}) : super(key: key);

  @override
  _DeckImportScreenState createState() => _DeckImportScreenState();
}

class _DeckImportScreenState extends State<DeckImportScreen> {
  bool _isLoading = false;
  String? _jsonContent;
  DeckImportResult? _importResult;
  bool _isAdmin = false;
  bool _hasCollection = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.currentUser;

    // Check if user is admin - implement your admin check logic here
    // This is a placeholder - replace with your actual admin check
    final isAdmin = await authService.isUserAdmin(user?.uid ?? '');

    setState(() {
      _isAdmin = isAdmin;
    });
  }

  Future<void> _pickJsonFile() async {
    setState(() {
      _isLoading = true;
      _importResult = null;
    });

    try {
      final jsonContent = await FileImportUtils.pickJsonFile();

      if (jsonContent != null) {
        // Check if the JSON contains collection information
        try {
          final jsonMap = jsonDecode(jsonContent);
          setState(() {
            _hasCollection = jsonMap is Map &&
                jsonMap.containsKey('collections') &&
                jsonMap['collections'] != null;
          });
        } catch (_) {
          setState(() {
            _hasCollection = false;
          });
        }
      }

      setState(() {
        _jsonContent = jsonContent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: ${e.toString()}')),
      );
    }
  }

  Future<void> _importDecks() async {
    if (_jsonContent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a JSON file first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final deckService = Provider.of<DeckService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final result =
          await deckService.importDecksFromJson(_jsonContent!, user.uid);

      setState(() {
        _importResult = result;
        _isLoading = false;
      });

      // Navigate to the import report screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImportReportScreen(importResult: result),
        ),
      );

      // Show success message with collection info if applicable
      if (result.success &&
          result.collectionIds != null &&
          result.collectionIds!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully created collection with ID: ${result.collectionIds!.first}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // Navigate to collection details
                Navigator.pushNamed(
                  context,
                  '/collection_details',
                  arguments: {'collectionId': result.collectionIds!.first},
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing decks: ${e.toString()}')),
      );
    }
  }

  void _downloadSampleTemplate() {
    FileImportUtils.downloadSampleTemplate();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Deck Import'),
        ),
        body: const Center(
          child: Text('You do not have permission to access this page.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Decks (Admin)'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Import Decks from JSON File',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Upload a JSON file containing deck definitions to bulk import decks into the system. You can also include collection information to automatically add the decks to a collection.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickJsonFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Select JSON File'),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: _downloadSampleTemplate,
                        icon: const Icon(Icons.download),
                        label: const Text('Download Sample Template'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_jsonContent != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'File Selected',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_hasCollection)
                                      const Text(
                                        'Collection information detected',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: _importDecks,
                                  child: const Text('Import Decks'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text('JSON Content Preview:'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              height: 200,
                              child: SingleChildScrollView(
                                child: Text(
                                  _jsonContent!,
                                  style:
                                      const TextStyle(fontFamily: 'monospace'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_importResult != null) ...[
                    Card(
                      color: _importResult!.success
                          ? Colors.green[50]
                          : Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _importResult!.success
                                  ? 'Import Successful'
                                  : 'Import Failed',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _importResult!.success
                                    ? Colors.green[800]
                                    : Colors.red[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(_importResult!.message),
                            const SizedBox(height: 8),
                            Text(
                              'Total Decks: ${_importResult!.totalDecks}',
                            ),
                            Text(
                              'Successfully Imported: ${_importResult!.successfulDecks}',
                            ),
                            if (_importResult!.collectionIds != null &&
                                _importResult!.collectionIds!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Collection Created: ${_importResult!.collectionIds!.first}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/collection_details',
                                        arguments: {
                                          'collectionId': _importResult!
                                              .collectionIds!.first
                                        },
                                      );
                                    },
                                    child: const Text('View Collection'),
                                  ),
                                ],
                              ),
                            ],
                            if (_importResult!.errors.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Errors:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.red),
                                ),
                                height: 150,
                                child: ListView.builder(
                                  itemCount: _importResult!.errors.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                        '• ${_importResult!.errors[index]}',
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
