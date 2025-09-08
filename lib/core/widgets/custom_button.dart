import 'package:e_learning/core/constant/constant.dart';
import 'package:flutter/material.dart';


class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.onPressed, required this.text});
  final VoidCallback onPressed;
  final String text;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16,
            ),
          ),
          backgroundColor: kDarkPrimaryColor,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style:  TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: kFontSize16,
          ),
        ),
      ),
    );
  }
}