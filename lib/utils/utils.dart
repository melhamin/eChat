import 'package:audioplayers/audio_cache.dart';
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
                Text('Open Gallery', style: TextStyle(color: kBaseWhiteColor)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          CupertinoButton(
            child: Text('Open Camera', style: TextStyle(color: kBaseWhiteColor)),
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

  static Future<PickedFile> pickImage(BuildContext context) async {
    final res = await showImageSourceModal(context);
    if (res == null) return null;
    ImageSource src = res ? ImageSource.gallery : ImageSource.camera;
    ImagePicker imagePicker = ImagePicker();
    return await imagePicker.getImage(
      source: src,
      maxHeight: 500,
      maxWidth: 500,
      imageQuality: 85,
    );
  }

  static Future<PickedFile> pickVideo(BuildContext context) async {
    final res = await showImageSourceModal(context);
    if (res == null) return null;
    ImageSource src = res ? ImageSource.gallery : ImageSource.camera;
    ImagePicker videoPicker = ImagePicker();
    return await videoPicker.getVideo(
      source: src,
      // maxDuration: Duration(minutes: 1),
    );
  }

  static final AudioCache player = AudioCache();
  static playSound(String path) => player.play(path);
}
