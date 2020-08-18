import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../consts.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    @required this.imageUrl,
    Key key,
   
  }) : super(key: key);  

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
          backgroundColor: Hexcolor('#202020'),
          backgroundImage:
            imageUrl == null || imageUrl == ''
                  ? null
                  : CachedNetworkImageProvider(imageUrl),
          child: imageUrl == null || imageUrl == ''
              ? Icon(Icons.person, color: kBaseWhiteColor)
              : null,
          radius: 15,
        );
  }
}
