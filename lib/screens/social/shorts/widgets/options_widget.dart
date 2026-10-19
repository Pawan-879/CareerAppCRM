import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:careerapp/models/shorts_video_model.dart';

import '../../../../services/api_services.dart';

class OptionsWidget extends StatefulWidget {
  final ShortItem shortItem;
  final String userId;
  final String userName;
  const OptionsWidget(
      {Key? key,
      required this.shortItem,
      required this.userId,
      required this.userName})
      : super(key: key);

  @override
  State<OptionsWidget> createState() => _OptionsWidgetState();
}

class _OptionsWidgetState extends State<OptionsWidget> {
  int likecount = 0;
  TextEditingController commentCntrlr = TextEditingController();
  final border = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(
        color: Colors.transparent,
      ));

  ShortItem shortItem = ShortItem();

  @override
  void initState() {
    shortItem = widget.shortItem;
    likecount = int.parse(shortItem.likesCount!.totalLikes!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 110),
                  Text(
                    shortItem.title!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(
                          "assets/logo.png",
                        ),
                        radius: 16,
                      ),
                      SizedBox(width: 6),
                      Text('Carear Defence School',
                          style: TextStyle(color: Colors.white)),
                      SizedBox(width: 10),
                      Icon(
                        Icons.verified,
                        size: 15,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 6),
                      // TextButton(
                      //   onPressed: () {},
                      //   child: const Text(
                      //     'Follow',
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  // Row(
                  //   children: const [
                  //     Icon(
                  //       Icons.music_note,
                  //       size: 15,
                  //     ),
                  //     Text('Original Audio - some music track--'),
                  //   ],
                  // ),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.thumb_up,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (widget.userId.isNotEmpty) {
                        _handlePostLike();
                      } else {
                        Fluttertoast.showToast(
                            msg: "Log in to like", timeInSecForIosWeb: 10);
                      }
                    },
                  ),
                  Text(likecount.toString(),
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 20),
                  IconButton(
                    icon:
                        const Icon(Icons.comment_rounded, color: Colors.white),
                    onPressed: () {
                      commentBottomSheetMenu();
                    },
                  ),
                  Text(shortItem.comments!.length.toString(),
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 20),
                  Transform(
                    transform: Matrix4.rotationZ(5.8),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                  SizedBox(height: 10.h),
                  const Icon(Icons.more_vert, color: Colors.white),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  _handlePostLike() async {
    var data = json.encode({
      'user_id': widget.userId,
      'short_video_id': shortItem.id,
    });

    try {
      var response2 = await ApiService.postMethod4(
        'Api/addShortVideoLike',
        data,
      );
      if (response2["status"] == "1") {
        Fluttertoast.showToast(msg: "Liked", timeInSecForIosWeb: 10);
        setState(() {
          likecount++;
        });
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  void commentBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (builder) {
          return StatefulBuilder(builder: (context, state) {
            return Container(
              height: 70.h,
              padding: EdgeInsets.symmetric(
                horizontal: 5.w,
              ),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0))),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Comments',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                            fontSize: 12.sp)),
                    trailing: IconButton(
                        onPressed: (() {
                          Navigator.pop(context);
                        }),
                        icon: const Icon(Icons.close)),
                  ),
                  SizedBox(height: 2.h, child: const Divider(height: 1)),
                  ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage(
                            "assets/profileimg.png",
                          ),
                          radius: 16,
                        ),
                        title: SizedBox(
                          width: 75.w,
                          height: 5.h,
                          child: TextFormField(
                            style: TextStyle(fontSize: 10.sp),
                            controller: commentCntrlr,
                            decoration: InputDecoration(
                                suffix: TextButton(
                                    onPressed: () async {
                                      if (widget.userId.isNotEmpty) {
                                        if (commentCntrlr.text.isNotEmpty) {
                                          await _handleCommentPost(
                                              commentCntrlr.text, state);
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "Enter comment.",
                                              timeInSecForIosWeb: 10);
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Log in to comment",
                                            timeInSecForIosWeb: 10);
                                      }
                                    },
                                    child: Text(
                                      'Post',
                                      style: TextStyle(
                                          color: Colors.indigo.shade900,
                                          fontWeight: FontWeight.normal),
                                    )),
                                contentPadding:
                                    EdgeInsets.only(left: 5.w, bottom: 2.5.h),
                                focusedBorder: border,
                                border: border,
                                enabledBorder: border,
                                filled: true,
                                fillColor: const Color(0xffF8F8FA),
                                hintText: 'Write a comment...'),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h, child: const Divider(height: 1)),
                      ListView.separated(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: shortItem.comments!.length,
                        itemBuilder: ((context, index) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.blue,
                              backgroundImage: AssetImage(
                                "assets/profileimg.png",
                              ),
                            ),
                            title: Text(
                              shortItem.comments![index].userName!,
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800),
                            ),
                            subtitle: Text(
                              shortItem.comments![index].comment!,
                              style: TextStyle(
                                  fontSize: 9.sp, color: Colors.grey.shade600),
                            ),
                          );
                        }),
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            color: Colors.grey.shade600,
                          );
                        },
                      )
                    ],
                  )
                ],
              ),
            );
          });
        });
  }

  _handleCommentPost(
      String comment, void Function(void Function()) state) async {
    var data = json.encode({
      'user_id': widget.userId,
      'short_video_id': shortItem.id,
      'comment': comment
    });

    try {
      var response2 = await ApiService.postMethod4(
        'Api/addShortVideoComment',
        data,
      );

      if (response2["status"] == "1") {
        Fluttertoast.showToast(msg: "Comment Posted.", timeInSecForIosWeb: 10);
        FocusScope.of(context).requestFocus(FocusNode());

        state(() {
          setState(() {
            shortItem.comments!
                .add(Comment(comment: comment, userName: widget.userName));
          });
        });

        commentCntrlr.clear();
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  @override
  void dispose() {
    commentCntrlr.dispose();
    super.dispose();
  }
}
