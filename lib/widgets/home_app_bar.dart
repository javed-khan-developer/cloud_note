import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/notes_controller.dart';

class NotesAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  const NotesAppBar({super.key}) : preferredSize = const Size.fromHeight(60.0);

  @override
  NotesAppBarState createState() => NotesAppBarState();
}

class NotesAppBarState extends State<NotesAppBar> {
  final NotesController notesController = Get.find<NotesController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppBar(
        automaticallyImplyLeading: false,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: notesController.isSearching.value
              ? TextField(
                  controller: notesController.searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search notes...',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) =>
                      notesController.searchNotes(value), // Search logic
                )
              : const Text(
                  'My Notes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
        ),
        actions: [
          if (!notesController.isSearching.value)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                notesController.isSearching.value = true;
              },
            ),
          if (notesController.isSearching.value)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                notesController.isSearching.value = false;
                notesController.searchController.clear();
                notesController
                    .fetchAllNotes(); // Reset the list when search is cleared
              },
            ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'sort_date') {
                notesController.sortNotes('date');
              } else if (value == 'sort_name') {
                notesController.sortNotes('name');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort_date',
                child: Text('Sort By Date'),
              ),
              const PopupMenuItem(
                value: 'sort_name',
                child: Text('Sort By Name'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
