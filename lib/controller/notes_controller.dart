import 'dart:developer';

import 'package:cloud_note/controller/localization_controller.dart';
import 'package:cloud_note/screen/notes_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:translator/translator.dart';

import '../model/notes.dart';
import '../screen/home_screen.dart';
import '../services/notes_services.dart';
import '../utils/app_snackbar.dart';

class NotesController extends GetxController {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  RxBool isCreatesNotesLoading = false.obs;
  RxBool isFetchAllNotesLoading = false.obs;
  RxBool isUpdateNotesLoading = false.obs;
  RxBool isSearching = false.obs;

  // To hold the selected image path
  RxString selectedImagePath = ''.obs;

  // To hold the selected date
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  final ImagePicker _imagePicker = ImagePicker();
  final translator = GoogleTranslator(); //  Initialize Translator

  RxList<Notes> notesList = <Notes>[].obs; // Reactive list to store notes
  Rx<Notes?> currentNote =
      Rx<Notes?>(null); // Reactive variable for the current note

  String get locale =>
      Get.find<LocalizationController>().locale.value.languageCode;

  @override
  void onInit() {
    super.onInit();
    log(" Initialized Language (From Storage): $locale"); //  Safe initialization
  }

  /// Create Note
  createNote({
    required Notes notes,
  }) {
    // Check if image or description is empty
    if ((notes.imagePath == null || notes.imagePath!.isEmpty) &&
        (notes.description == null || notes.description!.isEmpty)) {
      AppSnackBar.showSnackBar(
        false,
        'Please add an image or provide a description.',
      );
      return; // Exit without proceeding
    }

    isCreatesNotesLoading.value = true;
    try {
      NotesService.createNotes(notes).then((_) {
        AppSnackBar.showSnackBar(
          true,
          'Note created successfully!',
        );
        fetchAllNotes(); // Refresh list after creation
        resetNotesData();
        Get.off(const HomeScreen());
      }).catchError((e) {
        AppSnackBar.showSnackBar(
          false,
          'Failed to create note. Please try again.',
        );
        log('Error creating note: $e');
      }).whenComplete(() => isCreatesNotesLoading.value = false);
    } catch (e) {
      log('Unexpected error: $e');
      isCreatesNotesLoading.value = false;
    }
  }

  /// Choose Media Source
  chooseMediaSource() async {
    await Get.defaultDialog(
      title: 'Choose Media Source',
      content: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              _capturePhotoFromCamera();
            },
            child: const Text('Camera'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              _pickImageFromGallery();
            },
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
  }

