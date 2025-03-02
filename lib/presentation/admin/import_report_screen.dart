import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/models/deck_import.dart';

class ImportReportScreen extends StatelessWidget {
  final DeckImportResult importResult;

  const ImportReportScreen({Key? key, required this.importResult})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummarySection(),
            const SizedBox(height: 16),
            if (importResult.collectionIds != null &&
                importResult.collectionIds!.isNotEmpty)
              _buildSuccessfulCollectionsSection(context),
            const SizedBox(height: 16),
            _buildFailedCollectionsSection(),
            const SizedBox(height: 16),
            _buildFailedDecksSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Card(
      color: importResult.success ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              importResult.success ? 'Import Successful' : 'Import Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    importResult.success ? Colors.green[800] : Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(importResult.message),
            const SizedBox(height: 16),
            Text(
              'Total Decks: ${importResult.totalDecks}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Successfully Imported: ${importResult.successfulDecks}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Failed: ${importResult.totalDecks - importResult.successfulDecks}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessfulCollectionsSection(BuildContext context) {
    if (importResult.collectionIds == null ||
        importResult.collectionIds!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Successful Collections',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: importResult.collectionIds!.length,
              itemBuilder: (context, index) {
                final collectionId = importResult.collectionIds![index];
                return ListTile(
                  title: Text('Collection ID: $collectionId'),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/collection_details',
                        arguments: {'collectionId': collectionId},
                      );
                    },
                    child: const Text('View Collection'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedCollectionsSection() {
    // This would use the failedCollections map from the enhanced DeckImportResult
    // Since we don't have that yet, we'll return an empty widget
    return const SizedBox.shrink();
  }

  Widget _buildFailedDecksSection() {
    if (importResult.errors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Errors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: importResult.errors.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '• ${importResult.errors[index]}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
