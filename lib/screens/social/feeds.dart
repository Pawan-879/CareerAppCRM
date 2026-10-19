import 'package:careerapp/widgets/webview_widget.dart';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import 'package:sizer/sizer.dart';

import 'package:careerapp/models/feed_model.dart';

import 'package:careerapp/services/api_services.dart';

import 'package:url_launcher/url_launcher.dart';

// import '../../models/shorts_video_model.dart';

import '../../models/shorts_video_model.dart';

import 'package:share_plus/share_plus.dart';

import 'shorts/short_screen.dart';

import 'widgets/feed_widget.dart';

import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';

import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import 'dart:io' show Platform;

import 'package:new_version/new_version.dart';



class Feeds extends StatefulWidget {

  const Feeds({Key? key}) : super(key: key);



  @override

  _FeedsState createState() => _FeedsState();

}



class _FeedsState extends State<Feeds> with SingleTickerProviderStateMixin {

  var data2 = [];

  var data4 = [];

  var images = [];

  var userName = "";

  var userId = "";

  var userData;

  var message = "";

  // late ScrollController controller;

  List<dynamic> feedList = [];

  FeedModel homeData = FeedModel(data: []);

  ShortsModel shortsModel = ShortsModel(data: []);

  int pageNo = 1;

  int shortsPageNo = 1;

  List<FeedItem>? data = [];

  List<ShortItem>? shortsData = [];

  late int daysLeft;



  bool isLoading = false;

  late DateTime nextSaturday;

  List dataHomePage = [];



  late DateTime nextSunday;



  get param => null;

  late AnimationController _controller2;



  @override

  void initState() {

    // controller = ScrollController()..addListener(_scrollListener);

    super.initState();



    _controller2 =

        AnimationController(vsync: this, duration: const Duration(seconds: 1))

          ..repeat();



    getUserData();

    getShortVideos(shortsPageNo);

    getData(1);

    getSlider();

    getHomePageFilters();

    //for web

    if (Platform.isAndroid) {

      _checkVersion();

    }



    // _showServiceFeedbackDialogOnce(); // Disabled: prevent extra popup after registration

    // _showcounsellorfeedbackDialogOnce(); // Disabled: prevent extra popup after registration



    DateTime now = DateTime.now();

    int daysToSaturday = (DateTime.saturday - now.weekday) % 7;

    nextSaturday = now.add(Duration(days: daysToSaturday));

    // nextSaturday = now.add(Duration(days: daysToSaturday));

    daysLeft = nextSaturday.difference(now).inDays;

//         int daysToSunday = (DateTime.sunday - now.weekday) % 7;

// nextSunday = now.add(Duration(days: daysToSunday));

  }



  void _checkVersion() async {

    try {

      final newVersion = NewVersion(androidId: 'com.careergroup.careerapp');

      if (mounted) {

        await newVersion.showAlertIfNecessary(context: context);

      }

    } catch (e) {

      print('Unable to check app version: $e');

    }

  }



  // New method to get logged in user ID

  Future<int> _getLoggedInUserId() async {

    try {

      SharedPreferences prefs = await SharedPreferences.getInstance();



      dynamic userId = prefs.getInt('session_user_id');



      userId ??= prefs.getInt('user_id');



      userId ??= prefs.getInt('id');



      if (userId == null) {

        String? userJson = prefs.getString('userData');

        if (userJson != null) {

          try {

            Map<String, dynamic> userData = jsonDecode(userJson);

            dynamic idFromJson = userData['id'] ?? userData['user_id'];



            if (idFromJson is String) {

              userId = int.tryParse(idFromJson) ?? 1421;

            } else if (idFromJson is int) {

              userId = idFromJson;

            } else {

              userId = 1421;

            }

          } catch (e) {

            print("Error parsing userData JSON: $e");

            userId = 1421;

          }

        } else {

          userId = 1421;

        }

      }



      print("Logged in user ID: $userId");

      return userId as int;

    } catch (e) {

      print("Error getting logged in user ID: $e");

      return 2;

    }

  }



  // New method to send tracking data when dialog is closed

  Future<void> _sendDialogCloseTracking() async {

    try {

      int loggedInUserId = await _getLoggedInUserId();



      // Create the data to send

      Map<String, dynamic> postData = {

        'user_id': loggedInUserId,

        'action': 'dialog_closed',

        'dialog_type': 'apply_now_last_date',

        'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),

      };



      print("Sending dialog close tracking: $postData");



      // Send using postMethodWithFiles (even though it's not a file upload, it works for JSON too)

      var response = await ApiService.postMethod3(

        '/addInPass',

        json.encode(postData),

      );



      print("Tracking response: $response");

    } catch (e) {

      print("Error sending dialog close tracking: $e");

    }

  }



