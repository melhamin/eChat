import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final String url;
  ImageView(this.url);
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Hero(
            tag: url,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                color: Colors.red,
                constraints: BoxConstraints(
                  maxHeight: mq.size.height * 0.7,
                ),
                height: double.infinity,
                width: double.infinity,
                child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
