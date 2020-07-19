import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class Storage {
  final _storageBucket =
      FirebaseStorage(storageBucket: 'gs://flutter-whatsapp-1ab58.appspot.com');

  Future<String> getUrl(String path, String id) async {
    try {
      String url = '';
      await FirebaseStorage.instance
          .ref()
          .child('$path/$id.png')
          .getDownloadURL()
          .then((value) => url = value);
      return url;
    } catch (error) {
      print('****************** Storage getUrl error **********************');
      print(error);
      throw error;
    }
  }

  StorageUploadTask getUploadTask(File file, String path) {
    try {
      return _storageBucket.ref().child(path).putFile(file);
    } catch (error) {
      print(
          '****************** Storage getUploadTask error **********************');
      print(error);
      throw error;
    }
  }

  void uploadImage(String path, File file, String id) {
    try {
      _storageBucket.ref().child('$path/$id.png');
    } catch (error) {
      print(
          '****************** Storage uploadImage error **********************');
      print(error);
      throw error;
    }
  }
}
