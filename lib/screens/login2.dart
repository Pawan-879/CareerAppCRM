import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerapp/screens/App.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:careerapp/screens/staff_login.dart';
// import 'package:google_fonts/google_fonts.dart';

class Login2Screen extends StatefulWidget {
  static const String routeName = '/login2';
  const Login2Screen({Key? key}) : super(key: key);

  @override
  _Login2ScreenState createState() => _Login2ScreenState();
}

class _Login2ScreenState extends State<Login2Screen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var forgotEmailController = TextEditingController();
  var otpController = TextEditingController();
  final _authData = {'email': '', 'password': ''};
  bool _showPassword = true;
  bool _isForgotPassword = false;
  bool _isOtpSent = false;
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _serverOtp = '';
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    otpController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      var data = json.encode({
        'email': _authData['email'],
        'password': _authData['password'],
        'deviceType': 'android'
      });

      setState(() {
        _isLoading = true;
      });

      try {
        var response = await ApiService.postMethod('/login', data);

        if (response["status"] == "1") {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userData', json.encode(response["detail"]));
          print("User Data: ${prefs.getString('userData')}");
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(App.routeName, (r) => false);
          }
        } else {
          _showErrorToast("Invalid email and password!");
        }
      } catch (err) {
        print(err);
        _showErrorToast("Connection error. Please try again.");
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _forgotPassword() async {
    if (forgotEmailController.text.isEmpty || phoneController.text.isEmpty) {
      _showErrorToast("Email and Phone fields can't be empty");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var data = json.encode({
      'email': forgotEmailController.text,
      'user_phone': phoneController.text,
    });

    try {
      var response = await ApiService.postMethod('/forgot', data);
      print("Raw API Response: $response");

      if (response == null) {
        _showErrorToast("Server did not respond.");
        return;
      }

      if (response["status"] == "1") {
        setState(() {
          _isOtpSent = true;
          _serverOtp = response["otp"].toString();
        });
        _showSuccessToast("OTP Sent! Check your phone.");
      } else {
        _showErrorToast("Failed to send OTP. Try again.");
      }
    } catch (err) {
      print("Error: $err");
      _showErrorToast("Error sending OTP. Check your internet.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _verifyOtp() async {
    if (otpController.text.isEmpty) {
      _showErrorToast("Please enter the OTP");
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    if (otpController.text == _serverOtp) {
      _showSuccessToast("OTP Verified!");

      // Simulate login after OTP by fetching user detail again or use stored detail
      var data = json.encode({'email': forgotEmailController.text});
      
      try {
        var response = await ApiService.postMethod('/forgot', data);

        if (response["status"] == "1") {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userData', json.encode(response["detail"]));

          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(App.routeName, (r) => false);
          }
        } else {
          _showErrorToast("Failed to verify user after OTP");
        }
      } catch (e) {
        print("Error: $e");
        _showErrorToast("Something went wrong. Try again.");
      }
    } else {
      _showErrorToast("Invalid OTP");
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E), // Deep indigo
              Color(0xFF303F9F), // Indigo
              Color(0xFF3949AB), // Lighter indigo
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
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with shadow and animation
                        Container(
                          height: 120,
                          width: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Hero(
                            tag: 'logo',
                            child: Image.asset('assets/logo.png'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // App Title
                        const Text(
                          "CAREER APP",
                          style: TextStyle(
  color: Colors.white,
  fontSize: 28.0,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.5,
),

                        ),
                        const Text(
                          "STUDENTS LOGIN",
                         style: TextStyle(
  color: Colors.white,
  fontSize: 28.0,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.5,
),

                        ),
                        const SizedBox(height: 40),
                        
                        // Main Content - Login or Forgot Password
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.1),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _isForgotPassword 
                              ? _buildForgotPasswordForm() 
                              : _buildLoginForm(),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Switch between login and forgot password
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isForgotPassword = !_isForgotPassword;
                              _isOtpSent = false;
                            });
                          },
                          child: Text(
                            _isForgotPassword ? "Back to Login" : "Forgot Password?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 260,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const StaffLogin(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.badge_outlined),
                            label: const Text('STAFF LOGIN'),
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      key: const ValueKey('loginForm'),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Field
            _buildTextField(
              controller: emailController,
              hintText: "Email Address",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Enter a valid email';
                }
                return null;
              },
              onSaved: (value) {
                _authData['email'] = value!;
              },
            ),
            const SizedBox(height: 16),
            
            // Password Field
            _buildTextField(
              controller: passwordController,
              hintText: "Password",
              prefixIcon: Icons.lock_outline,
              obscureText: _showPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
              onSaved: (value) {
                _authData['password'] = value!;
              },
            ),
            const SizedBox(height: 24),
            
            // Login Button
            _buildGradientButton(
              text: "LOGIN",
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordForm() {
    return Container(
      key: const ValueKey('forgotPasswordForm'),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isOtpSent ? "Verify OTP" : "Reset Password\nFill Any one",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          if (!_isOtpSent) ...[
            // Email Field for Forgot Password
            _buildTextField(
              controller: forgotEmailController,
              hintText: "Email Address",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            
            // Phone Field
            _buildTextField(
              controller: phoneController,
              hintText: "Phone Number",
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            
            // Send OTP Button
            _buildGradientButton(
              text: "SEND OTP",
              isLoading: _isLoading,
              onPressed: _forgotPassword,
            ),
          ] else ...[
            // OTP Field
            _buildTextField(
              controller: otpController,
              hintText: "Enter OTP",
              prefixIcon: Icons.pin_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
            const SizedBox(height: 8),
            
            // Resend OTP option
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : _forgotPassword,
                child: const Text(
                  "Resend OTP",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Verify OTP Button
            _buildGradientButton(
              text: "VERIFY OTP",
              isLoading: _isLoading,
              onPressed: _verifyOtp,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(prefixIcon, color: Colors.white70, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onSaved: onSaved,
      inputFormatters: inputFormatters,
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4A148C), // Deep purple
            Color(0xFF7B1FA2), // Purple
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B1FA2).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
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
    );
  }
}
