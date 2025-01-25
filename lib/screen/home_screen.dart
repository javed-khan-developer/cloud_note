import 'dart:io';

import 'package:cloud_note/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/notes_controller.dart';
import '../widgets/home_app_bar.dart';
import 'notes_detail_screen.dart';
import 'notes_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NotesAppBar(),
      body: NotesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(NoteEditorScreen(
            isNavigatedFromEditScreen: false,
            noteId: -1,
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NotesList extends StatelessWidget {
  NotesList({super.key});

  final NotesController notesController = Get.put(NotesController());

  @override
  Widget build(BuildContext context) {
    // Fetch notes when the screen loads
    notesController.fetchAllNotes();

    return Obx(
      () => notesController.isFetchAllNotesLoading.value
          ? const AppLoader()
          : notesController.notesList.isEmpty
              ? const Center(
                  child: Text(
                    'No notes available.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  itemCount: notesController.notesList.length,
                  itemBuilder: (context, index) {
                    final note = notesController.notesList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: note.imagePath != null &&
                                  note.imagePath!.isNotEmpty
                              ? Image.file(
                                  File(note.imagePath!),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                        ),
                        title: Text(
                          note.title?.isNotEmpty == true
                              ? note.title!
                              : 'Untitled Note',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              note.description?.isNotEmpty == true
                                  ? note.description!
                                  : 'No description available.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Date: ${note.date?.toLocal().toString().split(' ')[0] ?? 'Not set'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.blue),
                              onPressed: () {
                                // Share logic here
                                notesController.shareNotes(note);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                notesController.deleteNote(note.id);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Get.to(() => NoteDetailScreen(noteId: note.id));
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
