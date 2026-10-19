import 'dart:convert';

import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:flutter/material.dart';
import '../../../models/feed_model.dart';
import '../../../services/api_services.dart';
import 'package:sizer/sizer.dart';

import 'video_content_widget.dart';

class SwipeVideosScreen extends StatefulWidget {
  final FeedItem feedItem;
  final String userId;
  final String userName;
  final bool isFeed;
  const SwipeVideosScreen(
      {Key? key,
      required this.feedItem,
      required this.userId,
      required this.userName,
      required this.isFeed})
      : super(key: key);

  @override
  State<SwipeVideosScreen> createState() => _SwipeVideoScreenState();
}

class _SwipeVideoScreenState extends State<SwipeVideosScreen> {
  FeedModel homeData = FeedModel(data: []);
  List<FeedItem>? data = [];
  String message = '';
  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: SafeArea(
        child: Stack(
          children: [
            homeData.data!.isNotEmpty
                ? Swiper(
                    itemCount: homeData.data!.length,
                    itemBuilder: (context, int index) {
                      return VideoContentWidget(
                        src: homeData.data![index],
                        userId: widget.userId,
                        userName: widget.userName,
                      );
                    },
                    scrollDirection: Axis.vertical,
                    loop: true,
                    controller: SwiperController(),
                  )
                : Container(
                    alignment: Alignment.center,
                    height: 100.h,
                    child: const Column(
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
                  ),
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  getData() async {
    var res2 = await ApiService.getMethod(
        "//getVideoPosts2?id=${widget.feedItem.id}");
    if (List.from(jsonDecode(res2.body)['data'])
        .map((item) => FeedItem.fromJson(item))
        .toList()
        .isNotEmpty) {
      data!.add(widget.feedItem);
      data!.addAll(List.from(jsonDecode(res2.body)['data'])
          .map((item) => FeedItem.fromJson(item))
          .toList());

      setState(() {
        homeData = FeedModel(
            data: data,
            response: jsonDecode(res2.body)['response'],
            status: jsonDecode(res2.body)['status']);
      });
    } else {
      setState(() {
        message = "No Feed Found";
      });
    }
  }
}
