import 'dart:developer';
import 'package:cloud_note/model/notes.dart';
import 'package:cloud_note/screen/home_screen.dart';
import 'package:cloud_note/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../database/db.dart';

class NotesController extends GetxController {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  RxBool isCreatesNotesLoading = false.obs;
  RxBool isFetchAllNotesLoading = false.obs;

  // To hold the selected image path
  RxString selectedImagePath = ''.obs;

  // To hold the selected date
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  final ImagePicker _imagePicker = ImagePicker();

  RxList<Notes> notesList = <Notes>[].obs; // Reactive list to store notes

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
      final response = createNotes(notes);
      AppSnackBar.showSnackBar(
        true,
        'Note created successfully!',
      );
      isCreatesNotesLoading.value = false;
      fetchAllNotes(); // Refresh list after creation
      clearData();
      Get.off(const HomeScreen());
    } catch (e, st) {
      AppSnackBar.showSnackBar(
        false,
        'Failed to create note. Please try again.',
      );
      log('catch createNotes $e-----$st');
      isCreatesNotesLoading.value = false;
    }
  }

  // Allow user to choose the media source
  chooseMediaSource() async {
    await Get.defaultDialog(
      title: 'Choose Media Source',
      content: Column(
        mainAxisSize: MainAxisSize.min,
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

  // Capture photo from the camera
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

  // Pick image from the gallery
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

  // Open a date picker and update the selected date
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

  //Fetch all notes from the database
  Future<void> fetchAllNotes() async {
    try {
      isFetchAllNotesLoading.value = true;
      final notes = await readAllNotes();
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

  // Clear all data after creating the note
  clearData() {
    titleController.clear();
    descriptionController.clear();
    selectedImagePath.value = '';
    selectedDate.value = null;
  }
}
