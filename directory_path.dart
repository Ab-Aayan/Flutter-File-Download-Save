import 'dart:io';

class DirectoryPath {
  getPath() async {
    final path = Directory(
        "/storage/emulated/0/Android/media/com.example.ctevt_solution/files");
    if (await path.exists()) {
    } else {
      path.create();
      return path.path;
    }
  }
}
