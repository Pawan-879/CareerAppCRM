import 'package:flutter/material.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:careerapp/screens/paidcategory.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';

final List<String> images = [
  "${ApiService.websiteUrl}ads/banner1.jpg",
  "${ApiService.websiteUrl}ads/banner2.jpg",
];

class Allcourses extends StatefulWidget {
  static const routeName = '/allcourses';

  const Allcourses({Key? key}) : super(key: key);
  @override
  _AllcoursesState createState() => _AllcoursesState();
}

class _AllcoursesState extends State<Allcourses> {
  var data2 = [];
  var searchdata = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      dynamic data = ModalRoute.of(context)?.settings.arguments;
      searchdata = data["category_name"];
      getData(data["category_id"]);
    });
  }

  getData(categoryId) async {
    var res2 = await ApiService.getMethod(
        "/getCoursesByCategory?category_id=$categoryId");
    data2 = jsonDecode(res2.body);
    // print(data2);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Courses"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 140,
              color: Colors.black,
              padding: const EdgeInsets.all(10.0),
              child: Swiper(
                fade: 0.0,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: <Widget>[
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0)),
                            image: DecorationImage(
                                image: NetworkImage(images[index]),
                                fit: BoxFit.cover)),
                      ),
                    ],
                  );
                },
                itemCount: 2,
                scale: 0.9,
                autoplay: true,
                pagination: const SwiperPagination(),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue,
              child: Text(
                "Search Result: '$searchdata'",
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
            Expanded(
              child: data2.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: data2.length,
                      itemBuilder: (BuildContext context, int i) {
                        return _courseCard(data2[i]);
                      },
                    )
                  : const Center(
                      child: Text(
                        'No course found',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _courseCard(dynamic param) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Paidcategory.routeName, arguments: param);
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10, top: 10),
        child: Container(
          width: 230.0,
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
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15)),
                child: Image.network(
                    "${ApiService.websiteUrl}subcat-images/" + param["image"],
                    fit: BoxFit.fill),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                child: Text(
                  param["sub_cat_name"],
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("Rs." + param["mrp"],
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                child: Text(
                  "Rs." + param["our_price"],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
