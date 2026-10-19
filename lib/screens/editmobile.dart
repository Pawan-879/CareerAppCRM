import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class Editmobile extends StatefulWidget {
  static const String routeName = '/editmobile';

  const Editmobile({Key? key}) : super(key: key);

  @override
  _EditmobileState createState() => _EditmobileState();
}

class _EditmobileState extends State<Editmobile> {
  var user_id;
  var userData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final phone = TextEditingController();
  final otp = TextEditingController();
  var systemotp;
  var emailid = "";
  final _authData = {'phone': '', 'otp': ''};
  var otpsend = false;
  void _submit() async {
    if (validateAndSave()) {
      if (systemotp.toString() == _authData['otp']) {
        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString('userData');
        if (userDataString == null) {
          Fluttertoast.showToast(msg: "Please login again.", timeInSecForIosWeb: 10);
          return;
        }

        userData = json.decode(userDataString);

        var data = json.encode(
            {'user_id': userData["user_id"], 'phone': _authData['phone']});

        try {
          var response = await ApiService.postMethod(
            '/updateMobile',
            data,
          );

          if (response["status"] == "1") {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.setString('userData', json.encode(response["detail"]));
            Fluttertoast.showToast(
                msg: "Profile updated successfully.", timeInSecForIosWeb: 10);
            if (!mounted) return;
            Navigator.pop(context);
          } else {
            Fluttertoast.showToast(
                msg: "Invalid password", timeInSecForIosWeb: 10);
          }
        } catch (err) {
          if (kDebugMode) {
            print(err);
          }
        }
      } else {
        Fluttertoast.showToast(msg: "OTP is invalid!", timeInSecForIosWeb: 10);
      }
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      final userDataString = prefs.getString('userData');
      if (userDataString == null) return;
      userData = json.decode(userDataString);
      user_id = userData["user_id"];
      emailid = userData["user_email"];
      if (!mounted) return;
      setState(() {});
    }
  }

  void sendOTP() async {
    var data = json.encode({'email': emailid, 'deviceType': 'android'});
    try {
      var response = await ApiService.postMethod(
        '/forgot',
        data,
      );
      if (kDebugMode) {
        print(response);
      }
      systemotp = response["otp"];
      otpsend = true;

      Fluttertoast.showToast(
          msg: "OTP is sent. Please check your email id.",
          timeInSecForIosWeb: 25);
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    emailController.dispose();
    phone.dispose();
    otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Mobile Number",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
         backgroundColor: Colors.blue, 
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 1000,
                  color: Colors.grey[100],
                ),
                Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Card(
                            child: Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: const Text(
                                      "Update mobile number by Registered Email Id.",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  const Divider(
                                    color: Colors.black38,
                                  ),
                                  Text(
                                    emailid,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  otpsend == true
                                      ? const Text("Please wait...")
                                      : SizedBox(
                                          width: 200,
                                          height: 44,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.blue[700],
                                              foregroundColor: Colors.white,
                                              textStyle: const TextStyle(
                                                color: Colors.white,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                            ),
                                            onPressed: sendOTP,
                                            child: const Text('Send OTP'),
                                          ),
                                        ),
                                  const SizedBox(height: 15),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: const Text(
                                      "Edit Information",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  const Divider(
                                    color: Colors.black38,
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextFormField(
                                              textInputAction:
                                                  TextInputAction.next,
                                              onEditingComplete: () =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              keyboardType:
                                                  TextInputType.number,
                                              validator: (value) =>
                                                  value == null || value.isEmpty
                                                  ? 'Phone field can\'t be empty'
                                                  : null,
                                              onSaved: (value) {
                                                _authData['phone'] = value ?? '';
                                              },
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  // width: 0.0 produces a thin "hairline" border
                                                  borderSide: BorderSide(
                                                      color: Colors.black,
                                                      width: 1.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                ),
                                                hintText: "New Mobile No.",
                                                hintStyle: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            TextFormField(
                                              textInputAction:
                                                  TextInputAction.next,
                                              onEditingComplete: () =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              keyboardType:
                                                  TextInputType.number,
                                              validator: (value) =>
                                                  value == null || value.isEmpty
                                                  ? 'OTP field can\'t be empty'
                                                  : null,
                                              onSaved: (value) {
                                                _authData['otp'] = value ?? '';
                                              },
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  // width: 0.0 produces a thin "hairline" border
                                                  borderSide: BorderSide(
                                                      color: Colors.black,
                                                      width: 1.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                ),
                                                hintText: "Enter OTP",
                                                hintStyle: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            SizedBox(
                                              width: 200,
                                              height: 44,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue[700],
                                              foregroundColor: Colors.white,

                                                  textStyle: const TextStyle(
                                                      color: Colors.white),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                ),
                                                onPressed: _submit,
                                                child: const Text(
                                                    'Update Mobile No.'),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
