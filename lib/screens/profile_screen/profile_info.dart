import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/providers/auth.dart';
import 'package:whatsapp_clone/models/person.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/screens/profile_screen/edit_profile_picture.dart';
import 'package:whatsapp_clone/services/db.dart';
import 'package:whatsapp_clone/widgets/tab_title.dart';

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
  DB db;
  TextEditingController _nameController;
  TextEditingController _statusController;
  ScrollController _textFieldScrollController;

  // bool _initLoaded = false;
  // bool _isLoading = true;
  FirebaseUser user;
  Person details;

  @override
  void initState() {
    super.initState();
    db = DB();
    _textFieldScrollController = ScrollController();
    Future.delayed(Duration.zero).then((value) {
      FirebaseAuth.instance.currentUser().then((value) {
        setState(() {
          user = value;
        });
        db.getUserDocRef(user.uid).then((value) {
          setState(() {
            details = Person.fromSnapshot(value);
            _statusController = TextEditingController(
                text: details.about ?? 'Hi there! I am using eChat.');
            _nameController =
                TextEditingController(text: details.name ?? 'Not Availabe.');
            // _isLoading = false;
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

  void navToEditImage(
      BuildContext context, FirebaseUser user, String imageUrl) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          EditProfilePicture(user, imageUrl),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return imageUrl == null || imageUrl == ''
            ? CupertinoPageTransition(
                child: child,
                primaryRouteAnimation: animation,
                secondaryRouteAnimation: secondaryAnimation,
                linearTransition: false,
              )
            : FadeTransition(opacity: animation, child: child);
      },
    ));
    // Navigator.of(context).push(MaterialPageRoute(
    //   builder: (context) => EditProfilePicture(user, imageUrl),
    // ));
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

      db.updateUserInfo(user.uid, {'username': newValue});
    }
  }

  void updateAbout(String newValue) {
    goToStart();
    if (details.about != newValue) {
      _statusController.text = '$newValue';
      db.updateUserInfo(user.uid, {
        'about': newValue,
        'aboutChangeDate': DateTime.now().toIso8601String(),
      });
    }
  }

  Widget _buildImageAndName(BuildContext context, FirebaseUser user) {
    var imageUrl = Provider.of<User>(context).imageUrl;
    return 
    Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Hero(
              tag: (details != null && details.imageUrl != null)
                  ? details.imageUrl
                  : 'EMPTY',
              child: GestureDetector(
                onTap: () => navToEditImage(context, user, imageUrl),
                child: imageUrl == null
                    ? Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: kBorderColor1),
                            borderRadius: BorderRadius.circular(80)),
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: kBaseWhiteColor,
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        loadingBuilder: (ctx, wid, loading) {
                          return loading == null
                              ? wid
                              : CupertinoActivityIndicator();
                        },
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('USERNAME'),
            SizedBox(height: 5),
            user == null
                ? CupertinoActivityIndicator()
                : Container(
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: kBorderColor1),
                        top: BorderSide(color: kBorderColor1),
                      ),
                    ),
                    // height: 50,
                    child: CupertinoTextField(
                      scrollController: _textFieldScrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
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
      ],
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
          ),
        ),
      ],
    );
  }

  void _handleLogout() {
    Provider.of<User>(context, listen: false).clearChatsAndContacts();
    Provider.of<Auth>(context, listen: false).signOut();
    Navigator.of(context).pop();
  }

  void showConfirmDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        // title: Padding(
        //   padding: const EdgeInsets.only(bottom: 20),
        //   child: Text('Logout?'),
        // ),
        content: Text(
          'Log out of ${details.name}?',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kBaseWhiteColor),
        ),
        actions: [
          CupertinoButton(
            child: Text('cancel', style: TextStyle(color: kBaseWhiteColor)),
            onPressed: () {
              Navigator.of(context).pop();
            },
            padding: const EdgeInsets.all(0),
          ),
          CupertinoButton(
            child: Text('Log Out',
                style: TextStyle(color: Theme.of(context).errorColor)),
            onPressed: _handleLogout,
            // color: Theme.of(context).accentColor,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TabScreenTitle(
                  title: 'Edit Profile',
                  actionWidget: CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      showConfirmDialog(context);
                    },
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                          fontSize: 17, color: Theme.of(context).errorColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(25),
                topLeft: Radius.circular(25),
              ),
              child: ListView(
                children: [
                  _buildImageAndName(context, user),
                  SizedBox(height: 30),
                  user == null
                      ? CupertinoActivityIndicator()
                      : _buildEmail(user),
                  SizedBox(height: 30),
                  user == null
                      ? CupertinoActivityIndicator()
                      : _buildAbout(user),
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
