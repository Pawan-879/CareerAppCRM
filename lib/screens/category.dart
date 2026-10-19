import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:careerapp/screens/mycourse_details_screen.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Category extends StatefulWidget {
  static const routeName = '/category';

  const Category({Key? key}) : super(key: key);
  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  late Razorpay _razorpay;
  var data2 = [];
  var userId = "";
  var userName = "";
  var userEmail = "";
  var userPhone = "";
  var userData;
  dynamic subcat;
  var subcatName = "Loading...";
  var featuredImage = "placeholder.png";
  var ourPrice = "0";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      subcat = ModalRoute.of(context)?.settings.arguments;
      subcatName = subcat["sub_cat_name"];
      featuredImage = subcat["image"];
      ourPrice = subcat["our_price"];
      getData(subcat["id"]);
    });

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    getUserData();
    setState(() {});
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      userData = json.decode(prefs.getString('userData')!);
      userId = userData["user_id"];
      userName = userData["user_name"];
      userEmail = userData["user_email"];
      userPhone = userData["user_phone"];
      setState(() {});
    }
  }

  getData(subcatId) async {
    var res2 =
        await ApiService.getMethod("/getCoursesByCat?subcat_id=$subcatId");
    data2 = jsonDecode(res2.body);
    setState(() {});
  }

  void openCheckout() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      if (double.parse(ourPrice) != 0) {
        var options = {
          'key': 'rzp_live_Pcdep9U0ODwKYM',
          'amount': double.parse(ourPrice) * 100,
          'name': userName,
          'description': 'Payment',
          'prefill': {'contact': userPhone, 'email': userEmail},
          'external': {
            'wallets': ['paytm']
          }
        };

        try {
          _razorpay.open(options);
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    } else {
      Fluttertoast.showToast(msg: "Please login first", timeInSecForIosWeb: 4);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    var data = json.encode({
      'user_id': userId,
      'course_id': subcat["id"],
      'payment_id': response.paymentId
    });

    try {
      var response2 = ApiService.postMethod(
        '/coursePayment',
        data,
      );

      if (response2["status"] == "1") {
        Fluttertoast.showToast(
            msg: "Payment successfully Completed.", timeInSecForIosWeb: 10);
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: ${response.code} - ${response.message!}",
        timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: ${response.walletName!}", timeInSecForIosWeb: 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //subcatName
        title: const Text("Recorded Classes"),
        // actions: [
        //   // FlatButton(
        //   //   onPressed: () {
        //   //     openCheckout();
        //   //   },
        //   //   child: Text('BUY NOW', style: TextStyle(color: Colors.white)),
        //   // )
        // ],
      ),
      body: Column(
        children: [
          // Stack(
          //   children: <Widget>[
          //     Image.network(
          //         ApiService.websiteUrl + "subcat-images/" + featuredImage,
          //         width: double.infinity,
          //         fit: BoxFit.fill),
          //     Positioned(
          //       bottom: 0.0,
          //       left: 0.0,
          //       right: 0.0,
          //       child: Container(
          //         decoration: const BoxDecoration(
          //           gradient: LinearGradient(
          //             colors: [
          //               Color.fromARGB(255, 0, 0, 0),
          //               Color.fromARGB(0, 0, 0, 0)
          //             ],
          //             begin: Alignment.bottomCenter,
          //             end: Alignment.topCenter,
          //           ),
          //         ),
          //         padding: const EdgeInsets.symmetric(
          //             vertical: 20.0, horizontal: 10.0),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               subcatName,
          //               style: const TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 20.0,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             )
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue,
            child: const Text(
              "CONTENTS LIST ",
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: data2.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.all(2),
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
    );
  }

  _courseCard(dynamic param) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(MycourseDetailsScreen.routeName, arguments: param);
      },
      child: Card(
        elevation: 3,
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 90,
              width: 150,
              child: Stack(
                children: <Widget>[
                  Image.network(
                      "${ApiService.websiteUrl}course-images/" +
                          param["feature_image"],
                      height: 95,
                      fit: BoxFit.fill),
                  // Positioned(
                  //   bottom: 0.0,
                  //   left: 0.0,
                  //   right: 0.0,
                  //   child: Container(
                  //     color: Colors.blue,
                  //     padding: EdgeInsets.symmetric(
                  //         vertical: 10.0, horizontal: 20.0),
                  //     child: Text(
                  //       "50% Discount",
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 14.0,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      param["course_title"],
                      maxLines: 3,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 17),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Row(
                      children: <Widget>[
                        Icon(
                          Icons.star,
                          color: Colors.pink,
                          size: 18,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.pink,
                          size: 18,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.pink,
                          size: 18,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.pink,
                          size: 18,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.pink,
                          size: 18,
                        ),
                      ],
                    ),
                    const Row(
                      children: <Widget>[
                        Text(
                          "4.5/90",
                          style: TextStyle(fontSize: 13),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Ratings",
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // return GestureDetector(
    //   onTap: () {
    //     Navigator.of(context)
    //         .pushNamed(MycourseDetailsScreen.routeName, arguments: param);
    //   },
    //   child: Padding(
    //     padding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0),
    //     child: Container(
    //       decoration: BoxDecoration(
    //         borderRadius: const BorderRadius.all(Radius.circular(15.0)),
    //         color: Color(0xff2874a6),
    //         boxShadow: <BoxShadow>[
    //           BoxShadow(
    //               color: Colors.grey.withOpacity(0.5),
    //               offset: const Offset(0, 2),
    //               blurRadius: 8.0),
    //         ],
    //       ),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           ClipRRect(
    //           borderRadius: BorderRadius.only(topRight:  Radius.circular(15),topLeft:  Radius.circular(15)),
    //           child: Image.network(
    //               ApiService.websiteUrl +
    //                   "course-images/" +
    //                   param["feature_image"],

    //               fit: BoxFit.fill),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
    //             child: Text(
    //               param["course_title"],
    //               overflow: TextOverflow.ellipsis,
    //               maxLines: 3,
    //               style: TextStyle(
    //                   fontSize: 14,
    //                   color: Colors.white,
    //                   fontWeight: FontWeight.bold),
    //             ),
    //           ),
    //           SizedBox(height: 5),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               Padding(
    //                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
    //                 child: Text("Author: Career Institute",
    //                     style: TextStyle(color: Colors.white)),
    //               ),

    //             ],
    //           ),
    //           SizedBox(height: 10),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
