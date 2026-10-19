import 'package:flutter/material.dart';
import 'package:careerapp/screens/login.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var emailController = TextEditingController();
  final _authData = {
    'full_name': '',
    'student_name': '',
    'class_name': '',
    'category': '',
    'board': '',
    'email': '',
    'phone': '',
    'city': '',
    'state': '',
    'address': '',
    'pincode': '',
    'password': ''
  };
  var boards = [], classes = [], states = [], districts = [];
  var board = "",
      class1 = "",
      class_name = "",
      state = "",
      city = "",
      studyingin = "";
  bool _showPassword = true;
  var acceptTerms = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getData();
    errorMessage = "";
  }

  void _submit() async {
    _formKey.currentState!.save();
    if (validateAndSave()) {
      var data = json.encode({
        'full_name': _authData['full_name'],
        'studyingin': studyingin,
        'class_name': class_name,
        'category': class1,
        'board': board,
        'email': _authData['email'],
        'phone': _authData['phone'],
        'city': city,
        'state': state,
        'address': _authData['address'],
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
          Navigator.of(context)
              .pushNamedAndRemoveUntil(LoginScreen.routeName, (r) => false);
        } else {
          Fluttertoast.showToast(
              msg: "User already exist!", timeInSecForIosWeb: 10);
        }
      } catch (err) {
        print(err);
      }
    }
  }

  getData() async {
    try {
      var res = await ApiService.getMethod("/getBoards");
      dynamic mydata = json.decode(res.body);
      boards = mydata["detail"];

      var res2 = await ApiService.getMethod("/getAppCategories");
      dynamic mydata2 = json.decode(res2.body);
      classes = mydata2["detail"];

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
      body: Container(
          padding: const EdgeInsets.only(top: 70, bottom: 20),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/background.png"), fit: BoxFit.cover),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      const SizedBox(height: 45),
                      Image.asset('assets/logo.png'),
                      const SizedBox(height: 15),
                      const Text(
                        "CAREER APP SIGNUP",
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 40, top: 20, right: 40, bottom: 0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () =>
                                    FocusScope.of(context).nextFocus(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  // height: 0.5,
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Student Name field can\'t be empty'
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
                                        color: Colors.white70, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1.0),
                                  ),
                                  hintText: "Student Name",
                                  hintStyle: TextStyle(
                                      fontSize: 14.0, color: Colors.white70),
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
                                        color: Colors.white70, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1.0),
                                  ),
                                  hintText: "Studying In",
                                  hintStyle: TextStyle(
                                      fontSize: 14.0, color: Colors.white70),
                                ),
                                isExpanded: true,
                                dropdownColor: Colors.blue,
                                initialValue: studyingin == "" ? null : studyingin,
                                validator: (value) {
                                  print(value);
                                  if (value == null) {
                                    return 'Please studying in';
                                  }

                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    studyingin = value!;
                                    print(value);
                                  });
                                },
                                items: <String>[
                                  'Career Defence School',
                                  'Other School'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                        style: const TextStyle(
                                            color: Colors.white70)),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 15),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide: BorderSide(
                                        color: Colors.white70, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1.0),
                                  ),
                                  hintText: "Select Class",
                                  hintStyle: TextStyle(
                                      fontSize: 14.0, color: Colors.white70),
                                ),
                                isExpanded: true,
                                dropdownColor: Colors.blue,
                                initialValue: class_name == "" ? null : class_name,
                                validator: (value) {
                                  print(value);
                                  if (value == null) {
                                    return 'Please select class';
                                  }

                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    class_name = value!;
                                    print(value);
                                  });
                                },
                                items: <String>[
                                  'Class 1',
                                  'Class 2',
                                  'Class 3',
                                  'Class 4',
                                  'Class 5',
                                  'Class 6',
                                  'Class 7',
                                  'Class 8',
                                  'Class 9',
                                  'Class 10',
                                  'Class 11',
                                  'Class 12'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                        style: const TextStyle(
                                            color: Colors.white70)),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 15),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide: BorderSide(
                                        color: Colors.white70, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1.0),
                                  ),
                                  hintText: "Course Interested",
                                  hintStyle: TextStyle(color: Colors.white70),
                                ),
                                isExpanded: true,
                                dropdownColor: Colors.blue,
                                initialValue: class1 == "" ? null : class1,
                                onChanged: (value) {
                                  setState(() {
                                    class1 = value!;
                                    print(value);
                                  });
                                },
                                validator: (value) {
                                  print(value);
                                  if (value == null) {
                                    return 'Please select Course Interested';
                                  }

                                  return null;
                                },
                                items: classes
                                    .map<DropdownMenuItem<String>>(
                                        (value) => DropdownMenuItem<String>(
                                              value: value["id"],
                                              child: Text(
                                                  value["category_name"],
                                                  style: const TextStyle(
                                                      color: Colors.white70)),
                                            ))
                                    .toList(),
                              ),
                              const SizedBox(height: 15),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide: BorderSide(
                                        color: Colors.white70, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1.0),
                                  ),
                                  hintText: "Select Board",
                                  hintStyle: TextStyle(color: Colors.white70),
                                ),
                                isExpanded: true,
                                dropdownColor: Colors.blue,
                                initialValue: board == "" ? null : board,
                                onChanged: (value) {
                                  setState(() {
                                    board = value!;
                                    print(value);
                                  });
                                },
                                validator: (value) {
                                  print(value);
                                  if (value == null) {
                                    return 'Please select Board';
                                  }

                                  return null;
                                },
                                items: boards
                                    .map<DropdownMenuItem<String>>(
                                        (value) => DropdownMenuItem<String>(
                                              value: value["id"],
                                              child: Text(value["board_name"],
                                                  style: const TextStyle(
                                                      color: Colors.white70)),
                                            ))
                                    .toList(),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                onEditingComplete: () =>
                                    FocusScope.of(context).nextFocus(),
                                style: const TextStyle(
                                  color: Colors.white,
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
                                        color: Colors.white70, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1.0),
                                  ),
                                  hintText: "Mobile No.",
                                  hintStyle: TextStyle(
                                      fontSize: 14.0, color: Colors.white70),
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
                                        color: Colors.white70, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1.0),
                                  ),
                                  hintText: "Select State",
                                  hintStyle: TextStyle(color: Colors.white70),
                                ),
                                isExpanded: true,
                                dropdownColor: Colors.blue,
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
                                                      color: Colors.white70)),
                                            ))
                                    .toList(),
                              ),
                              const SizedBox(height: 15),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide: BorderSide(
                                        color: Colors.white70, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1.0),
                                  ),
                                  hintText: "Select City",
                                  hintStyle: TextStyle(color: Colors.white70),
                                ),
                                isExpanded: true,
                                dropdownColor: Colors.blue,
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
                                                      color: Colors.white70)),
                                            ))
                                    .toList(),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () =>
                                    FocusScope.of(context).nextFocus(),
                                style: const TextStyle(
                                  color: Colors.white,
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
                                        color: Colors.white, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1.0),
                                  ),
                                  hintText: "Address",
                                  hintStyle: TextStyle(
                                      fontSize: 14.0, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                onEditingComplete: () =>
                                    FocusScope.of(context).nextFocus(),
                                style: const TextStyle(
                                  color: Colors.white,
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
                                        color: Colors.white70, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1.0),
                                  ),
                                  hintText: "PINCODE",
                                  hintStyle: TextStyle(
                                      fontSize: 14.0, color: Colors.white70),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: emailController,
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () =>
                                    FocusScope.of(context).nextFocus(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  // height: 0.5,
                                ),
                                validator: (value) {
                                  RegExp regExp = RegExp(
                                      r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$');

                                  if (value!.isEmpty) {
                                    return 'Email Address field can\'t be empty';
                                  }

                                  if (!regExp.hasMatch(value)) {
                                    return 'Enter a valid email id.';
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
                                        color: Colors.white70, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1.0),
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
                                          ? Colors.white
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
                                        color: Colors.white70, width: 1.0),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1.0),
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
                                    backgroundColor: Colors.white,
                                    textStyle: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                  onPressed: _submit,
                                  child: const Text('REGISTER ACCOUNT'),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
