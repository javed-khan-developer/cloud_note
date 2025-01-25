import 'dart:developer';

import 'package:cloud_note/screen/notes_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../database/db.dart';
import '../model/notes.dart';
import '../screen/home_screen.dart';
import '../utils/app_snackbar.dart';

class NotesController extends GetxController {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  RxBool isCreatesNotesLoading = false.obs;
  RxBool isFetchAllNotesLoading = false.obs;
  RxBool isUpdateNotesLoading = false.obs;

  // To hold the selected image path
  RxString selectedImagePath = ''.obs;

  // To hold the selected date
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  final ImagePicker _imagePicker = ImagePicker();

  RxList<Notes> notesList = <Notes>[].obs; // Reactive list to store notes
  Rx<Notes?> currentNote =
      Rx<Notes?>(null); // Reactive variable for the current note

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
      DatabaseService.createNotes(notes).then((_) {
        AppSnackBar.showSnackBar(
          true,
          'Note created successfully!',
        );
        fetchAllNotes(); // Refresh list after creation
        clearData();
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
      final notes = await DatabaseService.readAllNotes();
      notesList.assignAll(notes); // Populate reactive list with fetched notes
      isFetchAllNotesLoading.value = false;
    } catch (e) {
      AppSnackBar.showSnackBar(
        false,
        'Failed to fetch notes. Please try again later.',
      );
      isFetchAllNotesLoading.value = false;
    }
  }

  /// Fetch updated Note
  Future<void> fetchUpdatedNoteById(int id) async {
    try {
      // Fetch the updated note from the database
      final updatedNote = await DatabaseService.readNote(id);

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

    DatabaseService.updateNotes(
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
      clearData();
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
      DatabaseService.deleteNote(id).then((_) {
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

  /// Clear Data
  clearData() {
    titleController.clear();
    descriptionController.clear();
    selectedImagePath.value = '';
    selectedDate.value = null;
  }
}
