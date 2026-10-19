import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'dart:convert';
import 'package:careerapp/services/api_services.dart';

class FreePlayerScreen3 extends StatefulWidget {
  const FreePlayerScreen3({Key? key}) : super(key: key);
  static const routeName = '/freeplayer3';

  @override
  _FreePlayerScreen3State createState() => _FreePlayerScreen3State();
}

class _FreePlayerScreen3State extends State<FreePlayerScreen3> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late YoutubePlayerController _controller;

  var section_id = "";
  var data4 = [];

  PlayerState? playerState;
  YoutubeMetaData? videoMetaData;
  final bool _isPlayerReady = false;

  final List<String> _ids = [];

  @override
  void initState() {
    super.initState();
    initCode();
    Future.delayed(Duration.zero, () {
      dynamic data33 = ModalRoute.of(context)!.settings.arguments;
      //print(data33["section_id"]);
      getData(data33["section_id"].toString(), data33["type"].toString());
    });
  }

  initCode() {
    _controller.loadVideoById(
      videoId: "rTk18GwzSWw",
      startSeconds: 96.0,
    );
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        // playlist: [
        //   'nPt8bK2gbaU',
        //   'K18cpp_-gP8',
        //   'iLnmTe5Q2Qw',
        //   '_WoCV4c6XOE',
        //   'KmzdUe0RSJo',
        //   '6jZDSSZZxjQ',
        //   'p2lYr3vM_1w',
        //   '7QUtEmBT_-w',
        //   '34_PXCzGw1M',
        // ],
        showControls: true,
        showFullscreenButton: true,
      ),
    );
    _controller.setFullScreenListener((value) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
  }

  getData(id, type) async {
    print("/getFreeCourseVideos?section_id=" + id + "&type=" + type);
    var res = await ApiService.getMethod(
        "/getFreeCourseVideos?section_id=$id&type=" + type);
    data4 = jsonDecode(res.body);
    for (var element in data4) {
      _ids.add(element["youtube_link"]);
    }
    _controller.loadVideoById(videoId: _ids[0]);
    setState(() {});
  }

  void listener() {
    _controller.setFullScreenListener(
      (isFullScreen) {
        if (_isPlayerReady && mounted && !isFullScreen) {
          setState(() {
            playerState = _controller.value.playerState;
            videoMetaData = _controller.metadata;
          });
        }
      },
    );
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    //_controller.close();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      builder: (context, player) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
              title: const Text(
            'Player',
            style: TextStyle(color: Colors.white),
          )),
          body: Column(
            children: <Widget>[
              player,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: Colors.blue,
                child: const Text(
                  "TOPICS LIST ",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
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
                        return _courseCard(
                            (index + 1).toString(),
                            data4[index]["youtube_link"],
                            data4[index]["video_title"]);
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  _courseCard(
    String id,
    String videoId,
    String title,
  ) {
    return GestureDetector(
      onTap: () {
        //print(video_id);
        _controller.loadVideoById(videoId: videoId);
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
