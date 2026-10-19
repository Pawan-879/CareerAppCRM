import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_services.dart';

class ConsultantLeads extends StatefulWidget {
  static const String routeName = '/consultant-leads';
  const ConsultantLeads({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _ConsultantLeadsState createState() => _ConsultantLeadsState();
}

class _ConsultantLeadsState extends State<ConsultantLeads>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var defaultCourse = "Not Working";
  var textcontroller = TextEditingController();
  var type = "";
  var tab_name = "";
  late TabController _tabController;
  var data = [];
  var allleads = [];
  var myleads = [];
  dynamic consultants = [];
  var search = "";
  final _authData = {'id': '', 'status': '', 'remark': ''};

  final scrollController = ScrollController();
  var staff_id, parent_id;
  var page = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(_handleTabSelection);
    getUserData();
    scrollAction();
  }

  scrollAction() {
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        page++;
        getMyStudents(staff_id, page, '');
      }
    });
  }

  getUserData() async {
    data = [];
    page = 1;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('consulData') &&
        prefs.getString('consulData') != '') {
      var staffData = json.decode(prefs.getString('consulData')!);

      if (staffData["id"] != '') {
        staff_id = staffData["id"];
        parent_id = staffData["parent_id"];
      }
      getMyStudents(staff_id, page, '');
      setState(() {});
    }
  }

  getMyStudents(id, p, search) async {
    if (parent_id == '0') {
      var res = await ApiService.getMethod3("${"/getParentConsulLeads?id=" +
          id}&page=$p&search=" +
          search);
      var d = jsonDecode(res.body)["data"];

      data.addAll(d);
    } else {
      var res = await ApiService.getMethod3("${"/getChildConsulLeads?id=" +
          id}&page=$p&search=" +
          search);

      var d = jsonDecode(res.body)["data"];

      data.addAll(d);
    }
    setState(() {});
  }

  void _handleTabSelection() {
    page = 1;
    data = [];

    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          setState(() {
            getMyStudents(staff_id, page, '');
          });
          break;
        case 1:
          setState(() {});
          break;
      }
    }
  }

  submit() async {
    var data1 = json.encode(_authData);

    try {
      var response = await ApiService.postMethod3(
        '/updateLead',
        data1,
      );

      if (response["error"] == false) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "Lead updated successfully", timeInSecForIosWeb: 10);

        page = 1;
        data = [];

        getMyStudents(staff_id, page, '');
      }
    } catch (err) {
      print(err);
    }
  }

  showSubConsultants() async {
    print(staff_id);
    try {
      var res = await ApiService.getMethod3(
          "/getSubConsultants?parent_id=" + staff_id);
      var d = jsonDecode(res.body)["data"];
      consultants = d;

      _showMyDialog2(d);
      setState(() {});
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xfff4f4f4),
        appBar: AppBar(
          title: const Text(
            "Leads",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 15),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
            margin: const EdgeInsets.only(top: 20),
            child: SingleChildScrollView(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 0, bottom: 0),
                  child: Form(
                    key: _formKey,
                    child: Row(
                      children: <Widget>[
                        if (parent_id == '0')
                          IconButton(
                            icon: const Icon(Icons.people, size: 30),
                            onPressed: () {
                              showSubConsultants();
                            },
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 16, top: 0, bottom: 8, left: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      offset: const Offset(0, 2),
                                      blurRadius: 8.0),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 4, bottom: 4),
                                child: TextFormField(
                                  onFieldSubmitted: (value) {
                                    page = 1;
                                    data = [];

                                    getMyStudents(staff_id, page, value);
                                  },
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                  cursorColor: const Color(0xFF54D3C2),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search Course Here...',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                    height: 550,
                    child: ListView.builder(
                      controller: scrollController,
                      scrollDirection: Axis.vertical,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return mystudent(context, data[index], index);
                      },
                    ))
              ],
            ))));
  }

  mystudent(context, data, index) {
    return Container(
        margin: const EdgeInsets.only(top: 5),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Text(
            "${index + 1}.",
            style: const TextStyle(fontSize: 18),
          ),
          title: Row(children: [
            Text(data["student_name"]),
            const SizedBox(width: 10),
            if (data["status"] == "0")
              Container(
                  padding: const EdgeInsets.all(3),
                  color: Colors.cyan,
                  child: const Text("Not worked",
                      style: TextStyle(fontSize: 11, color: Colors.white))),
            if (data["status"] == "1")
              Container(
                  padding: const EdgeInsets.all(3),
                  color: Colors.green,
                  child: const Text("Converted",
                      style: TextStyle(fontSize: 11, color: Colors.white))),
            if (data["status"] == "2")
              Container(
                  padding: const EdgeInsets.all(3),
                  color: Colors.yellow,
                  child: const Text("In Progress", style: TextStyle(fontSize: 11))),
            if (data["status"] == "3")
              Container(
                  padding: const EdgeInsets.all(3),
                  color: Colors.red,
                  child: const Text("Not interested",
                      style: TextStyle(fontSize: 11, color: Colors.white))),
          ]),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Father Name: " + data["father_name"]),
              Text("Mobile No.: " + data["mobile1"]),
              const SizedBox(height: 5),
              if (data["name"].toString() != 'null')
                Text(
                  "Consultant: " + data["name"],
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                )
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () {
              _showMyDialog(data);
            },
            child: const Text('Action'),
          ),
        ));
  }

  getStatus(val) {
    if (val == '0') {
      return "Not worked";
    } else if (val == '1') {
      return "Converted";
    } else if (val == '2') {
      return "In progress";
    } else {
      return "Not interested";
    }
  }

  _showMyDialog(data) async {
    print(data);
    var values = "";
    _authData['remark'] = data["remark"] ?? '';
    _authData["id"] = data["id"];
    if (data["status"] == "0") values = "Not Worked";
    if (data["status"] == "1") values = "Converted";
    if (data["status"] == "2") values = "In Progress";
    if (data["status"] == "3") values = "Not Interested";
    textcontroller.text = data["remark"] ?? '';
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('Update Lead'),
            content: SizedBox(
                height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _authData['remark'] = value;
                        });
                      },
                      controller: textcontroller,
                      keyboardType: TextInputType.multiline,
                      minLines: 4,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Remarks',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Status"),
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
                        hintText: "Select School",
                        hintStyle:
                            TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                      isExpanded: true,
                      dropdownColor: Colors.blue,
                      initialValue: values,
                      validator: (value) {
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _authData["status"] = value!;
                        });
                      },
                      items: <String>[
                        'Not Worked',
                        'Converted',
                        'In Progress',
                        'Not Interested'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        onPressed: () {
                          submit();
                        },
                        child: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )));
      },
    );
  }

  _showMyDialog2(data2) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('Sub Consultants'),
            content: SizedBox(
                height: 300,
                width: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: scrollController,
                  scrollDirection: Axis.vertical,
                  itemCount: data2.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Text("${index + 1}."),
                      title: Text(data2[index]["name"]),
                      subtitle: Text(data2[index]["mobile"]),
                    );
                  },
                )));
      },
    );
  }
}
