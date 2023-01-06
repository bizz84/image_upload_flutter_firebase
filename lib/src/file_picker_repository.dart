import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilePickerRepository {
  FilePickerRepository(this._filePicker);
  final FilePicker _filePicker;

  Future<PlatformFile?> pickSingleImage() async {
    final result = await _filePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      onFileLoading: (status) => debugPrint(status.toString()),
    );
    // user cancelled picker
    if (result == null) {
      return null;
    }
    // https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ
    return result.files.single;
  }
}

final filePickerRepositoryProvider = Provider<FilePickerRepository>((ref) {
  return FilePickerRepository(FilePicker.platform);
});
