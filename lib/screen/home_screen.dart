import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:isar/isar.dart';

import '../database/db.dart';
import '../model/notes.dart';
import 'notes_detail_screen.dart';
import 'notes_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort',
                child: Text('Sort Notes'),
              ),
              const PopupMenuItem(
                value: 'filter',
                child: Text('Filter Notes'),
              ),
            ],
          )
        ],
      ),
      body: const NotesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(NoteEditorScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NotesList extends StatefulWidget {
  const NotesList({super.key});

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  late List<Notes> notes;

  @override
  void initState() {
    super.initState();
    readUsers();
  }

  readUsers() async {
    notes = await readAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length, // Replace with actual count from database
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(notes[index].title ?? ''),
            subtitle: Text(notes[index].description ?? ''),
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.note, color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {},
                ),
              ],
            ),
            onTap: () {
              Get.to(NoteDetailScreen(noteId: index));
            },
          ),
        );
      },
    );
  }
}
