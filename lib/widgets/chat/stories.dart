

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/utils/utils.dart';
import 'package:whatsapp_clone/widgets/chat/story_item.dart';

class Stories extends StatefulWidget {
  @override
  _StoriesState createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {

  File _image;
  bool _mediaSelected = false;
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

  Future getImage() async {
    showImageSourceModal().then((value) async {
      if (value != null) {
        _image = null;
        var pickedFile = await Utils.pickImage(
            value ? ImageSource.gallery : ImageSource.camera);
        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
            _mediaSelected = true;
          });          
        }
      }
    });
  }

  Widget _buildMyStoryItem(FirebaseUser user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CupertinoButton(
          padding: const EdgeInsets.all(0),
              onPressed: () => getImage(),
                  child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                      color: Theme.of(context).accentColor, width: 1.5),
                ),
                child: CircleAvatar(
                  backgroundColor: Hexcolor('#303030'),
                  backgroundImage:
                      (user.photoUrl != null && user.photoUrl != '')
                          ? CachedNetworkImageProvider(user.photoUrl)
                          : null,
                  child: (user.photoUrl == null || user.photoUrl == '')
                      ? Icon(
                          Icons.person,
                          color: kBaseWhiteColor,
                        )
                      : null,
                  radius: 27,
                ),
              ),
              Positioned(
                bottom: 4,
                right: 3,
                child: Container(
                  decoration: BoxDecoration(
                  color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Text(
            // user.displayName.split(' ')[0],
            'You Story',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: kBaseWhiteColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final chats = Provider.of<User>(context).chats;
    final user = Provider.of<User>(context).getUser;
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 15),
      scrollDirection: Axis.horizontal,
      itemCount: chats.length + 1,
      itemBuilder: (ctx, i) =>
          i == 0 ? _buildMyStoryItem(user) : StoryItem(chats[i - 1]),
      separatorBuilder: (_, __) => SizedBox(width: 30),
    );
  }
}
