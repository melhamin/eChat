import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/database/db.dart';
import 'package:whatsapp_clone/database/storage.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/screens/profile_screen/widgets/photo_uploader.dart';
import 'package:whatsapp_clone/utils/utils.dart';
import 'package:whatsapp_clone/widgets/back_button.dart';

class EditProfilePicture extends StatefulWidget {
  final FirebaseUser info;
  final String imageUrl;
  EditProfilePicture(this.info, this.imageUrl);
  @override
  _EditProfilePictureState createState() => _EditProfilePictureState();
}

class _EditProfilePictureState extends State<EditProfilePicture> {
  DB db;
  void initState() {
    super.initState();
    db = DB();
  }

  Widget _getImage(MediaQueryData mq) {
    if (widget.imageUrl == null || widget.imageUrl == '') {
      return Icon(Icons.person,
          size: mq.size.height * 0.2, color: kBaseWhiteColor);
    }
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: BoxFit.cover,
    );
  }

  Widget _buildSelectedImage(MediaQueryData mq) {
    return Container(
        width: mq.size.width,
        child: PhotoUploader(
            file: _image, uid: widget.info.uid, getUrl: updateProfilePicture));
  }

  Widget _buildProfileImage(MediaQueryData mq) {
    return widget.imageUrl == null ? Container(
        height: mq.size.height * 0.7 - kToolbarHeight,
        width: mq.size.width,
        child: _getImage(mq),
      ):
     Hero(
      tag: widget.imageUrl,
      child: Container(
        height: mq.size.height * 0.7 - kToolbarHeight,
        width: mq.size.width,
        child: _getImage(mq),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);    
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Profile Picture',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kBaseWhiteColor),
          ),
          leading: CBackButton(),
          actions: [
            CupertinoButton(
              onPressed: () => imageSelected
                  ? setState(() => imageSelected = false)
                  : pickImage(),
              // updateProfilePicture(),
              child: Text(
                imageSelected ? 'Cancel' : 'Update',
                style: TextStyle(
                  color: imageSelected
                      ? Theme.of(context).errorColor
                      : Theme.of(context).accentColor,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 50),
            imageSelected ? _buildSelectedImage(mq) : _buildProfileImage(mq),
            SizedBox(height: 10),
            if (widget.imageUrl != null && !imageSelected)
              CupertinoButton(
                onPressed: () {},
                child: Center(
                    child: Text(
                  'Delete Photo',
                  style: TextStyle(
                      fontSize: 22, color: Theme.of(context).errorColor),
                )),
              ),
            if (imageSelected)
              CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () => pickImage(),
                child: Center(
                    child: Text(
                  'Choose another picture.',
                  style: TextStyle(
                      fontSize: 22, color: Theme.of(context).accentColor),
                )),
              ),
          ],
        ),
      ),
    );
  }

  File _image;
  bool imageSelected = false;
  final picker = ImagePicker();

  Future<bool> showImageSourceModal() async {
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

  void pickImage() async {
    showImageSourceModal().then((value) async {
      if (value != null) {
        _image = null;
        var pickedFile = await Utils.pickImage(
            value ? ImageSource.gallery : ImageSource.camera);
        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
            imageSelected = true;
          });
          // Navigator.of(context).pop();
        }
      }
    });
  }

  void updateProfilePicture(String url) {
    final user = Provider.of<User>(context, listen: false).getUser;
    final info = UserUpdateInfo();
    info.photoUrl = url;
    user.updateProfile(info);

    db.updateUserInfo(widget.info.uid, {
      'imageUrl': url,
    });

    Provider.of<User>(context, listen: false).setImageUrl(url);
    Navigator.of(context).pop();
  }
}

