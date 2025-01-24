import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import 'notes_edit_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final int noteId;

  const NoteDetailScreen({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.to(NoteEditorScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share note logic
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Note Title $noteId',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateTime.now().toLocal()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'This is the detailed description of the note. It can span multiple lines.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Icon(Icons.image,size: 100,), // Placeholder for the note image
              ),
            ),
          ],
        ),
      ),
    );
  }
}
