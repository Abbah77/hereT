import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Format date
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return DateFormat.yMMMd().format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  // Show snackbar
  static void showSnackBar(
    BuildContext context, 
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  // Show loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }
  
  // Generate avatar color from string
  static Color getAvatarColor(String text) {
    final hash = text.hashCode.abs();
    final hue = hash % 360;
    return HSLColor.fromAHSL(1, hue.toDouble(), 0.7, 0.7).toColor();
  }
  
  // Truncate text
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  // Parse error message
  static String parseError(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString().replaceAll('Exception: ', '');
    if (error is Map) return error['message'] ?? 'Unknown error';
    return 'An unexpected error occurred';
  }
  
  // Debouncer for search
  static Debouncer createDebouncer({Duration duration = const Duration(milliseconds: 500)}) {
    return Debouncer(duration: duration);
  }
}

class Debouncer {
  final Duration duration;
  Timer? _timer;
  
  Debouncer({required this.duration});
  
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }
  
  void dispose() {
    _timer?.cancel();
  }
}