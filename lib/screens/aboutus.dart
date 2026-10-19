import 'package:flutter/material.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:careerapp/services/api_services.dart';

class Aboutus extends StatefulWidget {
  const Aboutus({Key? key}) : super(key: key);

  @override
  _AboutusState createState() => _AboutusState();
}

class _AboutusState extends State<Aboutus> {
  final String image = "";

  final List<String> images = [
    "${ApiService.websiteUrl}ads/school1.jpg",
    "${ApiService.websiteUrl}ads/school2.jpg",
    "${ApiService.websiteUrl}ads/school3.jpg",
    "${ApiService.websiteUrl}ads/school4.jpg",
    "${ApiService.websiteUrl}ads/school5.jpg",
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "About Us",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
         backgroundColor: Colors.blue[500],
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 260,
                  padding: const EdgeInsets.all(0.0),
                  child: Swiper(
                    fade: 0.0,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: <Widget>[
                          Container(
                            height: 240,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(images[index]),
                                    fit: BoxFit.cover)),
                          ),
                        ],
                      );
                    },
                    itemCount: 4,
                    scale: 0.9,
                    autoplay: true,
                    pagination: const SwiperPagination(),
                  ),
                ),
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
                        vertical: 20.0, horizontal: 20.0),
                    child: const Row(
                      children: <Widget>[
                        Icon(
                          Icons.home,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          "Career Defence School",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "About CDS",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text(
                    "Career Defense School makes progress toward greatness in instructing and getting the excellance, offering an outstanding training in an assorted network. We create visionary, well-spoken and moral people prepared to accomplish their maximum capacity in administration and throughout everyday life.",
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text(
                    "Education that makes a Child Curious, Sympathetic, Independent, Socially alarm and Great individual, simultaneously, it shows him fundamental abilities and qualities.",
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text(
                    "Besides imparting education in accordance with the education policy of India and tha Army Welfare Education Society, our aim is to provide opportunities to the students to develop fully. They should strive for academic exellence, should be honest and upright, should have confidence in themselves and above all, have pride in their Country. They should love their country and ceaselessly strive for its betterment. It is then appropriate that tha school's motto is 'DEDICATION TO THE NATION'.",
                    textAlign: TextAlign.justify,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