  /// Capture Photo from Camera
  _capturePhotoFromCamera() async {
    try {
      final XFile? photo =
          await _imagePicker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        selectedImagePath.value = photo.path;
        log('Image captured: ${photo.path}');
      }
    } catch (e) {
      log('Error capturing photo: $e');
    }
  }

  /// Pick Image from Gallery
  _pickImageFromGallery() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImagePath.value = image.path;
        log('Image picked: ${image.path}');
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  /// Open Date Picker
  pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      selectedDate.value = pickedDate;
      log('Selected date: $pickedDate');
    }
  }

  /// Fetch All Notes
  Future<void> fetchAllNotes() async {
    try {
      isFetchAllNotesLoading.value = true;
      final notes = await NotesService.readAllNotes();
      // Debugging: Check saved language
      log('fetchAllNotes savedLanguage ${locale}');

      // Translate all notes before displaying
      final translatedNotes = await Future.wait(notes.map((note) async {
        return await _translateNote(note);
      }));

      // Debugging: Log translated notes
      for (var note in translatedNotes) {
        log('Translated Title: ${note.title}');
        log('Translated Description: ${note.description}');
      }

      notesList.assignAll(
          translatedNotes); // Populate reactive list with translated notes

      isFetchAllNotesLoading.value = false;
    } catch (e) {
      AppSnackBar.showSnackBar(
        false,
        'Failed to fetch notes. Please try again later.',
      );
      isFetchAllNotesLoading.value = false;
    }
  }

  // Translate each note
  Future<Notes> _translateNote(Notes note) async {
    log(" Translating Note: ${note.title} | Language: ${locale}");

    if (locale == 'en') {
      log(" No Translation Needed (Already English)");
      return note;
    }

    try {
      final translatedTitle =
          await translator.translate(note.title ?? "", to: locale);
      final translatedDesc =
          await translator.translate(note.description ?? "", to: locale);

      log(" Translated Title: ${translatedTitle.text}");
      log(" Translated Desc: ${translatedDesc.text}");

      return Notes()
        ..id = note.id
        ..title = translatedTitle.text
        ..description = translatedDesc.text
        ..date = note.date
        ..imagePath = note.imagePath;
    } catch (e) {
      log("Translation Error: $e");
      return note; // Return original note if translation fails
    }
  }


  /// Fetch updated Note
  Future<void> fetchUpdatedNoteById(int id) async {
    try {
      // Fetch the updated note from the database
      final updatedNote = await NotesService.readNote(id);

      // Assign it to the currentNote reactive variable
      currentNote.value = updatedNote;

      log('Updated note fetched successfully: $updatedNote');
    } catch (e) {
      AppSnackBar.showSnackBar(
        false,
        'Failed to fetch updated note. Please try again later.',
      );
      log('Error fetching updated note: $e');
    }
  }

  /// Update Note
  updateNote({
    required int id,
    String? title,
    String? description,
    DateTime? date,
    String? imagePath,
  }) {
    isUpdateNotesLoading.value = true;

    NotesService.updateNotes(
      id,
      title: title,
      description: description,
      date: date,
      imagePath: imagePath,
    ).then((_) {
      AppSnackBar.showSnackBar(
        true,
        'Note updated successfully!',
      );
      fetchUpdatedNoteById(id);
      fetchAllNotes();
      resetNotesData();
      Get.off(NoteDetailScreen(noteId: id));
    }).catchError((e) {
      AppSnackBar.showSnackBar(
        false,
        'Failed to update note. Please try again.',
      );
      log('Error updating note: $e');
    }).whenComplete(() => isUpdateNotesLoading.value = false);
  }

  /// Delete Note
  Future<void> deleteNote(int id) async {
    bool? confirmed = await Get.defaultDialog<bool>(
      title: 'Are you sure you want to delete this note?',
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );

    if (confirmed ?? false) {
      NotesService.deleteNote(id).then((_) {
        AppSnackBar.showSnackBar(
          true,
          'Note deleted successfully!',
        );
        fetchAllNotes(); // Refresh list after deletion
      }).catchError((e) {
        AppSnackBar.showSnackBar(
          false,
          'Failed to delete note. Please try again.',
        );
        log('Error deleting note: $e');
      });
    }
  }

  /// Function to handle search
  void searchNotes(String query) async {
    if (query.isEmpty) {
      fetchAllNotes(); // Reset to full list if search query is empty
      return;
    } else {
      final translatedQuery = await translator.translate(query,
          to: 'en'); // Translate search text to English

      final filteredNotes = notesList.where((note) {
        final title = note.title?.toLowerCase() ?? '';
        final description = note.description?.toLowerCase() ?? '';
        return title.contains(translatedQuery.text.toLowerCase()) ||
            description.contains(translatedQuery.text.toLowerCase());
      }).toList();

      notesList.assignAll(filteredNotes);
    }
  }

  /// Function to handle sorting
  void sortNotes(String criteria) {
    final sortedNotes = [...notesList];

    if (criteria == 'date') {
      sortedNotes.sort((a, b) => b.date!.compareTo(a.date!)); // Newest first
    } else if (criteria == 'name') {
      sortedNotes.sort((a, b) =>
          (a.title ?? '').compareTo(b.title ?? '')); // Alphabetical order
    }

    notesList.assignAll(sortedNotes);
  }

  shareNotes(Notes note) async {
    // Prepare the content to share
    String shareContent = '''
    Title: ${note.title ?? "Untitled Note"}
    Description: ${note.description ?? "No description available."}
    Date: ${note.date?.toLocal().toString().split(' ')[0] ?? "Not set"}
    ''';
    try {
      // If the note has an image, include it
      if (note.imagePath != null && note.imagePath!.isNotEmpty) {
        // Share with image
        await Share.shareXFiles(
          [XFile('${note.imagePath}')],
          text: shareContent,
        );
      } else {
        // Share without image
        await Share.share(shareContent);
      }
    } catch (e, st) {
      AppSnackBar.showSnackBar(
        false,
        'Failed to share note. Please try again.',
      );
      log('Error creating note: $e-----$st');
    }
  }

  /// Clear Data
  resetNotesData() {
    titleController.clear();
    descriptionController.clear();
    selectedImagePath.value = '';
    selectedDate.value = null;
  }

  @override
  void onClose() {
    super.onClose();
    searchController.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }
}
