import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class Contactus extends StatefulWidget {
  const Contactus({Key? key}) : super(key: key);

  @override
  _ContactusState createState() => _ContactusState();
}

class _ContactusState extends State<Contactus> {
  final String image = "http://careerinstitute.co/app/ads/cds.jpg";

  final _formKey = GlobalKey<FormState>();
  final _cName = TextEditingController();

  final _cPhoneNumber = TextEditingController();
  final _cEmail = TextEditingController();
  final _cAddress = TextEditingController();
  final _cQuery = TextEditingController();

  final _authData = {
    'name': '',
    'email': '',
    'phone': '',
    'address': '',
    'query': ''
  };

  @override
  void initState() {
    super.initState();
  }

  void _submit() async {
    _formKey.currentState?.save();
    if (validateAndSave()) {
      var data = json.encode({
        'name': _authData['name'],
        'email': _authData['email'],
        'phone': _authData['phone'],
        'address': _authData['address'],
        'query': _authData['query']
      });

      // print(data);
      try {
        var response = await ApiService.postMethod(
          '/contactus',
          data,
        );

        if (response["status"] == "1") {
          Fluttertoast.showToast(
              msg: "Your query submitted successfully.",
              timeInSecForIosWeb: 10);
        } else {
          Fluttertoast.showToast(msg: "Error occured!", timeInSecForIosWeb: 10);
        }
      } catch (err) {
        // print(err);
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
    TextFormField inputName = TextFormField(
      controller: _cName,
      autofocus: true,
      keyboardType: TextInputType.text,
      inputFormatters: const [],
      decoration: const InputDecoration(
        labelText: 'Name',
        icon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Name is required';
        }
        return null;
      },
      onSaved: (value) {
        _authData['name'] = value!;
      },
    );

    TextFormField inputPhoneNumber = TextFormField(
      controller: _cPhoneNumber,
      autofocus: true,
      keyboardType: TextInputType.number,
      inputFormatters: const [],
      decoration: const InputDecoration(
        labelText: 'Phone',
        icon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Phone is required';
        }
        return null;
      },
      onSaved: (value) {
        _authData['phone'] = value!;
      },
    );

    TextFormField inputEmail = TextFormField(
      controller: _cEmail,
      inputFormatters: const [],
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'E-mail',
        icon: Icon(Icons.email),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Email is required';
        }
        return null;
      },
      onSaved: (value) {
        _authData['email'] = value!;
      },
    );

    TextFormField inputAddress = TextFormField(
      controller: _cAddress,
      inputFormatters: const [],
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        labelText: 'Address',
        icon: Icon(Icons.web),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Address is required';
        }
        return null;
      },
      onSaved: (value) {
        _authData['address'] = value!;
      },
    );

    TextFormField inputQuery = TextFormField(
      controller: _cQuery,
      inputFormatters: const [],
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        labelText: 'Query',
        icon: Icon(Icons.web),
      ),
      onSaved: (value) {
        _authData['query'] = value!;
      },
    );

    final picture = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Image.network(image, width: double.infinity, fit: BoxFit.fill),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 0, 0, 0),
                      Color.fromARGB(0, 0, 0, 0)
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 20.0),
                child: const Row(
                  children: <Widget>[
                    Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      "CDS | Contact Us",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contact Us",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
         backgroundColor: Colors.blue[500],

        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            picture,
            Padding(
              padding: const EdgeInsets.only(
                  right: 25, top: 15, bottom: 15, left: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    inputName,
                    inputPhoneNumber,
                    inputEmail,
                    inputAddress,
                    inputQuery,
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 200,
                      height: 44,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: _submit,
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
