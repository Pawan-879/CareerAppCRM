import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:careerapp/services/api_services.dart';
import 'package:careerapp/widgets/categories_heading.dart';
import 'package:careerapp/size_config.dart';
import 'package:careerapp/screens/youtube_player.dart';

class Youtube extends StatefulWidget {
  const Youtube({Key? key}) : super(key: key);
  static const routeName = '/youtube';

  @override
  _YoutubeState createState() => _YoutubeState();
}

class _YoutubeState extends State<Youtube> {
  var alldata = [],
      data = [],
      data2 = [],
      data3 = [],
      data4 = [],
      data5 = [],
      data6 = [],
      data7 = [],
      data8 = [],
      data9 = [],
      data10 = [],
      data11 = [],
      data12 = [];
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    //sainik school 7
    var res = await ApiService.getMethod("/getVideosCatById");
    alldata = jsonDecode(res.body);

    for (var i = 0; i < alldata.length; i++) {
      if (alldata[i]["category_id"] == "7") {
        data.add(alldata[i]);
      } else if (alldata[i]["category_id"] == "6") {
        data2.add(alldata[i]);
      } else if (alldata[i]["category_id"] == "4") {
        data3.add(alldata[i]);
      } else if (alldata[i]["category_id"] == "9") {
        data4.add(alldata[i]);
      } else if (alldata[i]["category_id"] == "2") {
        data5.add(alldata[i]);
      } else if (alldata[i]["category_id"] == "3") {
        data6.add(alldata[i]);
      } else if (alldata[i]["category_id"] == "5") {
        data7.add(alldata[i]);
      } else if (alldata[i]["category_id"] == "14") {
        data8.add(alldata[i]);
      } else if (alldata[i]["category_id"] == "16") {
        data9.add(alldata[i]);
      } else if (alldata[i]["category_id"] == "17") {
        data10.add(alldata[i]);
      } else if (alldata[i]["category_id"] == "18") {
        data11.add(alldata[i]);
      } else if (alldata[i]["category_id"] == "19") {
        data12.add(alldata[i]);
      }
    }
    //military school
    // var res2 = await ApiService.getMethod("/getVideosCatById?id=6");
    // data2 = jsonDecode(res2.body);
    // //rimc dehradun
    // var res3 = await ApiService.getMethod("/getVideosCatById?id=4");
    // data3 = jsonDecode(res3.body);
    // //Central Hindu School
    // var res4 = await ApiService.getMethod("/getVideosCatById?id=9");
    // data4 = jsonDecode(res4.body);
    // //rai sport school
    // var res5 = await ApiService.getMethod("/getVideosCatById?id=2");
    // data5 = jsonDecode(res5.body);
    // //gurukul kurukshetra
    // var res6 = await ApiService.getMethod("/getVideosCatById?id=3");
    // data6 = jsonDecode(res6.body);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Youtube Videos",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F4),
              ),
              child: Column(children: [
                const SizedBox(height: 20),
                const CategoryHeading(title: "Sainik School"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 22 * SizeConfig.heightMultiplier!,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: _courseCard(
                            data[index],
                            data[index]["video_name"],
                            data[index]["video_image"]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const CategoryHeading(title: "Military School"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 22 * SizeConfig.heightMultiplier!,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data2.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: _courseCard(
                            data2[index],
                            data2[index]["video_name"],
                            data2[index]["video_image"]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const CategoryHeading(title: "Rimc Dehradun"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 22 * SizeConfig.heightMultiplier!,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data3.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: _courseCard(
                            data3[index],
                            data3[index]["video_name"],
                            data3[index]["video_image"]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const CategoryHeading(title: "Central Hindu School"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 22 * SizeConfig.heightMultiplier!,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data4.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: _courseCard(
                            data4[index],
                            data4[index]["video_name"],
                            data4[index]["video_image"]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const CategoryHeading(title: "Rai Sports School"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 22 * SizeConfig.heightMultiplier!,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data5.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: _courseCard(
                            data5[index],
                            data5[index]["video_name"],
                            data5[index]["video_image"]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const CategoryHeading(title: "Gurukul Kurukshetra"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 22 * SizeConfig.heightMultiplier!,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data6.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: _courseCard(
                            data6[index],
                            data6[index]["video_name"],
                            data6[index]["video_image"]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const CategoryHeading(title: "APS DAGSHAI"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 22 * SizeConfig.heightMultiplier!,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data7.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: _courseCard(
                            data7[index],
                            data7[index]["video_name"],
                            data7[index]["video_image"]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const CategoryHeading(title: "OAK GROVE SCHOOL"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 22 * SizeConfig.heightMultiplier!,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data8.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: _courseCard(
                            data8[index],
                            data8[index]["video_name"],
                            data8[index]["video_image"]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const CategoryHeading(title: "MILITARY NURSING SERVICES"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 22 * SizeConfig.heightMultiplier!,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data9.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: _courseCard(
                            data9[index],
                            data9[index]["video_name"],
                            data9[index]["video_image"]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const CategoryHeading(title: "NTSE For Class 10"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 22 * SizeConfig.heightMultiplier!,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data10.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: _courseCard(
                            data10[index],
                            data10[index]["video_name"],
                            data10[index]["video_image"]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const CategoryHeading(title: "NDA For Class 12"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 22 * SizeConfig.heightMultiplier!,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data11.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: _courseCard(
                            data11[index],
                            data11[index]["video_name"],
                            data11[index]["video_image"]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const CategoryHeading(title: "JOIN INDIAN ARMY"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 22 * SizeConfig.heightMultiplier!,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data12.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: _courseCard(
                            data12[index],
                            data12[index]["video_name"],
                            data12[index]["video_image"]),
                      );
                    },
                  ),
                )
              ]))),
    );
  }

  _courseCard(dynamic param, String title, String img) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Youtubevideo.routeName, arguments: param["video_url"]);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
        child: Container(
          width: 280.0,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  offset: const Offset(0, 2),
                  blurRadius: 8.0),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: <Widget>[
                  Image.network(
                      "${ApiService.websiteUrl2}includes/upload/video_images/$img",
                      width: double.infinity,
                      fit: BoxFit.fill, loadingBuilder: (BuildContext context,
                          Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  }),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 0, 0, 0),
                            Color.fromARGB(0, 0, 0, 0)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
