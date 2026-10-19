import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerapp/screens/App.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:convert';

class ConsultantLogin extends StatefulWidget {
  static const String routeName = '/ConsultantLogin';

  const ConsultantLogin({Key? key}) : super(key: key);
  @override
  _ConsultantLoginState createState() => _ConsultantLoginState();
}

class _ConsultantLoginState extends State<ConsultantLogin> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey();
  var emailController = TextEditingController();
  final _authData = {'email': '', 'password': ''};
  late String _errorMessage;
  bool _showPassword = true;
  @override
  void initState() {
    _errorMessage = "";
    super.initState();
  }

  void _submit() async {
    _formKey.currentState?.save();
    if (validateAndSave()) {
      print(_authData);

      var data = json.encode({
        'email': _authData['email'],
        'password': _authData['password'],
        'deviceType': 'android'
      });

      try {
        var response = await ApiService.postMethod3(
          '/consultant_login',
          data,
        );

        if (response["error"] == false) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('consulData', json.encode(response["data"]));
          Navigator.of(context)
              .pushNamedAndRemoveUntil(App.routeName, (r) => false);
        } else {
          Fluttertoast.showToast(
              msg: "Invalid email and password!", timeInSecForIosWeb: 10);
        }
      } catch (err) {
        print(err);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/background.png"), fit: BoxFit.cover),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png'),
                  const SizedBox(height: 15),
                  const Text(
                    "CAREER APP CONSULTANT LOGIN",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 60, top: 20, right: 60, bottom: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: emailController,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () =>
                                FocusScope.of(context).nextFocus(),
                            style: const TextStyle(
                              color: Colors.white,
                              // height: 0.5,
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Email field can\'t be empty'
                                : null,
                            onSaved: (value) {
                              _authData['email'] = value!;
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(
                                    color: Colors.white70, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1.0),
                              ),
                              hintText: "Email Address",
                              hintStyle: TextStyle(
                                  fontSize: 14.0, color: Colors.white70),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            obscureText: _showPassword,
                            keyboardType: TextInputType.visiblePassword,
                            style: const TextStyle(
                              color: Colors.white,
                              // height: 0.5,
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Password field can\'t be empty'
                                : null,
                            onSaved: (value) {
                              _authData['password'] = value!;
                            },
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.remove_red_eye,
                                  color: _showPassword
                                      ? Colors.white
                                      : Colors.grey[400],
                                ),
                                onPressed: () {
                                  setState(() =>
                                      _showPassword = !_showPassword);
                                },
                              ),
                              enabledBorder: const OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(
                                    color: Colors.white70, width: 1.0),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1.0),
                              ),
                              hintText: "Password",
                              hintStyle: const TextStyle(
                                  fontSize: 14.0, color: Colors.white70),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: 200,
                            height: 44,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              onPressed: _submit,
                              child: const Text('LOGIN'),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          showErrorMessage(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget showErrorMessage() {
    return Text(
      _errorMessage,
      style: const TextStyle(
        fontSize: 13.0,
        color: Colors.red,
        height: 1.0,
        fontWeight: FontWeight.w300,
      ),
    );
    }
}
