import 'package:flutter/material.dart';
import 'package:careerapp/models/feed_model.dart';
import 'package:careerapp/screens/social/widgets/swipeable_videos.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final FeedItem feedItem;
  final bool play;
  final String userId;
  final String userName;
  const CustomVideoPlayer(
      {Key? key,
      required this.feedItem,
      required this.play,
      required this.userId,
      required this.userName})
      : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? videoPlayerController;

  @override
  void initState() {
    initializeVideoPlayer();
    super.initState();
  }

  Future<void> initializeVideoPlayer() async {
    videoPlayerController =
        VideoPlayerController.network(widget.feedItem.image![0])
          ..initialize().then((_) {
            setState(() {}); //when your thumbnail will show.
          });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SwipeVideosScreen(
                      feedItem: widget.feedItem,
                      userId: widget.userId,
                      userName: widget.userName,
                      isFeed: true,
                    )));
      },
      child: Stack(
        children: [
          Center(
              child: AspectRatio(
            aspectRatio: videoPlayerController!.value.aspectRatio,
            child: VideoPlayer(videoPlayerController!),
          )),
          Positioned.fill(
              child: Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              backgroundColor: Colors.grey.withOpacity(0.5),
              radius: 50,
              child: const Icon(
                Icons.play_circle_outline_sharp,
                size: 100,
                color: Colors.white,
              ),
            ),
          ))
        ],
      ),
    );
  }

  @override
  void dispose() {
    videoPlayerController!.dispose();
    super.dispose();
  }
}
