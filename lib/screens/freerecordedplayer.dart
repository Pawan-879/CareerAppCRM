import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert';
import 'package:careerapp/services/api_services.dart';

class FreeRecordedScreen extends StatefulWidget {
  const FreeRecordedScreen({Key? key}) : super(key: key);
  static const routeName = '/freerecordedplayer';

  @override
  _FreeRecordedScreenState createState() => _FreeRecordedScreenState();
}

class _FreeRecordedScreenState extends State<FreeRecordedScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;

  var section_id = "";
  var data4 = [];

  PlayerState? playerState;
  YoutubeMetaData? videoMetaData;
  bool _muted = false;
  bool _isPlayerReady = false;

  final List<String> _ids = [];

  String player_name = "Recorded Videos";

  @override
  void initState() {
    super.initState();
    initCode();
    Future.delayed(Duration.zero, () {
      dynamic data88 = ModalRoute.of(context)!.settings.arguments;
      getData(data88["section_id"], data88["type"]);
    });
  }

  initCode() {
    _controller = YoutubePlayerController(
      initialVideoId: 'rTk18GwzSWw',
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: false,
      ),
    )..addListener(listener);

    _idController = TextEditingController();
    _seekToController = TextEditingController();
    videoMetaData = const YoutubeMetaData();
    playerState = PlayerState.unknown;
  }

  getData(id, type) async {
    var i = 1;
    var res = await ApiService.getMethod(
        "/getFreeRecordedVideos?section_id=$id&type=$type");
    print("/getFreeRecordedVideos?section_id=$id");
    data4 = jsonDecode(res.body);
    for (var element in data4) {
      if (i == 1) {
        _controller.load(element["item_link"]);
        player_name = element["item_name"];
      }
      _ids.add(element["item_link"]);
      i++;
    }

    setState(() {});
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        playerState = _controller.value.playerState;
        videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        topActions: <Widget>[
          const SizedBox(height: 200),
          const SizedBox(width: 0),
          const Text("15 Sec", style: TextStyle(color: Colors.white)),
          IconButton(
            icon: const Icon(
              Icons.fast_rewind,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              _controller.seekTo(
                  Duration(seconds: _controller.value.position.inSeconds - 15));
            },
          ),
          SizedBox(width: deviceSize.width - 200),
          IconButton(
            icon: const Icon(
              Icons.fast_forward,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              _controller.seekTo(
                  Duration(seconds: _controller.value.position.inSeconds + 15));
              print("pos");
              print(_controller.value.position.inSeconds);
            },
          ),
          const Text("15 Sec", style: TextStyle(color: Colors.white))
        ],
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          _controller
              .load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
        },
      ),
      builder: (context, player) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            title: Text(
          player_name,
          style: const TextStyle(color: Colors.white),
        )),
        body: Column(
          children: <Widget>[
            player,
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _space,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        onPressed: _isPlayerReady
                            ? () => _controller.load(_ids[
                                (_ids.indexOf(_controller.metadata.videoId) -
                                        1) %
                                    _ids.length])
                            : null,
                      ),
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: _isPlayerReady
                            ? () {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                                setState(() {});
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: _isPlayerReady
                            ? () => _controller.load(_ids[
                                (_ids.indexOf(_controller.metadata.videoId) +
                                        1) %
                                    _ids.length])
                            : null,
                      ),
                      IconButton(
                        icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                        onPressed: _isPlayerReady
                            ? () {
                                _muted
                                    ? _controller.unMute()
                                    : _controller.mute();
                                setState(() {
                                  _muted = !_muted;
                                });
                              }
                            : null,
                      ),
                      FullScreenButton(
                        controller: _controller,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                  _space,
                ],
              ),
            ),
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
                      return _courseCard((index + 1).toString(),
                          data4[index]["item_link"], data4[index]["item_name"]);
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget get _space => const SizedBox(height: 10);

  _courseCard(
    String id,
    String videoId,
    String title,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          player_name = title;
        });
        _controller.load(videoId);
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
