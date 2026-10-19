import 'dart:io';

import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerapp/screens/App.dart';
import 'package:careerapp/screens/login.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class StaffLogin extends StatefulWidget {
  static const String routeName = '/stafflogin';

  const StaffLogin({Key? key}) : super(key: key);
  @override
  _StaffLoginState createState() => _StaffLoginState();
}

class _StaffLoginState extends State<StaffLogin> with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final _authData = {'email': '', 'password': ''};
  late String _errorMessage;
  bool _showPassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    _errorMessage = "";
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid form
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
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
          '/login',
          data,
        );

        if (response["error"] == false) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('staffData', json.encode(response["data"]));
          print(prefs.getString('staffData'));

          var fcmToken = prefs.getString('fcm_token');
          if (fcmToken != null && fcmToken.isNotEmpty) {
            saveFCMToken(response["data"]["user_id"], fcmToken);
          }

          Navigator.of(context)
              .pushNamedAndRemoveUntil(App.routeName, (r) => false);
        } else {
          setState(() {
            _errorMessage = "Invalid email and password!";
            _isLoading = false;
          });
          
          Fluttertoast.showToast(
              msg: "Invalid email and password!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } catch (err) {
        setState(() {
          _errorMessage = "Connection error. Please try again.";
          _isLoading = false;
        });
        print(err);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  saveFCMToken(userId, fcmToken) async {
    var platformType = "";
    if (Platform.isAndroid) {
      platformType = "Android";
    } else if (Platform.isIOS) {
      platformType = "IOS";
    }

    var data = json.encode({
      'user_id': userId,
      'user_type': 'staff',
      'token': fcmToken,
      'platform': platformType
    });
    print(data);
    try {
      await ApiService.postMethod3('/fcmToken', data);
    } catch (err) {
      print(err);
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
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E), // Deep indigo
              Color(0xFF3949AB), // Indigo
              Color(0xFF303F9F), // Dark indigo
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with shadow
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/logo.png',
                          height: size.height * 0.15,
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Title with animation
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [Colors.white, Color(0xFFE0E0E0)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds);
                        },
                        child: const Text(
                          "CAREER APP",
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      
                      Text(
                        "STAFF LOGIN",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Login card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email label
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                                child: Text(
                                  "Email Address",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              
                              // Email field
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: emailController,
                                  textInputAction: TextInputAction.next,
                                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email field can\'t be empty';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _authData['email'] = value!;
                                  },
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 16.0, 
                                      horizontal: 16.0
                                    ),
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: Colors.white70,
                                    ),
                                    hintText: "Enter your email",
                                    hintStyle: TextStyle(
                                      fontSize: 14.0, 
                                      color: Colors.white60
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Password label
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                                child: Text(
                                  "Password",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              
                              // Password field
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: passwordController,
                                  obscureText: _showPassword,
                                  keyboardType: TextInputType.visiblePassword,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password field can\'t be empty';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _authData['password'] = value!;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16.0, 
                                      horizontal: 16.0
                                    ),
                                    border: InputBorder.none,
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: Colors.white70,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _showPassword 
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        setState(() => _showPassword = !_showPassword);
                                      },
                                    ),
                                    hintText: "Enter your password",
                                    hintStyle: const TextStyle(
                                      fontSize: 14.0, 
                                      color: Colors.white60
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 10),
                              
                              // Forgot password
                              // Align(
                              //   alignment: Alignment.centerRight,
                              //   child: TextButton(
                              //     onPressed: () {
                              //       // Add forgot password functionality
                              //     },
                              //     child: Text(
                              //       "Forgot Password?",
                              //       style: TextStyle(
                              //         color: Colors.white70,
                              //         fontSize: 13,
                              //         fontWeight: FontWeight.w500,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              
                              const SizedBox(height: 10),
                              
                              // Error message
                              if (_errorMessage.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage,
                                          style: const TextStyle(
                                            fontSize: 13.0,
                                            color: Colors.red,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              const SizedBox(height: 24),
                              
                              // Login button
                              _buildGradientButton(
              text: "LOGIN",
              isLoading: _isLoading,
              onPressed: _submit,
            ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.school_outlined),
                        label: const Text('STUDENT LOGIN'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white60),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Need help text
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text(
                      //       "Need help? ",
                      //       style: TextStyle(
                      //         color: Colors.white70,
                      //         fontSize: 14,
                      //       ),
                      //     ),
                      //     GestureDetector(
                      //       onTap: () {
                      //         // Add contact support functionality
                      //       },
                      //       child: Text(
                      //         "Contact Support",
                      //         style: TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 14,
                      //           fontWeight: FontWeight.w600,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

 Widget _buildGradientButton({
  required String text,
  required VoidCallback onPressed,
  bool isLoading = false,
}) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4A148C), // Deep purple
              Color(0xFF7B1FA2), // Purple
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
        ),
      ),
    ),
  );
}
