import 'package:flutter/material.dart';

import '../../../core/constant/constant.dart';
import '../widgets/body_signup.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "حساب جديد",
          style: TextStyle(
              fontSize: kFontSize19, fontWeight: FontWeight.w700, height: 0),
        ),
      ),
      body: const BodySignUp(),
    );
  }
}
