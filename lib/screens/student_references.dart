import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentReferences extends StatefulWidget {
  static const routeName = '/StudentReferences';

  const StudentReferences({Key? key}) : super(key: key);

  @override
  _StudentReferencesState createState() => _StudentReferencesState();
}

class _StudentReferencesState extends State<StudentReferences> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _authData = {
    'user_id': 0,
    'student_name': '',
    'class': ' ',
    'course_name': '',
    'email': '',
    'mobile_no_1': '',
    'mobile_no_2': '',
    'location': ''
  };
  var defaultCourse = 'Class 1';
  var data6 = [];
  var heading = "References";
  var userData;
  var user_id;
  double total_amount = 0;

  dynamic data = {};
  Color textColor = Colors.indigo.shade800;
  int selectedInndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      getData();

      setState(() {});
    });
  }

  getData() async {
    var res =
        await ApiService.getMethod3("/getReferences?user_id=" + data["id"]);
    dynamic d = jsonDecode(res.body);
    setState(() {
      data6 = d["data"];

      for (var element in data6) {
        total_amount += double.parse(element["amount"]);
      }
    });

    _authData['user_id'] = data["id"];
    if (kDebugMode) {
      print(data6);
    }
    setState(() {});
  }

  void _submit() async {
    _formKey.currentState?.save();
    if (validateAndSave()) {
      var data = json.encode(_authData);

      print(data);
      try {
        var response = await ApiService.postMethod3(
          '/saveStudentReference',
          data,
        );

        if (response["error"] == false) {
          Navigator.of(context).pop();
          Fluttertoast.showToast(
              msg: "Reference added successfully", timeInSecForIosWeb: 10);
          getData();
        } else {
          Fluttertoast.showToast(
              msg: "User already exist!", timeInSecForIosWeb: 10);
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
      appBar: AppBar(
        title: Text(
          heading,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: 5.w, right: 5.w, top: 3.h),
          title: Row(
            children: [
              Text(
                'Great!',
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 0.7.h),
                child: Image.asset('assets/like_icon.png'),
              )
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You have " +
                    data6.length.toString() +
                    ' Refrences total earned ₹' +
                    total_amount.toStringAsFixed(2),
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp),
              ),
              const Text("Refer Your Family Friends & Earn Money 💰"),
            ],
          ),
          // trailing: Stack(
          //   children: [
          //     Padding(
          //       padding: EdgeInsets.only(top: 0.5.h),
          //       child: CircleAvatar(
          //         backgroundColor:
          //             Theme.of(context).primaryColor.withOpacity(0.5),
          //       ),
          //     ),
          //     TextButton(
          //       child: Text(
          //         '+ Add',
          //         style: TextStyle(
          //             color: textColor,
          //             fontSize: 13.sp,
          //             fontWeight: FontWeight.w500),
          //       ),
          //       style: TextButton.styleFrom(
          //           shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(5))),
          //       onPressed: () {
          //         _showMyDialog();
          //       },
          //     ),
          //   ],
          // ),
        ),
        Padding(
          padding:
              EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h, bottom: 1.h),
          child: Divider(color: Colors.grey.shade600),
        ),
        Padding(
          padding:
              EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h, bottom: 1.h),
          child: Text(
            'Refrence List',
            style: TextStyle(
                color: textColor, fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
        ),
        ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 0.5.h),
          children:
              data6 // Loops through dataColumnText, each iteration assigning the value to element
                  .map(
                    ((element) => listTile(
                          name: element["student_name"] +
                              " (" +
                              element["course_name"] +
                              ")",
                          email: element["email"],
                          adrs: element["location"],
                          amount: element["amount"],
                          receipt: element["receipt"],
                          m1: element["mobile_no_1"],
                          m2: element["mobile_no_2"],
                          date: DateFormat('dd MMM yyyy')
                              .format(DateTime.parse(element['date'])),
                        )),
                  )
                  .toList(),
        )
      ]),
      // body: SafeArea(
      //   child: SingleChildScrollView(
      //     scrollDirection: Axis.horizontal,
      //     child: DataTable(
      //       columnSpacing: 30,
      //       headingRowHeight: 40,
      //       dataRowHeight: 100,
      //       horizontalMargin: 5,
      //       headingTextStyle: const TextStyle(
      //           fontWeight: FontWeight.bold, color: Colors.black),
      //       headingRowColor: MaterialStateProperty.resolveWith(
      //           (states) => Colors.grey.shade300),
      //       columns: const [
      //         DataColumn(label: Text('#')),
      //         DataColumn(label: Text('Student Name')),
      //         DataColumn(label: Text('Class')),
      //         DataColumn(label: Text('Course Name')),
      //         DataColumn(label: Text('Email')),
      //         DataColumn(label: Text('Mobile 1')),
      //         DataColumn(label: Text('Mobile 2')),
      //         DataColumn(label: Text('Location')),
      //         DataColumn(label: Text('Date'))
      //       ],
      //       rows:
      //           data6 // Loops through dataColumnText, each iteration assigning the value to element
      //               .map(
      //                 ((element) => DataRow(
      //                       cells: <DataCell>[
      //                         DataCell(Text(
      //                             (data6.indexOf(element) + 1).toString())), //
      //                         DataCell(Text(element[
      //                             "student_name"])), //Extracting from Map element the value
      //                         DataCell(Text(element["class"])),
      //                         DataCell(Text(element["course_name"])),
      //                         DataCell(Text(element["email"])),
      //                         DataCell(Text(element["mobile_no_1"])),
      //                         DataCell(Text(element["mobile_no_2"])),
      //                         DataCell(Text(element["location"])),
      //                         DataCell(Text(element["date"]))
      //                       ],
      //                     )),
      //               )
      //               .toList(),
      //     ),
      //   ),
      // ),
    );
  }

  Widget listTile(
      {String? name,
      String? email,
      String? date,
      String? adrs,
      String? amount,
      String? receipt,
      String? m1,
      String? m2,
      int? index}) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedInndex = index!;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.h),
        height: 24.h,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/ref_tile_img.png'),
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          color: Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name ?? '',
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: textColor,
                          fontWeight: FontWeight.w500)),
                  Text("Amount",
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(email ?? '',
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400)),
                      Text("₹${amount!}",
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  Text(date ?? '',
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Receipt: ",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 11.sp,
                        color: textColor,
                        fontWeight: FontWeight.w400),
                  ),
                  if (receipt != null)
                    GestureDetector(
                      onTap: () {
                        launch("${ApiService.careerdefenceacademy2}includes/uploads/student_references/$receipt");
                      },
                      child: Text(
                        "Click here",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/call.png'),
                  SizedBox(
                    width: 2.w,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(m1 ?? '',
                          style: TextStyle(
                              fontSize: 11.5.sp,
                              color: textColor,
                              fontWeight: FontWeight.w500)),
                      Text(m2 ?? '',
                          style: TextStyle(
                              fontSize: 11.5.sp,
                              color: textColor,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Student Details'),
          content: SingleChildScrollView(
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
                            color: Colors.black,
                            // height: 0.5,
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Student Name field can\'t be empty'
                              : null,
                          onSaved: (value) {
                            _authData["student_name"] = value!;
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            hintText: "Student Name",
                            hintStyle:
                                TextStyle(fontSize: 14.0, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            hintText: "Apply For Class",
                            hintStyle:
                                TextStyle(fontSize: 14.0, color: Colors.black),
                          ),
                          isExpanded: true,
                          dropdownColor: Colors.blue,
                          initialValue: defaultCourse == "" ? null : defaultCourse,
                          onChanged: (value) {
                            setState(() {
                              _authData["course_name"] = value!;
                            });
                          },
                          validator: (value) {
                            print(value);
                            if (value == null) {
                              return 'Please select class';
                            }

                            return null;
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
                            'Class 12',
                          ]
                              .map<DropdownMenuItem<String>>(
                                  (value) => DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: const TextStyle(
                                                color: Colors.black)),
                                      ))
                              .toList(),
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
                          onSaved: (value) {
                            _authData["email"] = value!;
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            hintText: "Email",
                            hintStyle:
                                TextStyle(fontSize: 14.0, color: Colors.black),
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
                            if (value!.isEmpty) return 'Mobile can\'t be empty';

                            if (value.length < 10) {
                              return 'Mobile length should be 10';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            _authData["mobile_no_1"] = value!;
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            hintText: "Mobile No.",
                            hintStyle:
                                TextStyle(fontSize: 14.0, color: Colors.black),
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
                            if (value!.isEmpty && value.length < 10) {
                              return 'Mobile length should be 10';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            _authData["mobile_no_2"] = value!;
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            hintText: "Mobile No. 2",
                            hintStyle:
                                TextStyle(fontSize: 14.0, color: Colors.black),
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
                          onSaved: (value) {
                            _authData["location"] = value!;
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            hintText: "Location",
                            hintStyle:
                                TextStyle(fontSize: 14.0, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: 200,
                          height: 44,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                            onPressed: _submit,
                            child: const Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ]))),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
