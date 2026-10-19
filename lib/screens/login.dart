import 'package:flutter/material.dart';
import 'package:careerapp/screens/login2.dart';

/// The default login route opens the student email/password login screen.
class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const Login2Screen();
}
