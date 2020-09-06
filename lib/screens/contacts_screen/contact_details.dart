import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/user.dart';
import 'package:whatsapp_clone/screens/chats_screen/chat_media_screen.dart';
import 'package:whatsapp_clone/services/db.dart';
import 'package:whatsapp_clone/widgets/back_button.dart';
import 'package:whatsapp_clone/widgets/media_view.dart';

class ContactDetails extends StatelessWidget {
  final User contact;
  final String groupId;

  const ContactDetails({Key key, this.contact, this.groupId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 5),
          child: AppBar(
            centerTitle: true,
            backgroundColor: kBlackColor2,
            elevation: 0,
            leading: CBackButton(),
            title: Text(
              'Contact Info',
              style: TextStyle(
                  color: kBaseWhiteColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            actions: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(right: 5),
                child: CupertinoButton(
                  onPressed: () {
                    // storage.d();
                  },
                  child: Text(
                    'Edit',
                    style: TextStyle(
                        fontSize: 16, color: Theme.of(context).accentColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25),
              topLeft: Radius.circular(25),
            ),
            // color: kBlackColor2,
          ),
          width: size.width,
          child: ListView(
            children: [
              _Image(contact: contact),
              _ContactInfo(contact: contact),
              SizedBox(height: 20),
              _ChatInfo(groupId: groupId),
              SizedBox(height: 20),
              _Actions(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBlackColor,
        border: Border(
          top: BorderSide(color: kBlackColor2),
          bottom: BorderSide(color: kBlackColor2),
        ),
      ),
      child: Column(
        children: [
          _ActionsTile(title: 'Share Contact'),
          Divider(
              height: 0,
              color: kBorderColor1,
              indent: 20), // 20 (left padding + icon size)
          _ActionsTile(title: 'Export Chat'),
          Divider(
              height: 0,
              color: kBorderColor1,
              indent: 20), // 20 (left padding + icon size)
          _ActionsTile(title: 'Clear Chat'),
        ],
      ),
    );
  }
}

class _ActionsTile extends StatelessWidget {
  final String title;
  const _ActionsTile({
    Key key,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // splashColor: Colors.transparent,
        highlightColor: kBlackColor2,
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          width: size.width,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              color: kBaseWhiteColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  final User contact;
  const _ContactInfo({
    Key key,
    this.contact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBlackColor,
        border: Border(
          top: BorderSide(color: kBlackColor2),
          bottom: BorderSide(color: kBlackColor2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          _NamedIcons(contact: contact),
          SizedBox(height: 10),
          _About(contact: contact),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ChatInfo extends StatelessWidget {
  final String groupId;
  const _ChatInfo({
    Key key,
    @required this.groupId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBlackColor,
        border: Border(
          top: BorderSide(color: kBlackColor2),
          bottom: BorderSide(color: kBlackColor2),
        ),
      ),
      child: Column(
        children: [
          _MediaAndLinks(groupId: groupId),
          Divider(
              height: 0,
              color: kBorderColor1,
              indent: 65), // 65 (left padding + icon size)
          _MediaTile(
              icon: Icons.star,
              iconColor: Hexcolor('#800020'),
              title: 'Starred Messages',
              end: 'None'),
          Divider(
            height: 0,
            color: kBorderColor1,
            indent: 65,
          ),
          _MediaTile(
            icon: Icons.search,
            iconColor: Hexcolor('##ff6d00'),
            title: 'Chat Search',
            end: '',
          ),
        ],
      ),
    );
  }
}

class _MediaAndLinks extends StatefulWidget {
  final groupId;
  const _MediaAndLinks({
    Key key,
    this.groupId,
  }) : super(key: key);

  @override
  __MediaAndLinksState createState() => __MediaAndLinksState();
}

class __MediaAndLinksState extends State<_MediaAndLinks> {
  DB db;
  Stream<QuerySnapshot> mediaStream;

  @override
  void initState() {
    super.initState();
    db = DB();
    mediaStream = db.getMediaCount(widget.groupId);
  }

  void navToMedia() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatMediaScreen(widget.groupId),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: navToMedia,
        highlightColor: kBlackColor2,
        // splashColor: Colors.transparent,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
          child: Row(
            children: [
              Icon(
                Icons.image,
                size: 35,
                color: Theme.of(context).accentColor,
              ),
              SizedBox(width: 10),
              Text(
                'Media, Links, and Docs',
                style: TextStyle(
                  fontSize: 17,
                  color: kBaseWhiteColor,
                ),
              ),
              Spacer(),
              StreamBuilder(
                stream: mediaStream,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return CupertinoActivityIndicator();
                  else if (snapshot.data.documents.length == 0)
                    return Text('0', style: kChatItemSubtitleStyle);
                  else
                    return Text('${snapshot.data.documents.length}',
                        style: kChatItemSubtitleStyle);
                },
              ),
              SizedBox(width: 5),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white.withOpacity(0.7),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String end;
  final Function onTap;
  const _MediaTile({
    Key key,
    this.icon,
    this.iconColor,
    this.title,
    this.end,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: kBlackColor2,
        // splashColor: Colors.transparent,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 35,
                color: iconColor,
              ),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  color: kBaseWhiteColor,
                ),
              ),
              Spacer(),
              Text(end, style: kChatItemSubtitleStyle),
              SizedBox(width: 5),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white.withOpacity(0.7),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _About extends StatelessWidget {
  final User contact;
  const _About({
    Key key,
    this.contact,
  }) : super(key: key);

  String getAboutChangeDate(DateTime changeDate) {
    if (changeDate == null) return 'Not Available';
    return DateFormat('MMMM dd yyyy').format(changeDate);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contact.about ?? 'Not Available.',
            style: TextStyle(fontSize: 16, color: kBaseWhiteColor),
          ),
          SizedBox(height: 5),
          Text(
            getAboutChangeDate(contact.aboutChangeDate),
            style: kChatItemSubtitleStyle,
          ),
        ],
      ),
    );
  }
}

class _NamedIcons extends StatelessWidget {
  final User contact;
  const _NamedIcons({
    Key key,
    this.contact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: kBorderColor2))),
      padding: const EdgeInsets.only(right: 20, bottom: 10),
      margin: const EdgeInsets.only(
        left: 20,
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contact.username,
                style: TextStyle(
                    color: kBaseWhiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 5),
              Text(contact.email ?? 'No Available',
                  style: kChatItemSubtitleStyle),
            ],
          ),
          Spacer(),
          _Icon(icon: Icons.message, onTap: () => Navigator.of(context).pop()),
          SizedBox(width: 5),
          _Icon(icon: Icons.videocam),
          SizedBox(width: 5),
          _Icon(icon: Icons.call),
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final IconData icon;
  final Function onTap;
  const _Icon({
    Key key,
    @required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      onPressed: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(shape: BoxShape.circle, color: kBlackColor3),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }
}

class _Image extends StatelessWidget {
  final User contact;
  const _Image({
    Key key,
    @required this.contact,
  }) : super(key: key);

  void navToImageView(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          MediaView(url: contact.imageUrl, type: MediaType.Photo),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (contact.imageUrl == null || contact.imageUrl == '') {
      return Container(
        width: size.width,
        color: kBlackColor,
        height: size.height * 0.3,
        child: Icon(
          Icons.person,
          size: size.height * 0.25,
          color: kBaseWhiteColor,
        ),
      );
    }
    return GestureDetector(
      onTap: () => navToImageView(context),
      child: Container(
        width: size.width,
        height: size.height * 0.3,
        child: Hero(
          tag: contact.imageUrl,
          child: CachedNetworkImage(
            imageUrl: contact.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
      // ),
    );
  }
}
