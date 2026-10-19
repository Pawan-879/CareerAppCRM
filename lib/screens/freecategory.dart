import 'package:flutter/material.dart';
import 'package:careerapp/screens/course_details_screen.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:careerapp/screens/login.dart';
import 'package:careerapp/screens/openurl.dart';

class Freecategory extends StatefulWidget {
  static const routeName = '/freecategory';

  const Freecategory({Key? key}) : super(key: key);
  @override
  _FreecategoryState createState() => _FreecategoryState();
}

class _FreecategoryState extends State<Freecategory> {
  late Razorpay _razorpay;
  var data2 = [];
  var user_id = "";
  var user_name = "";
  var user_email = "";
  var user_phone = "";
  var userData;
  dynamic subcat;
  var subcat_name = "Loading...";
  var featured_image = "placeholder.png";
  var our_price = "0";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      subcat = ModalRoute.of(context)?.settings.arguments;
      subcat_name = subcat["sub_cat_name"];
      featured_image = subcat["image"];
      our_price = subcat["our_price"];
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
      user_id = userData["user_id"];
      user_name = userData["user_name"];
      user_email = userData["user_email"];
      user_phone = userData["user_phone"];
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
      if (double.parse(our_price) != 0) {
        var options = {
          'key': 'rzp_live_Pcdep9U0ODwKYM',
          'amount': double.parse(our_price) * 100,
          'name': user_name,
          'description': 'Payment',
          'prefill': {'contact': user_phone, 'email': user_email},
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
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  void openCheckout2() async {
    var uId = user_id;
    var pId = subcat["id"];

    dynamic row = {
      "school_name": subcat_name,
      "url": "https://www.careerinstitute.co/app/payu/payAction.php?user_id=$uId&product_id=" +
          pId +
          "&type=course"
    };
    Navigator.of(context).pushNamed(OpenUrl.routeName, arguments: row);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    var data = json.encode({
      'user_id': user_id,
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
            msg:
                "Payment successfully Completed. Please Check 'My Courses' Tab",
            timeInSecForIosWeb: 10);
      }
    } catch (err) {
      print(err);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "ERROR: Payment Failed", timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: Payment Failed", timeInSecForIosWeb: 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subcat_name),
        actions: [
          TextButton(
            onPressed: () {
              openCheckout2();
            },
            child: const Text('BUY NOW', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          Stack(
            children: <Widget>[
              Image.network(
                  "${ApiService.websiteUrl}subcat-images/$featured_image",
                  width: double.infinity,
                  fit: BoxFit.fill),
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
                      vertical: 20.0, horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subcat_name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
            .pushNamed(CourseDetailsScreen.routeName, arguments: param);
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
                          "5/5",
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
  }
}
