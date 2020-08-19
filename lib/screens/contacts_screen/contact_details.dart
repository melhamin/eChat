import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/person.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/screens/chats_screen/chat_media_screen.dart';
import 'package:whatsapp_clone/services/db.dart';
import 'package:whatsapp_clone/services/storage.dart';
import 'package:whatsapp_clone/widgets/back_button.dart';
import 'package:whatsapp_clone/widgets/image_view.dart';

class ContactDetails extends StatefulWidget {
  final Person info;
  final String groupId;
  ContactDetails(this.info, this.groupId);
  @override
  _ContactDetailsState createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  Storage storage;
  DB db;

  @override
  void initState() {
    super.initState();
    storage = Storage();
    db = DB();
  }

  void navToImageView() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ImageView(widget.info.imageUrl),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ));
  }

  Widget _buildImage(MediaQueryData mq) {
    if (widget.info.imageUrl == null || widget.info.imageUrl == '') {
      return Container(
        width: mq.size.width,
        color: Hexcolor('#202020'),
        height: mq.size.height * 0.3,
        child: Icon(
          Icons.person,
          size: mq.size.height * 0.25,
          color: kBaseWhiteColor,
        ),
      );
    }
    return GestureDetector(
      onTap: navToImageView,
      child: Container(
        width: mq.size.width,
        height: mq.size.height * 0.3,
        child: Hero(
          tag: widget.info.imageUrl,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25),
              topLeft: Radius.circular(25),
            ),
            child: CachedNetworkImage(
              imageUrl: widget.info.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, Function onTap) {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: kBlackColor3),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }

  Widget _buildNameAndIcons() {
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
                widget.info.name,
                style: TextStyle(
                    color: kBaseWhiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 5),
              Text(widget.info.email ?? 'No Available',
                  style: kChatItemSubtitleStyle),
            ],
          ),
          Spacer(),
          _buildIcon(Icons.message, () => Navigator.of(context).pop()),
          SizedBox(width: 5),
          _buildIcon(Icons.videocam, () {}),
          SizedBox(width: 5),
          _buildIcon(Icons.call, () {}),
        ],
      ),
    );
  }

  String getAboutChangeDate(DateTime changeDate) {
    if (changeDate == null) return 'Not Available';
    return DateFormat('MMMM dd yyyy').format(changeDate);
  }

  Widget _buildAbout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.info.about ?? 'Not Available.',
            style: TextStyle(fontSize: 16, color: kBaseWhiteColor),
          ),
          SizedBox(height: 5),
          Text(
            getAboutChangeDate(widget.info.aboutChangeDate),
            style: kChatItemSubtitleStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() => Container(
        decoration: BoxDecoration(
          color: Hexcolor('#202020'),
          border: Border(
            top: BorderSide(color: kBorderColor2),
            bottom: BorderSide(color: kBorderColor2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildNameAndIcons(),
            SizedBox(height: 10),
            _buildAbout(),
            SizedBox(height: 20),
          ],
        ),
      );

  Widget _buildMediaTile(
          IconData icon, Color iconColor, String title, String end,
          [Function onTap]) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          highlightColor: kBlackColor,
          splashColor: Colors.transparent,
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

  Widget _buildMedia() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: navToMedia,
        highlightColor: kBlackColor,
        splashColor: Colors.transparent,
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
                stream: db.getMediaCount(widget.groupId),
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

  void navToMedia() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatMediaScreen(widget.groupId),
    ));
  }

  Widget _buildMediaInfo() => Container(
        decoration: BoxDecoration(
          color: Hexcolor('#202020'),
          border: Border(
            top: BorderSide(color: kBorderColor2),
            bottom: BorderSide(color: kBorderColor2),
          ),
        ),
        child: Column(
          children: [
            _buildMedia(),
            // _buildMediaTile(Icons.image, Theme.of(context).accentColor,
            //     'Media, Links, and Docs', '16', navToMedia),
            Divider(
                height: 0,
                color: kBorderColor1,
                indent: 65), // 65 (left padding + icon size)
            _buildMediaTile(
                Icons.star, Hexcolor('#800020'), 'Starred Messages', 'None'),
            Divider(height: 0, color: kBorderColor1, indent: 65),
            _buildMediaTile(
                Icons.search, Hexcolor('##ff6d00'), 'Chat Search', ''),
          ],
        ),
      );

  Widget _buildActionsTile(String title, MediaQueryData mq) => Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: kBlackColor,
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            width: mq.size.width,
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

  Widget _buildContactActions(MediaQueryData mq) => Container(
        decoration: BoxDecoration(
          color: Hexcolor('#202020'),
          border: Border(
            top: BorderSide(color: kBorderColor2),
            bottom: BorderSide(color: kBorderColor2),
          ),
        ),
        child: Column(
          children: [
            _buildActionsTile('Share Contact', mq),
            Divider(
                height: 0,
                color: kBorderColor1,
                indent: 20), // 20 (left padding + icon size)
            _buildActionsTile('Export Chat', mq),
            Divider(
                height: 0,
                color: kBorderColor1,
                indent: 20), // 20 (left padding + icon size)
            _buildActionsTile('Clear Chat', mq),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);    
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 5),
          child: AppBar(
            centerTitle: true,
            backgroundColor: kBlackColor,
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
            // color: Hexcolor('#202020'),
          ),
          width: mq.size.width,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25),
              topLeft: Radius.circular(25),
            ),
            child: ListView(
              children: [
                _buildImage(mq),
                _buildInfo(),
                SizedBox(height: 20),
                _buildMediaInfo(),
                SizedBox(height: 20),
                _buildContactActions(mq),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
