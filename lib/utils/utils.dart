import 'package:image_picker/image_picker.dart';

class Utils {
  static Future<PickedFile> pickImage(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();
    return await imagePicker.getImage(
        source: source, maxHeight: 500, maxWidth: 500, imageQuality: 85);
  }
}
