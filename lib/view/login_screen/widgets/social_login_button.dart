import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton(
      {super.key, this.onPressed, required this.image, required this.title});

  final void Function()? onPressed;
  final String image;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: TextButton(
          style: TextButton.styleFrom(
            shape:  RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: const BorderSide(
                color: Color(0xffdcdede),
              ),
            ),
          ),
          onPressed: onPressed,
        child: ListTile(
          visualDensity: const VisualDensity(vertical: VisualDensity.minimumDensity),
          leading: SvgPicture.asset(image),
          title:     Text(title,textAlign: TextAlign.center,),
    ),
    ));
  }
}
