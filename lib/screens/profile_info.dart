import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/providers/auth.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/screens/edit_profile_picture.dart';

enum EditedField {
  Username,
  About,
}

class ProfileInfo extends StatefulWidget {
  @override
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo>
    with AutomaticKeepAliveClientMixin {
  TextEditingController _nameController;
  TextEditingController _statusController;
  ScrollController _textFieldScrollController;

  bool _initLoaded = false;
  bool _isLoading = true;
  FirebaseUser user;
  Person details;

  @override
  void initState() {
    super.initState();
    _textFieldScrollController = ScrollController();
    Future.delayed(Duration.zero).then((value) {
      FirebaseAuth.instance.currentUser().then((value) {
        setState(() {
          user = value;
          _nameController =
              TextEditingController(text: user.displayName ?? 'No name.');
        });
        Firestore.instance
            .collection('users')
            .document(user.uid)
            .get()
            .then((value) {
          setState(() {
            details = Person.fromSnapshot(value);
            _statusController =
                TextEditingController(text: details.about ?? 'No name.');
            _isLoading = false;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _textFieldScrollController.dispose();
    _statusController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void navToEditImage(BuildContext context, FirebaseUser user, String imageUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditProfilePicture(user, imageUrl),
    ));
  }

  void goToStart() {
    _textFieldScrollController.animateTo(
        _textFieldScrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn);
  }

  void updateUsername(String newValue) {
    goToStart();
    if (newValue != user.displayName) {
      _nameController.text = '$newValue';
      final info = UserUpdateInfo();
      info.displayName = newValue;
      user.updateProfile(info);

      Firestore.instance
          .collection('users')
          .document(user.uid)
          .get()
          .then((value) async {
        await Firestore.instance.runTransaction((transaction) async {
          await transaction.update(value.reference, {
            'username': newValue,
          });
        });
      });
    }
  }

  void updateAbout(String newValue) {
    goToStart();
    if (details.about != newValue) {
      _statusController.text = '$newValue';
      Firestore.instance
          .collection('users')
          .document(user.uid)
          .get()
          .then((value) async {
        await Firestore.instance.runTransaction((transaction) async {
          await transaction.update(value.reference, {
            'about': newValue,
            'aboutChangeDate': DateTime.now().toIso8601String(),
          });
        });
      });
    }
  }

  Widget _buildProfilePic() {
    return StatefulBuilder(
      builder: (ctx, thisState) {
        var imageUrl = Provider.of<User>(context).imageUrl;
        return Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: imageUrl == null
                ? Icon(
                    Icons.person,
                    size: 80,
                    color: kBaseWhiteColor,
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildImageAndName(BuildContext context, FirebaseUser user) {
    var imageUrl = Provider.of<User>(context).imageUrl;
      return Container(
        decoration: BoxDecoration(
          color: Hexcolor('#202020'),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(25),
          ),
          // border: Border.all(
          //   color: kBorderColor2,
          // ),
        ),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: imageUrl == null
                ? Icon(
                    Icons.person,
                    size: 80,
                    color: kBaseWhiteColor,
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
                SizedBox(height: 5),
                CupertinoButton(
                  onPressed: () => navToEditImage(context, user, imageUrl),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                        fontSize: 17, color: Theme.of(context).accentColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Container(
              alignment: Alignment.centerLeft,
              height: 50,
              child: CupertinoTextField(
                scrollController: _textFieldScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                cursorColor: Theme.of(context).accentColor,
                keyboardAppearance: Brightness.dark,
                style: TextStyle(
                  fontSize: 17,
                  color: kBaseWhiteColor,
                ),
                decoration: BoxDecoration(
                  color: Hexcolor('#202020'),
                ),
                controller: _nameController,
                onSubmitted: (value) => updateUsername(value),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      );

  Widget _buildEmail(FirebaseUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('EMAIL ADDRESS'),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Hexcolor('#202020'),
            border: Border(
              bottom: BorderSide(color: kBorderColor2),
              top: BorderSide(color: kBorderColor2),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 15, top: 15, bottom: 15),
            child: Text(
              user.email,
              style: TextStyle(
                fontSize: 17,
                color: kBaseWhiteColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAbout(FirebaseUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ABOUT'),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Hexcolor('#202020'),
            border: Border(
              bottom: BorderSide(color: kBorderColor2),
              top: BorderSide(color: kBorderColor2),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            child: CupertinoTextField(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              cursorColor: Theme.of(context).accentColor,
              keyboardAppearance: Brightness.dark,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: kBaseWhiteColor,
              ),
              decoration: BoxDecoration(
                color: Hexcolor('#202020'),
              ),
              controller: _statusController,
              onSubmitted: (value) => updateAbout(value),
            ),
            // Text(
            //   details.about,
            //   style: TextStyle(
            //     fontSize: 17,
            //     color: kBaseWhiteColor,
            //   ),
            // ),
          ),
        ),
      ],
    );
  }

  void showConfirmDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text('Logout?'),
        ),
        content: Text('Are you sure?'),
        actions: [
          CupertinoButton(
            child: Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<Auth>(context, listen: false).signOut();
            },
            // color: Theme.of(context).accentColor,
            padding: const EdgeInsets.all(0),
          ),
          CupertinoButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            padding: const EdgeInsets.all(0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = Provider.of<User>(context).getUser;
    final mq = MediaQuery.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Column(
        children: [
          Container(
            height: mq.size.height * 0.12,
            padding: const EdgeInsets.only(left: 15, top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  // padding: const EdgeInsets.only(right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      CupertinoButton(
                        onPressed: () {
                          showConfirmDialog(context);
                        },
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                              fontSize: 17,
                              color: Theme.of(context).errorColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(25),
                    ),
                    child: ListView(
                      children: [
                        _buildImageAndName(context, user),
                        SizedBox(height: 30),
                        _buildEmail(user),
                        SizedBox(height: 30),
                        _buildAbout(user),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
