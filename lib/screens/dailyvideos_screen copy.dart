// import 'package:flutter/material.dart';
// import 'package:careerapp/screens/dailyvideos_player.dart';
// import 'package:careerapp/screens/login.dart';
// import 'package:careerapp/services/api_services.dart';
// import 'dart:convert';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class DailyVideos extends StatefulWidget {
//   const DailyVideos({Key? key}) : super(key: key);
//   static const routeName = '/daily_videos';

//   @override
//   _DailyVideosState createState() => _DailyVideosState();
// }

// class _DailyVideosState extends State<DailyVideos> {
//   var section_id = "";
//   var data4 = [], data4_copy = [], data5 = [], data5_copy = [];
//   var userData, user_id = "";
//   var categories = [];
//   final List _selecteCategorys = [];

//   @override
//   void initState() {
//     super.initState();
//     getUserData();
//     getCategories();
//   }

//   getUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (prefs.containsKey('userData')) {
//       userData = json.decode(prefs.getString('userData')!);
//       user_id = userData["user_id"];
//       getData2(user_id);
//       getData3(user_id);
//       setState(() {});
//     } else {
//       getData();
//     }
//   }

//   getData() async {
//     var res = await ApiService.getMethod("/getDailyVideos");
//     data4 = jsonDecode(res.body);
//     data4_copy = jsonDecode(res.body);
//     setState(() {});
//   }

//   myfilter() {
//     data4_copy = data4.where((element) => _selecteCategorys.contains(element["category_id"])).toList();
//     data5_copy = data5.where((element) => _selecteCategorys.contains(element["category_id"])).toList();
//     setState(() {});
//   }

//   getCategories() async {
//     var res = await ApiService.getMethod("/getAppCategories");
//     categories = json.decode(res.body)["detail"];
//     setState(() {});
//   }

//   getData2(userId2) async {
//     var res = await ApiService.getMethod("/getDailyVideos?user_id=$userId2&type=unwatched");
//     data4 = jsonDecode(res.body);
//     data4_copy = jsonDecode(res.body);
//     setState(() {});
//   }

//   getData3(userId2) async {
//     var res = await ApiService.getMethod("/getDailyVideos?user_id=$userId2&type=watched");
//     data5 = jsonDecode(res.body);
//     data5_copy = jsonDecode(res.body);
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         backgroundColor: Colors.grey[100],
//         appBar: AppBar(
//           elevation: 4,
//           backgroundColor: Colors.white,
//           title: const Text("Daily Videos", style: TextStyle(color: Colors.black)),
//           centerTitle: true,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//           ),
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(60),
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               decoration: BoxDecoration(
//                 color: Colors.blue[800],
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: const TabBar(
//                 isScrollable: false,
//                 indicator: BoxDecoration(
//                   borderRadius: BorderRadius.all(Radius.circular(15)),
//                   color: Colors.white,
//                 ),
//                 labelColor: Colors.blue,
//                 unselectedLabelColor: Colors.white,
//                 labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 tabs: [
//                   Tab(text: 'Unwatched Videos'),
//                   Tab(text: 'Watched Videos'),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildVideoList(data4_copy, 'unwatched'),
//             user_id.isEmpty
//                 ? Center(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue[800],
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//                       ),
//                       onPressed: () {
//                         Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
//                       },
//                       child: const Text("Please Login", style: TextStyle(fontSize: 16, color: Colors.white)),
//                     ),
//                   )
//                 : _buildVideoList(data5_copy, 'watched'),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton.extended(
//           onPressed: popup,
//           label: const Text('Filter'),
//           icon: const Icon(FontAwesomeIcons.filter, size: 15),
//           backgroundColor: Colors.red[700],
//         ),
//       ),
//     );
//   }

//   Widget _buildVideoList(List data, String type) {
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       itemCount: data.length,
//       itemBuilder: (context, index) {
//         var video = data[index];
//         return _courseCard(
//           video["id"],
//           video["video_link"],
//           video["quote_name"],
//           video["quote_image"],
//           video,
//           type,
//         );
//       },
//     );
//   }

//   Widget _courseCard(String vId, String videoId, String title, String image, dynamic data, String type) {
//     return GestureDetector(
//       onTap: () {
//         dynamic data51 = {
//           'type': type,
//           'video_id': videoId,
//           'description': data["description"],
//           'title': title,
//           'id': vId,
//         };
//         Navigator.of(context).pushNamed(DailyVideosPlayer.routeName, arguments: data51);
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8, offset: const Offset(2, 2))],
//         ),
//         child: Column(
//           children: [
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//               child: Image.network(
//                 ApiService.websiteUrl2 + "includes/upload/quotes/" + image,
//                 width: double.infinity,
//                 height: 180,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             ListTile(
//               title: Text(
//                 title,
//                 style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
//                 maxLines: 2,
//               ),
//               trailing: Icon(Icons.play_circle_fill, color: Colors.blue[800], size: 30),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void popup() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Select Categories'),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           content: StatefulBuilder(
//             builder: (context, setState) {
//               return SizedBox(
//                 width: MediaQuery.of(context).size.width,
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: categories.length,
//                   itemBuilder: (context, index) {
//                     return CheckboxListTile(
//                       activeColor: Colors.blue[800],
//                       value: _selecteCategorys.contains(categories[index]['id']),
//                       onChanged: (bool? selected) {
//                         setState(() {
//                           selected == true
//                               ? _selecteCategorys.add(categories[index]['id'])
//                               : _selecteCategorys.remove(categories[index]['id']);
//                           myfilter();
//                         });
//                       },
//                       title: Text(categories[index]['category_name']),
//                     );
//                   },
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyVideos extends StatelessWidget {
  const DailyVideos({Key? key}) : super(key: key);
  static const routeName = '/daily_videos';

  final List<Map<String, String>> videos = const [
    {
      "title": "Video 1",
      "url": "https://youtu.be/-rsQnyq_yOY?feature=shared",
      "id": "-rsQnyq_yOY"
    },
    {
      "title": "Video 2",
      "url": "https://www.youtube.com/watch?v=dj56SeePaUA",
      "id": "dj56SeePaUA"
    },
    {
      "title": "Video 3",
      "url": "https://www.youtube.com/watch?v=U1X61QbotLE&t=10s",
      "id": "U1X61QbotLE"
    },
    {
      "title": "Video 4",
      "url": "https://www.youtube.com/watch?v=WCOiUAJvfzU",
      "id": "WCOiUAJvfzU"
    },
    {
      "title": "Video 5",
      "url": "https://www.youtube.com/watch?v=hFmkTLHjDtg",
      "id": "hFmkTLHjDtg"
    },
    {
      "title": "Video 6",
      "url": "https://www.youtube.com/watch?v=WCOiUAJvfzU&t=26s",
      "id": "WCOiUAJvfzU"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Videos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          final thumbnailUrl = "https://img.youtube.com/vi/${video['id']}/0.jpg";

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () async {
                final uri = Uri.parse(video['url']!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      thumbnailUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        return progress == null
                            ? child
                            : const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            video['title']!,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Icon(FontAwesomeIcons.youtube, color: Colors.red[700]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

