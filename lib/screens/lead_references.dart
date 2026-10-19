import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';

class LeadReferences extends StatefulWidget {
  static const routeName = '/LeadReferences';

  const LeadReferences({Key? key}) : super(key: key);

  @override
  _LeadReferencesState createState() => _LeadReferencesState();
}

class _LeadReferencesState extends State<LeadReferences> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _authData = {
    'appointment_id': '',
    'student_name': '',
    'father_name': '',
    'class_name': '',
    'mobile': '',
    'lead_type': '',
    'location': ''
  };

  var data6 = [];
  var heading = "References";
  var userData;
  var user_id;

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
        await ApiService.getMethod3("/getLeadReferences?id=" + data["id"]);
    dynamic d = jsonDecode(res.body);
    setState(() {
      data6 = d["data"];
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
      _authData["appointment_id"] = data["id"];
      var request = json.encode(_authData);
      print(_authData);
      try {
        var response = await ApiService.postMethod3(
          '/saveLeadReference',
          request,
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
                'References!',
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Students/References',
                style: TextStyle(
                    color: textColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600),
              )
            ],
          ),
          trailing: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0.5.h),
                child: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                onPressed: () {
                  _showMyDialog();
                },
                child: Text(
                  '+ Add',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h, bottom: 1.h),
          child: Divider(color: Colors.grey.shade600),
        ),
        SizedBox(
            height: 550,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 0.5.h),
              children:
                  data6 // Loops through dataColumnText, each iteration assigning the value to element
                      .map(
                        ((element) => listTile(
                              name: element["student_name"] +
                                  " (" +
                                  element["father_name"] +
                                  ")",
                              father_name: element["father_name"],
                              location: element["location"],
                              class_name: element["class"],
                              m1: element["mobile"],
                              date: DateFormat('dd MMM yyyy')
                                  .format(DateTime.parse(element['created'])),
                              type: element["type"],
                            )),
                      )
                      .toList(),
            ))
      ]),
    );
  }

  Widget listTile(
      {String? name,
      String? father_name,
      String? location,
      String? class_name,
      String? m1,
      String? date,
      String? type,
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
                  Text(class_name ?? '',
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
                      Text(' ',
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  Text(date ?? '',
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400)),
                  const SizedBox(height: 5),
                  Text("Location: ${location ?? ''}",
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type ?? '',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 11.sp,
                        color: textColor,
                        fontWeight: FontWeight.w400),
                  ),
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
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          style: const TextStyle(
                            color: Colors.black,
                            // height: 0.5,
                          ),
                          onSaved: (value) {
                            _authData["father_name"] = value!;
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            hintText: "Father Name",
                            hintStyle:
                                TextStyle(fontSize: 14.0, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            hintText: "Class",
                            hintStyle:
                                TextStyle(fontSize: 14.0, color: Colors.black),
                          ),
                          isExpanded: true,
                          dropdownColor: Colors.blue,
                          initialValue: null,
                          onChanged: (value) {
                            setState(() {
                              _authData["class_name"] = value!;
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
                          keyboardType: TextInputType.number,
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          style: const TextStyle(
                            color: Colors.black,
                            // height: 0.5,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return 'Mobile can\'t be empty';

                            if (value.length != 10) {
                              return 'Mobile length should be 10';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            _authData["mobile"] = value!;
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
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            hintText: "Reference",
                            hintStyle:
                                TextStyle(fontSize: 14.0, color: Colors.black),
                          ),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          initialValue: null,
                          validator: (value) {
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _authData['lead_type'] = value!;
                            });
                          },
                          items: <String>['Student', 'Reference']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          style: const TextStyle(
                            color: Colors.black,
                            // height: 0.5,
                          ),
                          validator: (value) {
                            return null;
                          },
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
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 200,
                          height: 44,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                            onPressed: () {
                              _submit();
                            },
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
