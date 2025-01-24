import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackBar {
  AppSnackBar._();

  static showSnackBar(bool status, String message) {
    Get.snackbar(
      status ? 'Success' : 'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: status ? Colors.green : Colors.red,
      colorText: Colors.white,
    );
  }
}
