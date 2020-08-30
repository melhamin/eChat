import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../consts.dart';


class ContactItem extends StatelessWidget {
  final DocumentSnapshot item;
    final Function onTap;
  const ContactItem({
    @required this.item,
    @required this.onTap,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // splashColor: Colors.transparent,
        highlightColor: kBlackColor2,
        onTap: () => onTap(context, item),
        child: Container(
          height: 70,
          child: Center(
            child: ListTile(
                // contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: kBlackColor3,
                  radius: 27,
                  child: (item['imageUrl'] == null || item['imageUrl'] == '')
                      ? Icon(
                          Icons.person,
                          size: 25,
                          color: kBaseWhiteColor,
                        )
                      : null,
                  backgroundImage:
                      (item['imageUrl'] != null && item['imageUrl'] != '')
                          ? CachedNetworkImageProvider(item['imageUrl'])
                          : null,
                ),
                title:
                    Text(item['username'] ?? 'NA', style: kChatItemTitleStyle)),
          ),
        ),
      ),
    );
  }
}
