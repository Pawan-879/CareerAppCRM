import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';

class DailyVideosPlayer extends StatefulWidget {
  const DailyVideosPlayer({Key? key}) : super(key: key);
  static const routeName = '/daily_videos_player';
  @override
  _DailyVideosPlayerState createState() => _DailyVideosPlayerState();
}

class _DailyVideosPlayerState extends State<DailyVideosPlayer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;

  var section_id = "";
  var data4 = [];
  var userData;
  var user_id = "";

  dynamic videos;

  var description = ' ';

  late PlayerState playerState;
  late YoutubeMetaData videoMetaData;
  bool _isPlayerReady = false;

  final List<String> _ids = [];
  String player_name = "Player";
  int i = 1;

  String first_video_id = "";

  var title = ' ';

  String? text;
  final List<String> avatars = [
    "http://careerinstitute.co/app/user.png",
    "http://careerinstitute.co/app/logo.png",
  ];

  final rand = Random();

  final GlobalKey<FormState> _formKey = GlobalKey();
  var comment = TextEditingController();
  final _authData = {"comments": ""};
  var video_id;
  var comments = [];
  int user_rating = 0;
  var db_rating = "0/5 Rating";
  @override
  void initState() {
    super.initState();
    getUserData();
    initCode();
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      userData = json.decode(prefs.getString('userData')!);

      user_id = userData["user_id"];

      Future.delayed(Duration.zero, () {
        videos = ModalRoute.of(context)?.settings.arguments;
        description = videos["description"];
        title = videos["title"];
        //    getData2(videos["type"], user_id);
        first_video_id = videos["video_id"];
        video_id = videos["id"];
        setUserWatched(user_id, videos["id"]);
        getUserComments(video_id);
        debugPrint("video id:$first_video_id");
        print(videos);
        setState(() {
          _ids.add(first_video_id);
          //  _controller.load(first_video_id);
        });
      });

      setState(() {});
    } else {
      Future.delayed(Duration.zero, () {
        videos = ModalRoute.of(context)?.settings.arguments;
        first_video_id = videos["video_id"];
        description = videos["description"] ?? '';
        title = videos["title"] ?? '';
        video_id = videos["id"];
        getUserComments(video_id);

        setState(() {
          _ids.add(first_video_id);
          //  _controller.load(first_video_id);
        });
      });

      //  getData();
    }
  }

  getUserComments(id) async {
    var res =
        await ApiService.getMethod("/getDailyVideoComments?video_id=" + id);
    comments = jsonDecode(res.body);
    int totalrating = 0;
    for (var element in comments) {
      totalrating += int.parse(element["rating"]);
    }

    double finalRating = (totalrating / comments.length);

    setState(() {
      db_rating = "${finalRating.round()}/5 Rating";
    });
  }

  setUserWatched(uId, vId) async {
    debugPrint("user_id=" + uId + ", video_id=" + vId);
    await ApiService.getMethod(
        "/setUserWatched?user_id=" + uId + "&video_id=" + vId);
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

  // getData() async {
  //   var res = await ApiService.getMethod("/getDailyVideos");

  //   data4 = jsonDecode(res.body);
  //   data4.forEach((element) {
  //     if (i == 1) {
  //       debugPrint("myvideo code:" + first_video_id);
  //       _controller.load(first_video_id);
  //     }
  //     _ids.add(element["video_link"]);
  //     i++;
  //   });

  //   setState(() {});
  // }

  // getData2(type, user_id2) async {
  //   var res = await ApiService.getMethod(
  //       "/getDailyVideos?user_id=" + user_id2 + "&type=" + type);

  //   data4 = jsonDecode(res.body);
  //   data4.forEach((element) {
  //     if (i == 1) {
  //       debugPrint("myvideo code:" + first_video_id);
  //       _controller.load(first_video_id);
  //     }
  //     _ids.add(element["video_link"]);
  //     i++;
  //   });

  //   setState(() {});
  // }

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
      onExitFullScreen: () {},
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
              debugPrint("pos");
              debugPrint(_controller.value.position.inSeconds.toString());
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
            title: const Text(
          "Daily Videos",
          style: TextStyle(color: Colors.white),
        )),
        body: Column(
          children: <Widget>[
            player,
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.star,
                    color: Colors.pink,
                    size: 28,
                  ),
                  Container(
                    width: (MediaQuery.of(context).size.width / 2) - 30,
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      db_rating,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  Container(
                    width: (MediaQuery.of(context).size.width / 2) - 30,
                    padding: const EdgeInsets.all(0),
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                          textStyle: const TextStyle(color: Colors.black)),
                      onPressed: () {
                        popup();
                      },
                      child: const Text('WRITE A REVIEW'),
                    ),
                  ),
                  const SizedBox(width: 20)
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 10.0);
                },
                reverse: true,
                itemCount: comments.length,
                itemBuilder: (BuildContext context, int index) {
                  dynamic m = comments[index];
                  return _buildMessageRow(m);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void popup() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text('WRITE A REVIEW'),
              content:
                  StatefulBuilder(// You need this, notice the parameters below:
                      builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                    height: 270,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.star),
                                color: user_rating >= 1
                                    ? Colors.pink
                                    : Colors.grey[300],
                                highlightColor: Colors.black,
                                onPressed: () {
                                  setState(() {
                                    user_rating = 1;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.star),
                                color: user_rating >= 2
                                    ? Colors.pink
                                    : Colors.grey[300],
                                highlightColor: Colors.black,
                                onPressed: () {
                                  setState(() {
                                    user_rating = 2;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.star),
                                color: user_rating >= 3
                                    ? Colors.pink
                                    : Colors.grey[300],
                                highlightColor: Colors.black,
                                onPressed: () {
                                  setState(() {
                                    user_rating = 3;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.star),
                                color: user_rating >= 4
                                    ? Colors.pink
                                    : Colors.grey[300],
                                highlightColor: Colors.black,
                                onPressed: () {
                                  setState(() {
                                    user_rating = 4;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.star),
                                color: user_rating >= 5
                                    ? Colors.pink
                                    : Colors.grey[300],
                                highlightColor: Colors.black,
                                onPressed: () {
                                  setState(() {
                                    user_rating = 5;
                                  });
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: comment,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            onEditingComplete: () =>
                                FocusScope.of(context).nextFocus(),
                            style: const TextStyle(
                              color: Colors.black,
                              // height: 0.5,
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Enter Your Comments' : null,
                            onSaved: (value) {
                              _authData['comments'] = value!;
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 1.0),
                              ),
                              hintText: "Comments",
                              hintStyle:
                                  TextStyle(fontSize: 14.0, color: Colors.blue),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: 200,
                            height: 44,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  textStyle:
                                      const TextStyle(color: Colors.white),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                              onPressed: () async {
                                if (user_id != "") {
                                  _formKey.currentState!.save();
                                  if (validateAndSave()) {
                                    var data = json.encode({
                                      "comments": comment.text,
                                      "user_id": user_id,
                                      "video_id": video_id,
                                      "rating": user_rating
                                    });

                                    try {
                                      var response =
                                          await ApiService.postMethod(
                                        '/addDailyVideoComment',
                                        data,
                                      );

                                      if (response["status"] == 1 ||
                                          response["status"] == "1") {
                                        Fluttertoast.showToast(
                                            msg: "Submit successfully.",
                                            timeInSecForIosWeb: 10);

                                        getUserComments(video_id);
                                        Navigator.pop(context);
                                      }
                                    } catch (err) {
                                      debugPrint(err.toString());
                                    }
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Please login for comments.",
                                      timeInSecForIosWeb: 10);
                                }
                              },
                              child: const Text('Submit'),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ));
              }));
        });
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Row _buildMessageRow(dynamic message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: message["user_type"] == "1" ? 20.0 : 30.0),
        CircleAvatar(
          backgroundImage: NetworkImage(
            message["user_type"] == "1" ? avatars[0] : avatars[1],
          ),
          radius: 20.0,
        ),
        const SizedBox(width: 5.0),

        ///Chat bubbles
        Container(
          width: MediaQuery.of(context).size.width - 100,
          padding: const EdgeInsets.only(
            bottom: 5,
            right: 5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[800]!),
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15, top: 10, bottom: 5, right: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          message["user_type"] == "2"
                              ? "Career Defence Academy"
                              : message["user_name"],
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          message["comments"],
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.done_all,
                        color: Colors.white,
                        size: 14,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                message["created"],
                style: TextStyle(
                    fontSize: 12, color: Colors.black.withOpacity(0.5)),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class Message {
  final int user;
  final String description;

  Message(this.user, this.description);
}
