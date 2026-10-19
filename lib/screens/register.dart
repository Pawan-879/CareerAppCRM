import 'package:flutter/material.dart';
import 'package:careerapp/screens/login.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var emailController = TextEditingController();
  var referralController = TextEditingController();
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
  bool isLoading = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getData();
    errorMessage = "";
  }

  launchURL() async {
    String url = "https://careerdefenceschool.com/terms-of-use.php";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _submit() async {
    setState(() {
      isLoading = true;
    });
    
    _formKey.currentState!.save();
    if (validateAndSave()) {
      var data = json.encode({
        'full_name': _authData['full_name'],
        'studyingin': studyingin,
        'category': class1,
        'email': _authData['email'],
        'phone': _authData['phone'],
        'referral': _authData['referral'],
        'password': _authData['password']
      });

      try {
        var response = await ApiService.postMethod(
          '/signup',
          data,
        );

        setState(() {
          isLoading = false;
        });

        if (response["status"] == "1") {
          // Show success animation
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Registration Successful!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Your account has been created successfully.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            LoginScreen.routeName, (r) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: const Text(
                        "Continue to Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          // Show error toast with improved styling
          Fluttertoast.showToast(
            msg: "User already exists!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red[800],
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (err) {
        setState(() {
          isLoading = false;
        });
        print(err);
        Fluttertoast.showToast(
          msg: "Registration failed. Please try again.",
          backgroundColor: Colors.red[800],
          textColor: Colors.white,
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  getData() async {
    try {
      var res2 = await ApiService.getMethod("/getAppCategories");
      dynamic mydata2 = json.decode(res2.body);
      classes = mydata2["detail"];
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF303F9F),
              Color(0xFF3949AB),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Logo and Header
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Image.asset(
                      'assets/logo.png',
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 15),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                    child: const Text(
                      "CREATE YOUR ACCOUNT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInDown(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      "Join our community of learners today",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Registration Form
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Student Name Field
                            _buildFormLabel("Student Name"),
                            _buildTextField(
                              hintText: "Enter your full name",
                              prefixIcon: Icons.person_outline,
                              validator: (value) => value!.isEmpty
                                  ? 'Student Name field can\'t be empty'
                                  : null,
                              onSaved: (value) {
                                _authData['full_name'] = value!;
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // School Selection Dropdown
                            _buildFormLabel("School"),
                            _buildDropdown(
                              hintText: "Select your school",
                              prefixIcon: Icons.school_outlined,
                              value: studyingin == "" ? null : studyingin,
                              items: <String>[
                                'Career Defence School',
                                'Other School'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select school';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  studyingin = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // Course Interested Dropdown
                            _buildFormLabel("Course Interested"),
                            _buildDropdown(
                              hintText: "Select course",
                              prefixIcon: Icons.book_outlined,
                              value: class1 == "" ? null : class1,
                              items: classes
                                  .map<DropdownMenuItem<String>>(
                                      (value) => DropdownMenuItem<String>(
                                            value: value["id"],
                                            child: Text(
                                              value["category_name"],
                                              style: const TextStyle(
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ))
                                  .toList(),
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select Course Interested';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  class1 = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // Mobile Number Field
                            _buildFormLabel("Mobile Number"),
                            _buildTextField(
                              hintText: "Enter your 10-digit mobile number",
                              prefixIcon: Icons.phone_android_outlined,
                              keyboardType: TextInputType.number,
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
                            ),
                            const SizedBox(height: 20),
                            
                            // Email Address Field
                            _buildFormLabel("Email Address"),
                            _buildTextField(
                              controller: emailController,
                              hintText: "Enter your email address",
                              prefixIcon: Icons.email_outlined,
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
                            ),
                            const SizedBox(height: 20),
                            
                            // Password Field
                            _buildFormLabel("Password"),
                            _buildTextField(
                              hintText: "Create a password (min. 8 characters)",
                              prefixIcon: Icons.lock_outline,
                              obscureText: _showPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() => _showPassword = !_showPassword);
                                },
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
                            ),
                            const SizedBox(height: 20),
                            
                            // Referral Code Field
                            _buildFormLabel("Referral Code (Optional)"),
                            _buildTextField(
                              controller: referralController,
                              hintText: "Enter referral code if you have one",
                              prefixIcon: Icons.card_giftcard_outlined,
                              onSaved: (value) {
                                _authData['referral'] = value!;
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // Terms and Conditions Checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Theme(
                                  data: ThemeData(
                                    checkboxTheme: CheckboxThemeData(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    unselectedWidgetColor: Colors.white70,
                                  ),
                                  child: Checkbox(
                                    activeColor: const Color(0xFF1E88E5),
                                    checkColor: Colors.white,
                                    value: acceptTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        acceptTerms = value!;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: "I have read and agree to the ",
                                        ),
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () {
                                              launchURL();
                                            },
                                            child: const Text(
                                              "terms of use",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            
                            // Register Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (acceptTerms) {
                                    _submit();
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "Please accept the terms of use.",
                                      backgroundColor: Colors.red[800],
                                      textColor: Colors.white,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E88E5),
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      )
                                    : const Text(
                                        "REGISTER ACCOUNT",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushReplacementNamed(
                                        LoginScreen.routeName);
                                  },
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build form labels
  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField({
    required String hintText,
    required IconData prefixIcon,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white60,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.white70,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.red.shade300,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.red.shade300,
            width: 1.5,
          ),
        ),
        errorStyle: TextStyle(
          color: Colors.red.shade300,
          fontSize: 12,
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  // Helper method to build dropdowns
  Widget _buildDropdown({
    required String hintText,
    required IconData prefixIcon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required String? Function(String?)? validator,
    required void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      validator: validator,
      onChanged: onChanged,
      icon: const Icon(
        Icons.arrow_drop_down,
        color: Colors.white70,
      ),
      dropdownColor: const Color(0xFF303F9F),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white60,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.white70,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.red.shade300,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.red.shade300,
            width: 1.5,
          ),
        ),
        errorStyle: TextStyle(
          color: Colors.red.shade300,
          fontSize: 12,
        ),
      ),
    );
  }
}