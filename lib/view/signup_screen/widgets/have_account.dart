import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/constant/constant.dart';




class HaveAnAccountWidget extends StatelessWidget {
  const HaveAnAccountWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "هل تمتلك حساب بالفعل؟",
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
                 Navigator.pop(context);
              },
            text:"تسجيل الدخول",
            style:
            const TextStyle(color: kPrimaryColor),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}