import 'dart:io';

import 'package:cloud_note/controller/notes_controller.dart';
import 'package:cloud_note/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/notes.dart';

class NoteEditorScreen extends StatelessWidget {
  final NotesController notesController = Get.put(NotesController());
  final bool isNavigatedFromEditScreen;
  final int noteId;

  NoteEditorScreen({
    super.key,
    required this.isNavigatedFromEditScreen,
    required this.noteId,
  }) {
    // Pre-fill data if editing
    if (isNavigatedFromEditScreen) {
      final note = notesController.currentNote.value;
      notesController.titleController.text = note!.title ?? '';
      notesController.descriptionController.text = note.description ?? '';
      notesController.selectedDate.value = note.date ?? DateTime.now();
      notesController.selectedImagePath.value = note.imagePath ?? '';
    } else {
      notesController.clearData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNavigatedFromEditScreen ? 'Edit Note' : 'Create Note'),
        actions: [
          Obx(
            () => notesController.isCreatesNotesLoading.value
                ? const AppLoader()
                : IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () async {
                      // Save or Update Note Logic
                      final newNote = Notes()
                        ..title = notesController.titleController.text
                        ..description =
                            notesController.descriptionController.text
                        ..date = notesController.selectedDate.value
                        ..imagePath = notesController.selectedImagePath.value;

                      if (!isNavigatedFromEditScreen) {
                        // Create new note
                        await notesController.createNote(notes: newNote);
                      } else {
                        // Update existing note
                        await notesController.updateNote(
                          id: noteId,
                          title: notesController.titleController.text,
                          description:
                              notesController.descriptionController.text,
                          date: notesController.selectedDate.value ??
                              DateTime.now(),
                          imagePath: notesController.selectedImagePath.value,
                        );
                      }
                    },
                    tooltip: 'Save Note',
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              const Text(
                'Title',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController.titleController,
                decoration: InputDecoration(
                  hintText: 'Enter note title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description Input
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController.descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Write your notes here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Add Image Button
              ElevatedButton.icon(
                onPressed: notesController.chooseMediaSource,
                icon: const Icon(Icons.image, size: 20),
                label: const Text('Add Image'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Add Date Picker
              Obx(() {
                final selectedDate = notesController.selectedDate.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        notesController.pickDate(context);
                      },
                      icon: const Icon(Icons.calendar_today, size: 20),
                      label: const Text('Pick Date'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    if (selectedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Selected Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                );
              }),

              const SizedBox(height: 16),

              // Display Selected Image Preview
              Obx(() {
                final imagePath = notesController.selectedImagePath.value;
                if (imagePath.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Image Preview',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(imagePath),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
