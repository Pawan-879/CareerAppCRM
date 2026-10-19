import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';

class StudentRequirements extends StatefulWidget {
  static const routeName = '/StudentRequirements';

  const StudentRequirements({Key? key}) : super(key: key);

  @override
  _StudentRequirementsState createState() => _StudentRequirementsState();
}

class _StudentRequirementsState extends State<StudentRequirements> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _authData = {
    'user_id': 0,
    'item_name': '',
    'month_name': '',
    'quantity': ''
  };
  var defaultCourse = 'October Requirements';
  var data6 = [];
  var heading = "Requirements";
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
        await ApiService.getMethod3("/getRequirements?user_id=" + data["id"]);
    dynamic d = jsonDecode(res.body);
    setState(() {
      data6 = d["data"];
    });

    _authData['user_id'] = data["id"];
    _authData['month_name'] = defaultCourse;
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
          '/saveStudentRequirement',
          data,
        );

        if (response["error"] == false) {
          Navigator.of(context).pop();
          Fluttertoast.showToast(
              msg: "Requirement added successfully", timeInSecForIosWeb: 10);
          getData();
        } else {
          Fluttertoast.showToast(
              msg: "Requirement already exist!", timeInSecForIosWeb: 10);
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
                "You have " + data6.length.toString() + ' Requirements',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp),
              ),
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
        Padding(
          padding:
              EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h, bottom: 1.h),
          child: Text(
            'Requirements List',
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
                          month: element["month_name"],
                          itemname: element["item_name"],
                          qunatity: element["quantity"],
                          date: DateFormat('dd MMM yyyy')
                              .format(DateTime.parse(element['date'])),
                        )),
                  )
                  .toList(),
        )
      ]),
    );
  }

  Widget listTile(
      {String? month, String? itemname, String? qunatity, String? date}) {
    return InkWell(
      onTap: () {
        setState(() {});
      },
      child: GestureDetector(
          onTap: () {},
          child: Container(
              margin: EdgeInsets.only(bottom: 2.h),
              height: 12.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 3,
                  ),
                ],
                borderRadius: const BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: 1.5.h,
                        left: 2.h,
                        right: 2.h,
                        bottom: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(100.0),
                            bottomRight: Radius.circular(100.0),
                            bottomLeft: Radius.circular(100.0)),
                      ),
                      child: const Text(
                        '*',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemname.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                  fontSize: 14.sp),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Text(
                              month.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  fontSize: 10.sp),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 24.w,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Qty: $qunatity',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                  fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]))),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Requirements'),
          content: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                            hintText: "Select Month",
                            hintStyle:
                                TextStyle(fontSize: 14.0, color: Colors.black),
                          ),
                          isExpanded: true,
                          dropdownColor: Colors.blue,
                          initialValue: defaultCourse == "" ? null : defaultCourse,
                          onChanged: (value) {
                            setState(() {
                              _authData["month_name"] = value!;
                            });
                          },
                          validator: (value) {
                            print(value);
                            if (value == null) {
                              return 'Please select month';
                            }

                            return null;
                          },
                          items: <String>[
                            'June Requirements',
                            'August Requirements',
                            'October Requirements',
                            'January Requirements',
                            'March Requirements'
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
                          validator: (value) => value!.isEmpty
                              ? 'Item Name field can\'t be empty'
                              : null,
                          onSaved: (value) {
                            _authData["item_name"] = value!;
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            hintText: "Item Name",
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
                            return null;
                          },
                          onSaved: (value) {
                            _authData["quantity"] = value!;
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            hintText: "Quantity",
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
