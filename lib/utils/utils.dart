import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../consts.dart';

class Utils {
  static Future<bool> showImageSourceIOS(BuildContext context) async {
    return showCupertinoModalPopup(
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

  static Future<bool> showImageSourceAndroid(BuildContext context) async {
    final size = MediaQuery.of(context).size;
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
        backgroundColor: kBlackColor2,        
        title: Text('Choose Image'),
        content: Container(
          height: size.height * 0.22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(          
            children: [
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    Image.asset('assets/images/camera.png', width: 50, height: 50),
                    SizedBox(height: 10),
                    Text('Camera'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    Image.asset('assets/images/photos_android.png', width: 50, height: 50),
                    SizedBox(height: 10),
                    Text('Gallery'),
                  ],
                ),
              ),            
            ],
          ),
          SizedBox(height: 20),
          CupertinoButton(      
            padding: const EdgeInsets.all(0),      
                child: Container(
                  width: size.width * 0.4,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kBaseWhiteColor,
                    ),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),  
    );
  }

  static Future<bool> showPickerDialog(BuildContext context) async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final res = isIOS ? await showImageSourceIOS(context) : await showImageSourceAndroid(context);
    return res;
  }

  static Future<PickedFile> pickImage(BuildContext context) async {
    final res = await showPickerDialog(context);

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
    final res = await showPickerDialog(context);
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

