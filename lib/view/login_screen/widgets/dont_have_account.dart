import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/constant/constant.dart';
import '../../signup_screen/views/signup_view.dart';



class DontHaveAnAccountWidget extends StatelessWidget {
  const DontHaveAnAccountWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "لا تمتلك حساب؟",
            style: const TextStyle(
              color: Color(0xFF949D9E),
            ),
          ),
          const TextSpan(
            text: ' ',
            style: TextStyle(
              color: Color(0xFF616A6B),
            ),
          ),
          TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpView(),));
              },
            text:"قم بإنشاء حساب",
            style:
            const TextStyle(color: kPrimaryColor),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}