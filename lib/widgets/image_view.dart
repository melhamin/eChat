import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final String url;
  ImageView(this.url);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: url,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              height: 300,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: url,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
