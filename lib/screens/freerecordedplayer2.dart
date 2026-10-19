import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'package:careerapp/services/api_services.dart';

class FreeRecordedScreen2 extends StatefulWidget {
  const FreeRecordedScreen2({Key? key}) : super(key: key);
  static const routeName = '/freerecordedplayer2';

  @override
  _FreeRecordedScreen2State createState() => _FreeRecordedScreen2State();
}

class _FreeRecordedScreen2State extends State<FreeRecordedScreen2> {
  String url = "";
  var section_id = "";
  var data4 = [];
  final List<String> _ids = [];
  bool myflag = false;

  late VideoPlayerController _controller;
  Future<void>? initializeVideoPlayerFuture;
  int? playBackTime;
  Duration? newCurrentPosition;

  List<Duration>? timestamps;

  String player_name = "Player";

  int i = 1;

  @override
  void initState() {
    super.initState();
    initializePlayer("https://www.careerdefenceschool.com/videos/video_1.mp4");
    Future.delayed(Duration.zero, () {
      dynamic data33 = ModalRoute.of(context)!.settings.arguments;
      //print(data33["section_id"]);
      getData(data33["section_id"].toString(), data33["type"].toString());
    });
  }
  //  url ="https://d33k6ew5mnycbk.cloudfront.net/pcloud/9thclassscience/physics/chptr3/5.mp4";

  getData(id, type) async {
    var res = await ApiService.getMethod(
        "/getFreeRecordedVideos?section_id=$id&type=$type");
    data4 = jsonDecode(res.body);

    for (var element in data4) {
      if (i == 1) {
        player_name = element["item_name"];

        url = element["video_link"];
        _startPlay(url, player_name);
      }
      _ids.add(element["video_link"]);
      i++;
    }

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> initializePlayer(url1) async {
    _controller = VideoPlayerController.network(url1)
      ..initialize().then((_) {
        _controller.play();
      });
    setState(() {});
  }

  Future<void> _initializePlay(String videoPath) async {
    _controller = VideoPlayerController.network(videoPath);
    _controller.addListener(() {
      setState(() {
        playBackTime = _controller.value.position.inSeconds;
      });
    });
    initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.seekTo(newCurrentPosition!);
      _controller.play();
    });
  }

  Future<void> _startPlay(String url, String title) async {
    setState(() {
      initializeVideoPlayerFuture = null;
      player_name = title;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _clearPrevious().then((_) {
        _initializePlay(url);
      });
    });
  }

  Future<bool> _clearPrevious() async {
    await _controller.pause();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          player_name,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(children: <Widget>[
        _controller.value.isInitialized
            ? Stack(
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        VideoPlayer(_controller), //here it is!!
                        VideoProgressIndicator(_controller,
                            allowScrubbing: true),
                      ],
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          _controller.value.isPlaying ? null : Icons.play_arrow,
                          size: 60,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 120),
                  Center(child: Text('Loading')),
                ],
              ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.fast_rewind),
                    onPressed: () {
                      rewind5Seconds();
                    },
                  ),
                  IconButton(
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                        setState(() {});
                      }),
                  IconButton(
                    icon: const Icon(Icons.fast_forward),
                    onPressed: () {
                      forward5Seconds();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: data4.length,
                itemBuilder: (context, index) {
                  return _courseCard((index + 1).toString(),
                      data4[index]["video_link"], data4[index]["item_name"]);
                },
              ),
            ),
          ),
        )
      ]),
    );
  }

  Widget buildButton(Widget child, Function onPressed) => SizedBox(
        height: 50,
        width: 50,
        child: ElevatedButton(
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.1)),
          child: child,
          onPressed: () => onPressed(),
        ),
      );

  Future rewindToPosition() async {
    if (timestamps!.isEmpty) return;
    Duration rewind(Duration currentPosition) => timestamps!.lastWhere(
          (element) => currentPosition > element + const Duration(seconds: 2),
          orElse: () => Duration.zero,
        );

    await goToPosition(rewind);
  }

  Future forwardToPosition() async {
    if (timestamps!.isEmpty) return;
    Duration forward(Duration currentPosition) => timestamps!.firstWhere(
          (position) => currentPosition < position,
          orElse: () => const Duration(days: 1),
        );

    await goToPosition(forward);
  }

  Future forward5Seconds() async => goToPosition(
      (currentPosition) => currentPosition + const Duration(seconds: 25));

  Future rewind5Seconds() async => goToPosition(
      (currentPosition) => currentPosition - const Duration(seconds: 25));

  Future goToPosition(
    Duration Function(Duration currentPosition) builder,
  ) async {
    final currentPosition = await _controller.position;
    final newPosition = builder(currentPosition!);

    await _controller.seekTo(newPosition);
  }

  _courseCard(
    String id,
    String videoId,
    String title,
  ) {
    return GestureDetector(
      onTap: () {
        _startPlay(videoId, title);
        //print(video_id);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Container(
          color: Colors.blue[50],
          child: ListTile(
            leading: Text(id,
                style: TextStyle(
                  fontSize: 32,
                  color: const Color(0xFF0D1333).withOpacity(0.15),
                  fontWeight: FontWeight.bold,
                )),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0D1333),
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
