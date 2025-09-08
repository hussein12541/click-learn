import 'package:flutter/material.dart';

import '../../../core/constant/constant.dart';
import '../widgets/login_view_body.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("تسجيل الدخول",style:  TextStyle(fontSize: kFontSize19,fontWeight: FontWeight.w700,height: 0),),
        automaticallyImplyLeading: false,

      ),
      body: const LoginViewBody(),
    );
  }
}
