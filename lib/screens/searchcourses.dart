import 'package:flutter/material.dart';
import 'package:careerapp/screens/paidcategory.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Searchcourses extends StatefulWidget {
  static const routeName = '/searchcourses';

  const Searchcourses({Key? key}) : super(key: key);
  @override
  _SearchcoursesState createState() => _SearchcoursesState();
}

class _SearchcoursesState extends State<Searchcourses> {
  final search = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _authData = {'search': ''};
  bool isLoading = false;
  var data2 = [];
  String query = "";
  var data;
  @override
  void initState() {
    super.initState();
    isLoading = true;
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      _authData['search'] = data;
      search.text = data;
      getData(data);
    });
  }

  void _submit() async {
    _formKey.currentState!.save();
    isLoading = true;
    query = _authData['search']!;
    print(query);
    getData(query);
  }

  getData(data) async {
    var res2 = await ApiService.getMethod("/searchCourses?search=$data");
    data2 = jsonDecode(res2.body);
    print(data2);
    setState(() {
      isLoading = false;
    });
  }

  showCircularProgress() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Searched Courses"),
          actions: const [],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 0, bottom: 0),
                child: Form(
                  key: _formKey,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 16, top: 0, bottom: 8),
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
                                controller: search,
                                onSaved: (value) {
                                  _authData['search'] = value!;
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                offset: const Offset(0, 2),
                                blurRadius: 8.0),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(32.0),
                            ),
                            onTap: () {
                              _submit();
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Icon(FontAwesomeIcons.magnifyingGlass,
                                  size: 20, color: Color(0xFFFFFFFF)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: isLoading == true
                    ? showCircularProgress()
                    : ListView.builder(
                        padding: const EdgeInsets.all(0),
                        itemCount: data2.length,
                        itemBuilder: (BuildContext context, int i) {
                          return _courseCard(data2[i]);
                        },
                      ),
              ),
            ],
          ),
        ));
  }

  _courseCard(dynamic param) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Paidcategory.routeName, arguments: param);
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10, top: 10),
        child: Container(
          width: 230.0,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  offset: const Offset(0, 2),
                  blurRadius: 8.0),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15)),
                child: Image.network(
                    "${ApiService.websiteUrl}subcat-images/" + param["image"],
                    fit: BoxFit.fill),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                child: Text(
                  param["sub_cat_name"],
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("Rs." + param["mrp"],
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                child: Text(
                  "Rs." + param["our_price"],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