  getSlider() async {

    try {

      var res = await ApiService.getMethod("/getHomeAds");

      data4 = jsonDecode(res.body);

      images.clear();

      for (var element in data4) {

        images.add("${ApiService.websiteUrl2}includes/upload/sliders/" +

            element["slider_image"]);

      }

      print(data4);

      // _showMyDialog();

      if (userId.isEmpty) {

        Future.delayed(Duration.zero, () {

          if (mounted) {

            _showMyDialog();

          }

        });

      }



      if (mounted) {

        setState(() {});

      }

    } catch (e) {

      print("Error loading feed sliders: $e");

    }

  }



  getShortVideos(int pageNumber) async {

    var res2 =

        await ApiService.getMethod("/getHomeShortVideos?page=$pageNumber");

    setState(() {

      if (List.from(jsonDecode(res2.body)['data'])

          .map((item) => ShortItem.fromJson(item))

          .toList()

          .isNotEmpty) {

        shortsData!.addAll(List.from(jsonDecode(res2.body)['data'])

            .map((item) => ShortItem.fromJson(item))

            .toList());

      }



      if (shortsData!.isEmpty) {

      } else {

        shortsModel = ShortsModel(

            data: shortsData,

            response: jsonDecode(res2.body)['response'],

            status: jsonDecode(res2.body)['status']);

      }

    });

  }



  getData(int pageNumber) async {

    if (!mounted) return;

    setState(() {

      isLoading = true;

    });

    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    var res2 = await ApiService.getMethod("/getPostsV2?page=$pageNumber");

    if (!mounted) return;

    // print("Response cjhkdcujkdvkf: " + res2.body);



    if (List.from(jsonDecode(res2.body)['data'])

        .map((item) => FeedItem.fromJson(item))

        .toList()

        .isNotEmpty) {

      data!.addAll(List.from(jsonDecode(res2.body)['data'])

          .map((item) => FeedItem.fromJson(item))

          .toList());



      setState(() {

        homeData = FeedModel(

            data: data,

            response: jsonDecode(res2.body)['response'],

            status: jsonDecode(res2.body)['status']);

        isLoading = false;

      });

    } else {

      if (!mounted) return;

      setState(() {

        message = "No Feed Found";

      });

    }

  }



  getHomePageFilters() async {

    try {

      var res = await ApiService.getMethod("/getHomePageFilters");

      print("Status Code: ${res.statusCode}");

      dynamic d = jsonDecode(res.body);

      print("Response: $d");

    } catch (e) {

      print("API Error: $e");

    }

  }



