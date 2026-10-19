import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:careerapp/models/feed_model.dart';
import 'package:video_player/video_player.dart';

import 'video_options_widget.dart';

class VideoContentWidget extends StatefulWidget {
  // final ShortItem? src;
  final FeedItem? src;
  final String userId;
  final String userName;

  const VideoContentWidget(
      {Key? key, this.src, required this.userId, required this.userName})
      : super(key: key);

  @override
  _VideoContentWidgetState createState() => _VideoContentWidgetState();
}

class _VideoContentWidgetState extends State<VideoContentWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future initializePlayer() async {
    _videoPlayerController =
        VideoPlayerController.network(widget.src!.image![0]);
    await Future.wait([_videoPlayerController.initialize()]);
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        showControls: false,
        looping: true,
        allowFullScreen: false);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(
                controller: _chewieController!,
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
        VideoOptionsWidget(
          feedItem: widget.src!,
          userId: widget.userId,
          userName: widget.userName,
        )
      ],
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    if (_chewieController != null) {
      _chewieController?.dispose();
    }
    super.dispose();
  }
}
