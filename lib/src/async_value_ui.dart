import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_upload_flutter_firebase/src/alert_dialogs.dart';

extension AsyncValueUI on AsyncValue {
  void showAlertDialogOnError(BuildContext context) {
    if (!isLoading && hasError) {
      showExceptionAlertDialog(
        context: context,
        title: 'Error',
        exception: _errorMessage(error),
      );
    }
  }

  String _errorMessage(Object? error) {
    if (error is PlatformException) {
      return error.message ?? error.toString();
    } else {
      return error.toString();
    }
  }
}