  getUserData() async {

    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('userData') && prefs.getString('userData') != '') {

      userData = json.decode(prefs.getString('userData')!);

      if (userData["user_name"] != '') {

        userName = userData["user_name"];

        userId = userData["user_id"];

      }

      setState(() {});

    }

  }



  // Updated _showMyDialog method with close button tracking

  _showMyDialog() async {

    return showDialog<void>(

      context: context,

      barrierDismissible: true,

      builder: (BuildContext context) {

        return AlertDialog(

          title: Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              FadeTransition(

                opacity: _controller2,

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      'Apply Now Last Date: ${DateFormat('dd MMM yyyy').format(nextSaturday)}  ( $daysLeft days left )',

                      style: const TextStyle(fontSize: 8, color: Colors.red),

                    ),

                  ],

                ),

              ),

              GestureDetector(

                onTap: () async {

                  // Send tracking data when close button is clicked

                  await _sendDialogCloseTracking();

                  Navigator.of(context).pop();

                },

                child: const Icon(Icons.close),

              ),

            ],

          ),

          contentPadding: EdgeInsets.zero,

          content: const SizedBox(

            width: 550,

            height: 450,

            child: WebviewWidget(

              url:

                  "https://www.careerdefenceschool.com/admission/register_popup.php",

            ),

          ),

          actions: const <Widget>[

            // TextButton(

            //   child: const Text('Close'),

            //   onPressed: () {

            //     Navigator.of(context).pop();

            //   },

            // ),

          ],

        );

      },

    );

  }



  @override

  Widget build(BuildContext context) {

    Size deviceSize = MediaQuery.of(context).size;

    return Container(

      color: const Color(0xffF8F8FA),

      height: double.infinity,

      child: SizedBox(

        height: 60.h,

        child: LazyLoadScrollView(

          isLoading: isLoading,

          scrollOffset: 600,

          onEndOfPage: () {

            print("print page end");

            _scrollListener();

          },

          child: ListView(

            // controller: controller,

            scrollDirection: Axis.vertical,

            primary: false,

            children: [

              // postFeedWidget(),



              if (images.isNotEmpty)

                Container(

                  height: 200,

                  padding: const EdgeInsets.all(10.0),

                  child: Swiper(

                    itemBuilder: (BuildContext context, int index) {

                      return Column(

                        children: <Widget>[

                          GestureDetector(

                            onTap: () {

                              if (data4[index]["code"] != null) {

                                launch(data4[index]["code"]);

                                // Navigator.of(context).pushNamed(

                                //     Youtubevideo.routeName,

                                //     arguments: data4[index]["code"]);

                              }

                            },

                            child: Container(

                              height: 180,

                              width: double.infinity,

                              decoration: BoxDecoration(

                                  borderRadius: const BorderRadius.only(

                                      topLeft: Radius.circular(10.0),

                                      topRight: Radius.circular(10.0),

                                      bottomLeft: Radius.circular(10.0),

                                      bottomRight: Radius.circular(10.0)),

                                  image: DecorationImage(

                                      image: NetworkImage(images[index]),

                                      fit: BoxFit.fill)),

                            ),

                          ),

                        ],

                      );

                    },

                    itemWidth: deviceSize.width - 40,

                    autoplay: true,

                    itemCount: images.length,

                    layout: SwiperLayout.STACK,

                  ),

                ),

              feedListWidget(),

              Visibility(

                  visible: isLoading,

                  child: Container(

                    width: 10.w,

                    alignment: Alignment.bottomCenter,

                    child: CircularProgressIndicator(

                      color: Theme.of(context).primaryColor,

                    ),

                  ))

            ],

          ),

        ),

      ),

    );

  }



  Widget shortsListWidget2() {

    return shortsModel.data!.isEmpty

        ? const SizedBox()

        : Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const Padding(

                padding: EdgeInsets.symmetric(horizontal: 10),

                child: Text(

                  "Short Videos",

                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

                ),

              ),

              const SizedBox(height: 10),

              SizedBox(

                height: 60, // Fixed height

                child: ListView.builder(

                  scrollDirection: Axis.horizontal,

                  itemCount: shortsModel.data!.length,

                  padding: const EdgeInsets.symmetric(horizontal: 10),

                  itemBuilder: (context, index) {

                    return Padding(

                      padding: const EdgeInsets.symmetric(horizontal: 8),

                      child: ClipOval(

                        child: Container(

                          width: 60, // Fixed width

                          height: 60, // Fixed height

                          decoration: BoxDecoration(

                            shape: BoxShape.circle, // Ensures circular shape

                            border: Border.all(

                                color: Colors.grey.shade300, width: 2),

                            boxShadow: const [

                              BoxShadow(

                                color: Colors.black26,

                                blurRadius: 4,

                                spreadRadius: 1,

                              ),

                            ],

                          ),

                          child: shortsListItem2(

                            item: shortsModel.data![index],

                            index: index,

                          ),

                        ),

                      ),

                    );

                  },

                ),

              ),

            ],

          );

  }



  Widget postFeedWidget() {

    return Container(

      width: double.infinity,

      height: 18.h,

      padding: EdgeInsets.symmetric(horizontal: 2.h),

      decoration: BoxDecoration(

          color: Colors.white,

          border: Border.all(

            color: Colors.white,

          ),

          borderRadius: const BorderRadius.only(

              bottomLeft: Radius.circular(20),

              bottomRight: Radius.circular(02))),

      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Row(

            mainAxisAlignment: MainAxisAlignment.center,

            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              CircleAvatar(

                radius: 3.5.w,

                backgroundImage: const AssetImage(

                  "assets/profileimg.png",

                ),

              ),

              SizedBox(

                width: 5.w,

              ),

              Container(

                width: 55.w,

                padding: EdgeInsets.only(bottom: 1.h),

                child: TextField(

                  keyboardType: TextInputType.multiline,

                  maxLength: null,

                  maxLines: null,

                  style: TextStyle(

                      fontSize: 10.sp, height: 2.0, color: Colors.black),

                  decoration: const InputDecoration.collapsed(

                    hintText: 'Type your message/post here',

                  ),

                ),

              ),

              SizedBox(

                width: 10.w,

              ),

              IconButton(

                  onPressed: () {},

                  icon: Icon(

                    Icons.emoji_emotions_rounded,

                    color: Colors.yellow.shade700,

                  ))

            ],

          ),

          SizedBox(

            height: 2.h,

          ),

          Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              addFeedButtonWidget(

                  btnIcon: Icons.camera_alt,

                  iconColor: Colors.green,

                  text: 'Photos',

                  ontap: () {}),

              addFeedButtonWidget(

                  btnIcon: Icons.video_camera_front,

                  iconColor: Colors.red,

                  text: 'Videos',

                  ontap: () {}),

              addFeedButtonWidget(

                  btnIcon: Icons.add_location_alt,

                  iconColor: Colors.blue,

                  text: 'Location',

                  ontap: () {}),

            ],

          ),

        ],

      ),

    );

  }



  Widget shortsListWidget() {

    return shortsModel.data!.isEmpty

        ? const SizedBox()

        : Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const Text("  Short Videos"),

              Container(

                margin: EdgeInsets.symmetric(vertical: 1.5.h),

                height: 25.h,

                child: NotificationListener<OverscrollNotification>(

                  // Suppress OverscrollNotification events that escape from the inner scrollable

                  onNotification: (notification) =>

                      notification.metrics.axisDirection != AxisDirection.down,

                  child: ListView.builder(

                    scrollDirection: Axis.horizontal,

                    shrinkWrap: true,

                    itemCount: shortsModel.data!.length,

                    padding: EdgeInsets.symmetric(horizontal: .5.h),

                    itemBuilder: ((context, index) {

                      return shortsListItem(

                          item: shortsModel.data![index], index: index);

                    }),

                  ),

                ),

              )

            ],

          );

  }



  Widget storyListWidget() {

    return Container(

      margin: EdgeInsets.symmetric(vertical: 1.5.h),

      height: 13.h,

      child: ListView.builder(

        scrollDirection: Axis.horizontal,

        shrinkWrap: true,

        itemCount: 10,

        padding: EdgeInsets.symmetric(horizontal: 1.h),

        itemBuilder: ((context, index) {

          if (index == 0) {

            return Column(

              children: [

                Stack(

                  children: [

                    Container(

                      alignment: Alignment.center,

                      padding: EdgeInsets.symmetric(horizontal: 1.2.h),

                      child: CircleAvatar(

                        radius: 9.w,

                        backgroundImage: const AssetImage(

                          "assets/profileimg.png",

                        ),

                      ),

                    ),

                    Container(

                      width: 22.5.w,

                      height: 20.w,

                      alignment: Alignment.bottomCenter,

                      child: Icon(

                        Icons.add_circle,

                        size: 2.5.h,

                        color: Colors.blue,

                      ),

                    )

                  ],

                ),

                SizedBox(height: .8.h),

                Text("Carear Defence",

                    style: TextStyle(

                      fontSize: 9.sp,

                      color: Colors.grey.shade800,

                    ))

              ],

            );

          }

          return Padding(

            padding: EdgeInsets.symmetric(horizontal: 1.2.h),

            child: Column(

              children: [

                CircleAvatar(

                  radius: 9.w,

                  backgroundColor: Colors.blue,

                  child: CircleAvatar(

                    radius: 8.5.w,

                    backgroundColor: Colors.blue,

                    backgroundImage: const AssetImage(

                      "assets/profileimg.png",

                    ),

                  ),

                ),

                SizedBox(height: 1.8.h),

                Text('User',

                    style: TextStyle(

                      fontSize: 9.sp,

                      color: Colors.grey.shade800,

                    ))

              ],

            ),

          );

        }),

      ),

    );

  }



  Widget dataHomePage2() {

    return Scaffold(

      appBar: AppBar(

        title: const Text('Card Grid UI'),

        centerTitle: true,

      ),

      body: Padding(

        padding: const EdgeInsets.all(10.0),

        child: GridView.builder(

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(

            crossAxisCount: 2, // Adjust the number of columns

            crossAxisSpacing: 10,

            mainAxisSpacing: 10,

            childAspectRatio: 3 / 2, // Adjust aspect ratio

          ),

          itemCount: 6, // Number of cards

          itemBuilder: (context, index) {

            return Card(

              elevation: 4,

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(12),

              ),

              child: Center(

                child: Text(

                  'Card ${index + 1}',

                  style: const TextStyle(

                      fontSize: 18, fontWeight: FontWeight.bold),

                ),

              ),

            );

          },

        ),

      ),

    );

  }



  Widget feedListWidget() {

    // "{"id":"460","title":"PTM","body":"⭐⭐Candidate in NCC Dress On PTM⭐⭐\r\n\*Career Defence School Ambala\*\r\n","post_category_name":"CDS Ambala","image":"https://www.careerinstitute.co/myapp/includes/upload/social/image_202209021847553013.jpeg","media_type":"image","createdBy":"0","updatedAt":"2022-09-02 06:17:55","createdAt":"2022-09-02 18:47:55","comments":[],"likesCount":{"total_likes":"1"}}"



    if (homeData.data!.isNotEmpty) {

      // homeData.data!.insert(

      //     0,

      //     FeedItem(

      //         id: "460",

      //         title: "PTM",

      //         body:

      //             "⭐⭐Candidate in NCC Dress On PTM⭐⭐\r\n\*Career Defence School Ambala\*\r\n",

      //         postCategoryName: "CDS Ambala",

      //         image: [

      //           "https://www.careerinstitute.co/myapp/includes/upload/social/image_202209021847553013.jpeg",

      //           "https://images.wallpapersden.com/image/download/purple-sunrise-4k-vaporwave_bGplZmiUmZqaraWkpJRmbmdlrWZlbWU.jpg"

      //         ],

      //         mediaType: "image",

      //         createdBy: "0",

      //         updatedAt: "2022-09-02 06:17:55",

      //         createdAt: "2022-09-02 18:47:55",

      //         comments: [],

      //         likesCount: LikesCount(totalLikes: "1")));

      homeData.data!.insert(2, FeedItem());

    }



    return homeData.data!.isEmpty

        ? SizedBox(height: 50.h, child: Center(child: Text(message)))

        : ListView.builder(

            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),

            primary: false,

            scrollDirection: Axis.vertical,

            itemCount: homeData.data!.length,

            itemBuilder: (context, index) {

              if (index == 2) {

                return shortsListWidget();

              } else if (index == 3) {

                return shortsListWidget2();

              }

              return FeedWidget(

                feed: homeData.data![index],

                notifyParent: refresh,

                usedId: userId,

                userName: userName,

              );

            });

  }



  Widget addFeedButtonWidget(

      {required String text,

      required IconData btnIcon,

      required Color iconColor,

      required Function ontap}) {

    return TextButton.icon(

        style: TextButton.styleFrom(

            backgroundColor: const Color(0xffF8F8FA),

            padding: EdgeInsets.symmetric(horizontal: 2.5.h)),

        onPressed: () => ontap,

        icon: Icon(

          btnIcon,

          color: iconColor,

          size: 2.h,

        ),

        label: Text(text,

            style: TextStyle(

              fontSize: 9.sp,

              color: Colors.grey.shade800,

            )));

  }



  Widget shortsListItem({required ShortItem item, required int index}) {

    return InkWell(

      onTap: () {

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (context) => SwipeShortsScreen(

              userId: userId,

              userName: userName,

              shortsList: shortsModel.data!,

              index: index,

            ),

          ),

        );

      },

      child: Container(

        width: 29.w,

        margin: EdgeInsets.symmetric(horizontal: .5.h),

        child: Stack(

          children: [

            SizedBox(

              height: 25.h,

              child: Image.network(

                item.image!,

                fit: BoxFit.cover,

              ),

            ),

            Container(

              height: 25.h,

              width: double.infinity,

              color: Colors.black.withOpacity(0.4),

            ),

            Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisAlignment: MainAxisAlignment.end,

              children: [

                Padding(

                  padding: EdgeInsets.symmetric(horizontal: 1.w),

                  child: Text(

                    item.title ?? '',

                    style: const TextStyle(

                      color: Colors.white,

                      fontWeight: FontWeight.w500,

                    ),

                  ),

                ),

                Padding(

                  padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),

                  child: Row(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [

                      Text(

                        '${item.likesCount?.totalLikes ?? 0} likes',

                        style: const TextStyle(

                          color: Colors.white,

                          fontWeight: FontWeight.w500,

                        ),

                      ),

                      IconButton(

                        onPressed: () {

                          Share.share(

                            item.image ?? '',

                            subject: item.title ?? 'Check out this video!',

                          );

                        },

                        icon: const Icon(Icons.share, color: Colors.white),

                        tooltip: 'Share',

                      ),

                    ],

                  ),

                ),

              ],

            ),

          ],

        ),

      ),

    );

  }



  Widget shortsListItem2({required ShortItem item, required int index}) {

    return InkWell(

      onTap: (() {

        Navigator.push(

            context,

            MaterialPageRoute(

                builder: ((context) => SwipeShortsScreen(

                      userId: userId,

                      userName: userName,

                      shortsList: shortsModel.data!,

                      index: index,

                    ))));

      }),

      child: Container(

          width: 29.w,

          color: Colors.black,

          margin: EdgeInsets.symmetric(horizontal: .5.h),

          child: Stack(children: [

            SizedBox(

              height: 25.h,

              child: Image.network(

                item.image!,

                fit: BoxFit.cover,

              ),

            ),

            Container(

              height: 25.h,

              width: double.infinity,

              color: Colors.black.withOpacity(0.4),

            ),

            Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisAlignment: MainAxisAlignment.end,

              children: [

                Padding(

                  padding: EdgeInsets.symmetric(

                    horizontal: 1.w,

                  ),

                  // child: Text(

                  //   item.title!,

                  //   style: const TextStyle(

                  //       color: Colors.white, fontWeight: FontWeight.w500),

                  // )

                ),

                // Padding(

                //     padding:

                //         EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),

                //     child: Text(

                //       '${item.likesCount!.totalLikes} likes',

                //       style: const TextStyle(

                //           color: Colors.white, fontWeight: FontWeight.w500),

                //     )),

                //  Padding(

                // padding:

                //     EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),

                // child: Text(

                //   '${item.likesCount!.totalLikes} Dis-likes',

                //   style: const TextStyle(

                //       color: Colors.white, fontWeight: FontWeight.w500),

                // )),

              ],

            ),

          ])),

    );

  }



  void _scrollListener() {

    // controller.addListener(() {

    //   if (controller.position.extentAfter <= 0) {

    pageNo++;

    getData(pageNo);

    // }

    // });

  }



  refresh() {

    setState(() {

      getData(pageNo);

    });

  }



  _showServiceFeedbackDialogOnce() async {

    final prefs = await SharedPreferences.getInstance();

    bool alreadyShown = prefs.getBool('serviceFeedbackDialogShown') ?? false;



    if (!alreadyShown) {

      await prefs.setBool('serviceFeedbackDialogShown', true);



      // Show the dialog

      showDialog<void>(

        context: context,

        barrierDismissible: false,

        builder: (BuildContext context) {

          return const AlertDialog(

            title: Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              // children: [

              //   Text('School Feedback Form',

              //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),

              //   GestureDetector(

              //       onTap: () {

              //         Navigator.of(context).pop();

              //       },

              //       child: Icon(Icons.close))

              // ],

            ),

            contentPadding: EdgeInsets.zero,

            content: SizedBox(

                width: 900,

                height: 500,

                child: WebviewWidget(

                  url:

                      "https://careerdefenceacademy.com/HomeController/service_feedback_form",

                )),

          );

        },

      );

    }

  }



  _showcounsellorfeedbackDialogOnce() async {

    final prefs = await SharedPreferences.getInstance();

    bool alreadyShown = prefs.getBool('counsellorFeedbackDialogShown') ?? false;



    if (!alreadyShown) {

      await prefs.setBool('counsellorFeedbackDialogShown', true);



      // Show the dialog

      showDialog<void>(

        context: context,

        barrierDismissible: false,

        builder: (BuildContext context) {

          return const AlertDialog(

            title: Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              // children: [

              //   Text('School Feedback Form',

              //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),

              //   GestureDetector(

              //       onTap: () {

              //         Navigator.of(context).pop();

              //       },

              //       child: Icon(Icons.close))

              // ],

            ),

            contentPadding: EdgeInsets.zero,

            content: SizedBox(

                width: 900000,

                height: 500,

                child: WebviewWidget(

                  url:

                      "https://careerdefenceacademy.com/HomeController/counsellor_feedback",

                )),

          );

        },

      );

    }

  }



  // @override

  // void dispose() {

  //   controller.removeListener(_scrollListener);

  //   super.dispose();

  // }

}
