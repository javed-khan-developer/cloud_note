import 'package:flutter/material.dart';
import '../controller/notes_controller.dart';
import 'notes_edit_screen.dart';
import 'package:get/get.dart';
import 'dart:io';

class NoteDetailScreen extends StatelessWidget {
  final int noteId;
  final NotesController notesController = Get.find();

  NoteDetailScreen({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    // Fetch the note details when the screen loads
    notesController.fetchUpdatedNoteById(noteId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.to(NoteEditorScreen(
                isNavigatedFromEditScreen: true,
                noteId:noteId,
              )); // Navigate to editor screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Add share functionality here
            },
          ),
        ],
      ),
      body: Obx(() {
        final note = notesController.currentNote.value;
        if (note == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Note Title
                Text(
                  note.title ?? 'Untitled Note',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // Note Date
                if (note.date != null)
                  Text(
                    'Date: ${note.date!.toLocal().toString().split(' ')[0]}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                const SizedBox(height: 16),

                // Note Description
                Text(
                  note.description ?? 'No description available.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),

                // Note Image or Placeholder
                if (note.imagePath != null && note.imagePath!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(note.imagePath!),
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
