import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_clone/consts.dart';

class CVideoPlayer extends StatefulWidget {
  final File video;
  final String url;
  final bool isLocal;

  CVideoPlayer({
    this.video,
    this.url,
    this.isLocal = false,
  });

  @override
  _CVideoPlayerState createState() => _CVideoPlayerState();
}

class _CVideoPlayerState extends State<CVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController _controller;
  Future<void> _initializedPlayerFuture;
  @override
  void initState() {
    super.initState();
    if (widget.isLocal)
      _controller = VideoPlayerController.file(widget.video);
    else
      _controller = VideoPlayerController.network(widget.url);
    // _controller.setLooping(true);

    _initializedPlayerFuture = _controller.initialize();
    //.then((value) => setState(() {_controller.play();}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void togglePlay() {
    setState(() {
      if (_controller.value.isPlaying)
        _controller.pause();
      else
        _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: _initializedPlayerFuture,
                builder: (ctx, snaps) {
                  if (snaps.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    );
                  }
                  return Center(child: CupertinoActivityIndicator());
                },
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.center,
          child: CupertinoButton(
            onPressed: togglePlay,
            padding: const EdgeInsets.all(0),
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Theme.of(context).accentColor.withOpacity(0.8), width: 2),
              ),
              child: Center(
                child: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_circle_filled_outlined
                      : Icons.play_arrow_outlined,
                  color: Theme.of(context).accentColor.withOpacity(0.8),
                  size: 70,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
