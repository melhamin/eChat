import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/providers/auth.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/screens/profile_info.dart';

class EditProfilePicture extends StatefulWidget {
  final FirebaseUser info;
  final String imageUrl;
  EditProfilePicture(this.info, this.imageUrl);
  @override
  _EditProfilePictureState createState() => _EditProfilePictureState();
}

class _EditProfilePictureState extends State<EditProfilePicture> {
  void initState() {
    super.initState();

    // print('username ======> ${widget.info.displayName}');
    // print('photoUrl ======> ${widget.info.photoUrl}');
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

  // void updateProfilePicture() {
  //   UserUpdateInfo info = UserUpdateInfo();
  //   info.photoUrl =
  //       'https://www.aconsciousrethink.com/wp-content/uploads/2019/05/reserved-person-702x336.jpg';
  //   info.displayName = 'Angela';
  //   widget.info.updateProfile(info);
  // }

  Widget _buildSelectedImage(MediaQueryData mq) {
    return Container(
        width: mq.size.width,
        child: PhotoUploader(
            file: _image, uid: widget.info.uid, getUrl: updateProfilePicture));
  }

  Widget _buildProfileImage(MediaQueryData mq) {
    return Container(
      height: mq.size.height * 0.7 - kToolbarHeight,
      width: mq.size.width,
      child: _getImage(mq),
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
          leading: BackButton(color: Theme.of(context).accentColor),
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

  void pickImage() async {
    _image = null;
    var pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
      imageSelected = true;
    });
    // Navigator.of(context).pop();
  }  

  void updateProfilePicture(String url) {
    final user = Provider.of<User>(context, listen: false).getUser;
    final info = UserUpdateInfo();
    info.photoUrl = url;
    user.updateProfile(info);    

    Firestore.instance
        .collection('users')
        .document(widget.info.uid)
        .get()
        .then((value) async {
      await Firestore.instance.runTransaction((transaction) async {
        await transaction.update(value.reference, {
          'imageUrl': url,
        });
      });
    });

    Provider.of<User>(context, listen: false).setImageUrl(url);
    Navigator.of(context).pop();        

  }
}

class PhotoUploader extends StatefulWidget {
  final File file;
  final String uid;
  final Function getUrl;
  PhotoUploader({
    @required this.file,
    @required this.uid,
    @required this.getUrl,
  });
  @override
  _PhotoUploaderState createState() => _PhotoUploaderState();
}

class _PhotoUploaderState extends State<PhotoUploader> {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://flutter-whatsapp-1ab58.appspot.com');
  StorageUploadTask _uploadTask;

  bool uploadCompleted = false;
  bool uploadStarted = false;

  void _startUpload() {
    var filePath = 'profilePictures/${widget.uid}.png';
    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);
      uploadStarted = true;
    });
  }

  void getImageUrl() async {
    var ref = FirebaseStorage.instance
        .ref()
        .child('profilePictures/${widget.uid}.png');
    ref.getDownloadURL().then((value) => widget.getUrl(value));    
  }

  void onUploadCompleted() {
    setState(() {
      uploadCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);    
    if (widget.file != null) {
      return Column(
        children: [
          Container(
            height: mq.size.height * 0.6 - kToolbarHeight,
            child: Image.file(widget.file, fit: BoxFit.cover),
          ),
          if (_uploadTask != null)
            StreamBuilder<StorageTaskEvent>(
              stream: _uploadTask.events,
              builder: (ctx, snapshots) {
                var event = snapshots?.data?.snapshot;
                double progress = event == null
                    ? 0
                    : event.bytesTransferred / event.totalByteCount;
                return Column(
                  children: [
                    // SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: progress,
                    ),
                    Text('Uploaded : ${(progress * 100).toStringAsFixed(2)} %'),                   
                  ],
                );
              },
            ),
          CupertinoButton(
            padding: const EdgeInsets.all(0),
            onPressed: uploadStarted ? getImageUrl : _startUpload,
            child: Center(
                child: Text(
              uploadStarted ? 'Save Changes' : 'Upload',
              style:
                  TextStyle(fontSize: 22, color: Theme.of(context).accentColor),
            )),
          ),        
        ],
      );
    }
    return Text('Select an image!!!');
  }
}
