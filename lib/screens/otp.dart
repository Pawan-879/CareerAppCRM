import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:careerapp/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:careerapp/screens/app.dart';

final inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(8.0),
  borderSide: BorderSide(color: Colors.grey.shade400),
);

final inputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
  border: inputBorder,
  focusedBorder: inputBorder,
  enabledBorder: inputBorder,
);

class OTPPage extends StatefulWidget {
  static const String routeName = '/otp';
  const OTPPage({Key? key}) : super(key: key);

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  dynamic mobileno = "", status = "0", otp, detail;
  FocusNode? pin2FN;
  FocusNode? pin3FN;
  FocusNode? pin4FN;
  final pinStyle = const TextStyle(fontSize: 32, fontWeight: FontWeight.bold);

  var pinval1, pinval2, pinval3, pinval4;

  @override
  void initState() {
    super.initState();
    pin2FN = FocusNode();
    pin3FN = FocusNode();
    pin4FN = FocusNode();
    Future.delayed(Duration.zero, () {
      mobileno = ModalRoute.of(context)!.settings.arguments;
      sendOTP();
      print("mobile" + mobileno);
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    pin2FN?.dispose();
    pin3FN?.dispose();
    pin4FN?.dispose();
  }

  void nextField(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  sendOTP() async {
    var data = json.encode({'phone': mobileno, 'deviceType': 'android'});
    try {
      var response = await ApiService.postMethod(
        '/login2',
        data,
      );
      print(response);
      otp = response["otp"];
      status = response["status"];
      detail = response["detail"];
    } catch (err) {
      print(err);
    }
  }

  void _submit() async {
    _formKey.currentState!.save();
    var enteredotp = pinval1 + "" + pinval2 + "" + pinval3 + "" + pinval4;

    if (otp.toString() == enteredotp) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userData', json.encode(detail));

      Navigator.of(context)
          .pushNamedAndRemoveUntil(App.routeName, (r) => false);
    } else {
      Fluttertoast.showToast(
          msg: "Invalid Mobile no and OTP!", timeInSecForIosWeb: 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30.0),
            const Text(
              "Please enter the 4-digit OTP",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 20.0),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          autofocus: true,
                          style: pinStyle,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: inputDecoration,
                          onSaved: (value) {
                            pinval1 = value;
                          },
                          onChanged: (value) {
                            nextField(value, pin2FN!);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          focusNode: pin2FN,
                          style: pinStyle,
                          onSaved: (value) {
                            pinval2 = value;
                          },
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: inputDecoration,
                          onChanged: (value) => nextField(value, pin3FN!),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          focusNode: pin3FN,
                          style: pinStyle,
                          onSaved: (value) {
                            pinval3 = value;
                          },
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: inputDecoration,
                          onChanged: (value) => nextField(value, pin4FN!),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          focusNode: pin4FN,
                          style: pinStyle,
                          onSaved: (value) {
                            pinval4 = value;
                          },
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: inputDecoration,
                          onChanged: (value) {
                            if (value.length == 1) {
                              pin4FN!.unfocus();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  // Text(
                  //   "Expiring in 02:22",
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  // ),
                  const SizedBox(height: 10.0),
                  TextButton(
                    child: Text(
                      "OTP has been Sent to " +
                          mobileno +
                          " and your registered Email Address. Please wait for OTP.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xff083174),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      sendOTP();
                    },
                  ),
                  const SizedBox(height: 30.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff083174),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      padding: const EdgeInsets.all(16.0),
                      minimumSize: const Size(200, 60),
                    ),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      _submit();
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
