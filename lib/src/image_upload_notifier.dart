import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_upload_flutter_firebase/src/file_picker_repository.dart';
import 'package:image_upload_flutter_firebase/src/image_upload_repository.dart';

class ImageUploadNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // no-op
  }

  Future<void> pickImageAndUpload() async {
    try {
      final filePicker = ref.read(filePickerRepositoryProvider);
      final imageFile = await filePicker.pickSingleImage();
      if (imageFile == null) {
        return;
      }
      state = const AsyncLoading();
      final uploader = ref.read(imageUploadRepositoryProvider);
      await uploader.uploadFile(imageFile);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final imageUploadNotifierProvider =
    AsyncNotifierProvider<ImageUploadNotifier, void>(ImageUploadNotifier.new);
