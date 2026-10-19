import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:careerapp/screens/product_detail.dart';

class BuybooksScreen extends StatefulWidget {
  static const routeName = '/buybooks';

  const BuybooksScreen({Key? key}) : super(key: key);

  @override
  _BuybooksScreenState createState() => _BuybooksScreenState();
}

class _BuybooksScreenState extends State<BuybooksScreen> {
  var data2 = [];
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    var res2 = await ApiService.getMethod("/getProducts?type=Books");
    data2 = jsonDecode(res2.body);
    // print(data2);
    setState(() {
      isLoading = false;
    });
  }

  showCircularProgress() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Books 📚"),
      ),
      body: isLoading == true
          ? showCircularProgress()
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.5,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      _courseCard,
                      childCount: data2.length,
                    ),
                  ),
                ]),
    );
  }

  Widget _courseCard(BuildContext context, int index) {
    dynamic param = data2[index];
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Productdetail.routeName, arguments: param);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
        child: Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
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
                  "${ApiService.websiteUrl}products/" + param["product_image"],
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
                child: Text(
                  param["product_name"],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("Rs." + param["mrp"] + "/-",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                child: Text(
                  "Rs." + param["our_price"] + "/-",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
