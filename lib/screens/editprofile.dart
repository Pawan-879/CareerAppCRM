import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class Editprofile extends StatefulWidget {
  static const String routeName = '/profile';

  const Editprofile({Key? key}) : super(key: key);

  @override
  _EditprofileState createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  var user_id;
  var userData;
  final GlobalKey<FormState> _formKey = GlobalKey();
  var emailController = TextEditingController();
  var full_name = TextEditingController();
  var address = TextEditingController();

  var pincode = TextEditingController();
  final _authData = {
    'full_name': '',
    'email': '',
    'address': '',
    'city': '',
    'state': '',
    'pincode': ''
  };

  var boards = [], classes = [], states = [], districts = [];
  var board = "",
      class1 = "",
      className = "",
      state = "",
      city = "",
      studyingin = "";

  @override
  void initState() {
    super.initState();
    getUserData();
    getData();
  }

  void _submit() async {
    _formKey.currentState!.save();

    if (validateAndSave()) {
      final prefs = await SharedPreferences.getInstance();
      userData = json.decode(prefs.getString('userData')!);

      var data = json.encode({
        'user_id': user_id,
        'full_name': _authData['full_name'],
        'studyingin': studyingin,
        'class_name': className,
        'category': class1,
        'board': board,
        'email': _authData['email'],
        'address': _authData['address'],
        'city': city,
        'state': state,
        'pincode': _authData['pincode'],
      });
      if (kDebugMode) {
        print(data);
      }
      try {
        var response = await ApiService.postMethod(
          '/updateUser',
          data,
        );

        if (response["status"] == "1") {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('userData', json.encode(response["detail"]));
          Fluttertoast.showToast(
              msg: "Profile updated successfully.", timeInSecForIosWeb: 10);
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

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      userData = json.decode(prefs.getString('userData')!);
      user_id = userData["user_id"];
      full_name.text = userData["user_name"];
      emailController.text = userData["user_email"];
      address.text = userData["address"];
      className = userData["class_name"];
      class1 = userData["category_id"];
      board = userData["board_id"];
      city = userData["city"];
      state = userData["state"];
      studyingin = userData["studyingin"];
      pincode.text = userData["pincode"].toString();
      getCities(state);
      setState(() {});
    }
  }

  getCities(stateId) async {
    try {
      var res4 = await ApiService.getMethod("/getDistricts?state_id=$stateId");
      dynamic mydata4 = json.decode(res4.body);
      districts = mydata4["detail"];
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[500],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15, color: Colors.white),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Text("Enter Your Name"),
                                            TextFormField(
                                              controller: full_name,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onEditingComplete: () =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                              style: const TextStyle(

                                                  // height: 0.5,
                                                  ),
                                              validator: (value) => value!
                                                      .isEmpty
                                                  ? 'Full Name field can\'t be empty'
                                                  : null,
                                              onSaved: (value) {
                                                _authData['full_name'] = value!;
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
                                                hintText: "Full Name",
                                                hintStyle: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            const Text("School"),
                                            DropdownButtonFormField<String>(
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
                                                hintText: "Select School",
                                                hintStyle: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black),
                                              ),
                                              isExpanded: true,
                                              initialValue: studyingin == ""
                                                  ? null
                                                  : studyingin,
                                              validator: (value) {
                                                if (kDebugMode) {
                                                  print(value);
                                                }
                                                if (value == null) {
                                                  return 'Please select school';
                                                }

                                                return null;
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  studyingin = value!;
                                                  if (kDebugMode) {
                                                    print(value);
                                                  }
                                                });
                                              },
                                              items: <String>[
                                                'Career Defence School',
                                                'Other School'
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value,
                                                      style: const TextStyle(
                                                          color: Colors.black)),
                                                );
                                              }).toList(),
                                            ),
                                            const SizedBox(height: 15),
                                            const Text("Class"),
                                            DropdownButtonFormField<String>(
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
                                                hintText: "Select Class",
                                                hintStyle: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black),
                                              ),
                                              isExpanded: true,
                                              initialValue: className == ""
                                                  ? null
                                                  : className,
                                              validator: (value) {
                                                if (kDebugMode) {
                                                  print(value);
                                                }
                                                if (value == null) {
                                                  return 'Please select class';
                                                }

                                                return null;
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  className = value!;
                                                  if (kDebugMode) {
                                                    print(value);
                                                  }
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
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value,
                                                      style: const TextStyle(
                                                          color: Colors.black)),
                                                );
                                              }).toList(),
                                            ),
                                            const SizedBox(height: 15),
                                            const Text("Course Interested"),
                                            DropdownButtonFormField<String>(
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
                                                hintText: "Course Interested",
                                                hintStyle: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              isExpanded: true,
                                              initialValue:
                                                  class1 == "" ? null : class1,
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
                                                  .map<
                                                      DropdownMenuItem<
                                                          String>>((value) =>
                                                      DropdownMenuItem<String>(
                                                        value: value["id"],
                                                        child: Text(
                                                            value[
                                                                "category_name"],
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                      ))
                                                  .toList(),
                                            ),
                                            const SizedBox(height: 15),
                                            const Text("Board"),
                                            DropdownButtonFormField<String>(
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
                                                hintText: "Select Board",
                                                hintStyle: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              isExpanded: true,
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
                                                  .map<
                                                      DropdownMenuItem<
                                                          String>>((value) =>
                                                      DropdownMenuItem<String>(
                                                        value: value["id"],
                                                        child: Text(
                                                            value["board_name"],
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                      ))
                                                  .toList(),
                                            ),
                                            const SizedBox(height: 15),
                                            const Text("Email Address"),
                                            TextFormField(
                                              controller: emailController,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onEditingComplete: () =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              validator: (value) => value!
                                                      .isEmpty
                                                  ? 'Email Address field can\'t be empty'
                                                  : null,
                                              onSaved: (value) {
                                                _authData['email'] = value!;
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
                                                hintText: "Email Address",
                                                hintStyle: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            const Text("State"),
                                            DropdownButtonFormField<String>(
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
                                                hintText: "Select State",
                                                hintStyle: TextStyle(
                                                    color: Colors.black),
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
                                                  .map<
                                                      DropdownMenuItem<
                                                          String>>((value) =>
                                                      DropdownMenuItem<String>(
                                                        value: value["id"],
                                                        child: Text(
                                                            value["state_name"],
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                      ))
                                                  .toList(),
                                            ),
                                            const SizedBox(height: 15),
                                            const Text("City"),
                                            DropdownButtonFormField<String>(
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
                                                hintText: "Select City",
                                                hintStyle: TextStyle(
                                                    color: Colors.black),
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
                                                  .map<
                                                      DropdownMenuItem<
                                                          String>>((value) =>
                                                      DropdownMenuItem<String>(
                                                        value: value["id"],
                                                        child: Text(
                                                            value[
                                                                "district_name"],
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                      ))
                                                  .toList(),
                                            ),
                                            const SizedBox(height: 15),
                                            const Text("Address"),
                                            TextFormField(
                                              controller: address,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onEditingComplete: () =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              validator: (value) => value!
                                                      .isEmpty
                                                  ? 'Address field can\'t be empty'
                                                  : null,
                                              onSaved: (value) {
                                                _authData['address'] = value!;
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
                                                hintText: "Address",
                                                hintStyle: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            const Text("Pincode"),
                                            TextFormField(
                                              controller: pincode,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onEditingComplete: () =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              validator: (value) => value!
                                                      .isEmpty
                                                  ? 'PINCODE field can\'t be empty'
                                                  : null,
                                              onSaved: (value) {
                                                _authData['pincode'] = value!;
                                              },
                                              keyboardType:
                                                  TextInputType.number,
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
                                                hintText: "Pincode",
                                                hintStyle: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          Column(
  children: [
    const SizedBox(height: 15),
    Center( // Wrap the SizedBox with Center
      child: SizedBox(
        width: 200,
        height: 44,
        child: TextButton(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(color: Colors.white),
            backgroundColor: const Color(0xff2169b1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: _submit,
          child: const Text('Update Profile'),
        ),
      ),
    ),
  ],
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
