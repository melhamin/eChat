import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../consts.dart';

class Utils {

  static Future<bool> showImageSourceModal(BuildContext context) async {
    return await showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoButton(
            child:
                Text('Choose Photo', style: TextStyle(color: kBaseWhiteColor)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          CupertinoButton(
            child: Text('Take Photo', style: TextStyle(color: kBaseWhiteColor)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
        cancelButton: CupertinoButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).errorColor),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  static Future<PickedFile> pickImage(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();
    return await imagePicker.getImage(
        source: source, maxHeight: 500, maxWidth: 500, imageQuality: 85);
  }
}
