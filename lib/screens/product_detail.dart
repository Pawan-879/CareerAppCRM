import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:careerapp/screens/openurl.dart';

class Productdetail extends StatefulWidget {
  static const routeName = '/product_detail';

  const Productdetail({Key? key}) : super(key: key);

  @override
  _ProductdetailState createState() => _ProductdetailState();
}

class _ProductdetailState extends State<Productdetail> {
  late Razorpay _razorpay;
  var data;
  var data2 = [];
  var isLoading = false;
  dynamic param;
  var user_id = "";
  var user_name = "";
  var user_email = "";
  var user_phone = "";
  var userData;

  final GlobalKey<FormState> _formKey = GlobalKey();
  var emailController = TextEditingController();
  final _authData = {
    'full_name': '',
    'student_name': '',
    'address': '',
    'class_name': '',
    'category': '',
    'board': '',
    'email': '',
    'phone': '',
    'city': '',
    'state': '',
    'pincode': '',
    'password': ''
  };
  var boards = [], classes = [], states = [], districts = [];
  var board = "", class1 = "", class_name = "", state = "", city = "";
  bool _showPassword = true, detailbox = false;
  var acceptTerms = false;
  String btnname = "Buy Now";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      param = ModalRoute.of(context)?.settings.arguments;
      setState(() {});
    });
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    getUserData();
    getData();
  }

  getData() async {
    try {
      var res3 = await ApiService.getMethod("/getStates");
      dynamic mydata3 = json.decode(res3.body);
      states = mydata3["detail"];
    } catch (err) {
      print(err);
    }
    setState(() {});
  }

  getCities(stateId) async {
    try {
      var res4 = await ApiService.getMethod("/getDistricts?state_id=$stateId");
      dynamic mydata4 = json.decode(res4.body);
      districts = mydata4["detail"];
    } catch (err) {
      print(err);
    }
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

  void openCheckout() async {
    if (!detailbox) {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('userData')) {
        checkout2(userData);
      } else {
        detailbox = true;
        setState(() {
          btnname = "Submit";
        });
      }
    } else {
      submitform();
    }
  }

  void openCheckout2() async {
    if (!detailbox) {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('userData')) {
        checkout3(userData);
      } else {
        detailbox = true;
        setState(() {
          btnname = "Submit";
        });
      }
    } else {
      submitform();
    }
  }

  void submitform() async {
    _formKey.currentState!.save();
    if (validateAndSave()) {
      var data = json.encode({
        'full_name': _authData['full_name'],
        'email': _authData['email'],
        'phone': _authData['phone'],
        'address': _authData['address'],
        'city': city,
        'state': state,
        'pincode': _authData['pincode'],
        'password': _authData['password']
      });

      print(data);
      try {
        var response = await ApiService.postMethod(
          '/signup',
          data,
        );

        if (response["status"] == "1") {
          dynamic studentData = response["detail"];
          user_id = studentData["user_id"];

          setState(() {});

          checkout3(studentData);
        } else {
          Fluttertoast.showToast(
              msg: "Email id already exist. Please try another email id.",
              timeInSecForIosWeb: 10);
        }
      } catch (err) {
        print(err);
      }
    }
  }

  void checkout3(studentDetails) async {
    var uId = user_id;
    var pId = param["id"];

    dynamic row = {
      "school_name": param["product_name"],
      "url": "https://www.careerinstitute.co/app/payu/payAction.php?user_id=$uId&product_id=" +
          pId +
          "&type=book"
    };
    Navigator.of(context).pushNamed(OpenUrl.routeName, arguments: row);
  }

  void checkout2(studentDetails) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      if (double.parse(param["our_price"]) != 0) {
        var options = {
          'key': 'rzp_live_Pcdep9U0ODwKYM',
          'amount': double.parse(param["our_price"]) * 100,
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
      if (double.parse(param["our_price"]) != 0) {
        var options = {
          'key': 'rzp_live_Pcdep9U0ODwKYM',
          'amount': double.parse(param["our_price"]) * 100,
          'name': studentDetails["user_name"],
          'description': 'Payment',
          'prefill': {
            'contact': studentDetails["user_phone"],
            'email': studentDetails["user_email"]
          },
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
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    var data = json.encode({
      'type': 'Book',
      'user_id': user_id,
      'product_id': param["id"],
      'payment_id': response.paymentId
    });

    try {
      var response2 = await ApiService.postMethod(
        '/productPayment',
        data,
      );
      print(response2);
      if (response2["status"] == "1") {
        Fluttertoast.showToast(
            msg: "Payment successfully Completed.", timeInSecForIosWeb: 10);
      }
    } catch (err) {
      print(err);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Failed", timeInSecForIosWeb: 4);
    // Fluttertoast.showToast(
    //     msg: "ERROR: " + response.code.toString() + " - " + response.message,
    //     timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: ${response.walletName!}", timeInSecForIosWeb: 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Details"),
          actions: const [],
        ),
        body: Column(children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: Image.network(
                    "${ApiService.websiteUrl}products/" +
                        param["product_image"],
                    fit: BoxFit.contain,
                  ),
                ),
                Card(
                  margin:
                      const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          param["product_name"],
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 18.0),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text("Rs." + param["mrp"] + "/-",
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.lineThrough)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Rs." + param["our_price"] + "/-",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                              fontSize: 25,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                detailbox
                    ? Container(
                        padding: const EdgeInsets.only(
                            left: 40, top: 20, right: 40, bottom: 0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Fill the below details:",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.red)),
                              const SizedBox(height: 10),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () =>
                                    FocusScope.of(context).nextFocus(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  // height: 0.5,
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Your Name field can\'t be empty'
                                    : null,
                                onSaved: (value) {
                                  _authData['full_name'] = value!;
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  hintText: "Your Name",
                                  hintStyle: TextStyle(
                                      fontSize: 14.0, color: Colors.black),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                onEditingComplete: () =>
                                    FocusScope.of(context).nextFocus(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  // height: 0.5,
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Mobile can\'t be empty';
                                  }

                                  if (value.length < 10) {
                                    return 'Mobile length should be 10';
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['phone'] = value!;
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  hintText: "Mobile No.",
                                  hintStyle: TextStyle(
                                      fontSize: 14.0, color: Colors.black),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () =>
                                    FocusScope.of(context).nextFocus(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  // height: 0.5,
                                ),
                                maxLines: 3,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Address can\'t be empty';
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['address'] = value!;
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  hintText: "Address",
                                  hintStyle: TextStyle(
                                      fontSize: 14.0, color: Colors.black),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                onEditingComplete: () =>
                                    FocusScope.of(context).nextFocus(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  // height: 0.5,
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Pincode can\'t be empty';
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['pincode'] = value!;
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  hintText: "PINCODE",
                                  hintStyle: TextStyle(
                                      fontSize: 14.0, color: Colors.black),
                                ),
                              ),
                              const SizedBox(height: 15),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  hintText: "Select State",
                                  hintStyle: TextStyle(color: Colors.black),
                                ),
                                isExpanded: true,
                                initialValue: state == "" ? null : state,
                                onChanged: (value) {
                                  setState(() {
                                    state = value!;
                                    getCities(state);
                                  });
                                },
                                validator: (value) {
                                  print(value);
                                  if (value == null) {
                                    return 'Please select State';
                                  }

                                  return null;
                                },
                                items: states
                                    .map<DropdownMenuItem<String>>(
                                        (value) => DropdownMenuItem<String>(
                                              value: value["id"],
                                              child: Text(value["state_name"],
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                            ))
                                    .toList(),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                  child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  hintText: "Select City",
                                  hintStyle: TextStyle(color: Colors.black),
                                ),
                                isExpanded: true,
                                initialValue: city == "" ? null : city,
                                onChanged: (value) {
                                  setState(() {
                                    city = value!;
                                    print(value);
                                  });
                                },
                                validator: (value) {
                                  print(value);
                                  if (value == null) {
                                    return 'Please select city';
                                  }

                                  return null;
                                },
                                items: districts
                                    .map<DropdownMenuItem<String>>(
                                        (value) => DropdownMenuItem<String>(
                                              value: value["id"],
                                              child: Text(
                                                  value["district_name"],
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                            ))
                                    .toList(),
                              )),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: emailController,
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () =>
                                    FocusScope.of(context).nextFocus(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  // height: 0.5,
                                ),
                                validator: (value) {
                                  RegExp regExp = RegExp(
                                      r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$');

                                  if (!regExp.hasMatch(value!)) {
                                    return 'Enter a valid email id.';
                                  }

                                  if (value.isEmpty) {
                                    return 'Email Address field can\'t be empty';
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['email'] = value!;
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  hintText: "Email Address",
                                  hintStyle: TextStyle(
                                      fontSize: 14.0, color: Colors.black),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                obscureText: _showPassword,
                                keyboardType: TextInputType.visiblePassword,
                                style: const TextStyle(
                                  color: Colors.black,
                                  // height: 0.5,
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Password can\'t be empty';
                                  }

                                  if (value.length < 8) {
                                    return 'Password length must be greater than 8';
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['password'] = value!;
                                },
                                onChanged: (val) {},
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color: _showPassword
                                          ? Colors.black
                                          : Colors.grey[400],
                                    ),
                                    onPressed: () {
                                      setState(
                                          () => _showPassword = !_showPassword);
                                    },
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  hintText: "Password",
                                  hintStyle: const TextStyle(
                                      fontSize: 14.0, color: Colors.black),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const Text(" "),
                Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, top: 0.0, right: 10.0),
                    child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                            bottomLeft: Radius.circular(5),
                            topLeft: Radius.circular(5)),
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          color: Colors.blue,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () {
                              openCheckout2();
                            },
                            child: Text(btnname,
                                style: const TextStyle(
                                    fontSize: 19, color: Colors.white)),
                          ),
                        ))),
                const SizedBox(height: 10),
                Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Html(data: param["content"], style: {
                      "html": Style(
                        color: Colors.black,
                        //              color:Colors.black,
                      ),
                    })),
              ],
            ),
          )
        ]));
  }
}
