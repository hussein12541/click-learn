import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.textInputType,
    this.isPassword = false,
    required this.controller,
    this.validator,
    this.onChange,  this.maxLines =1,
  });

  final String hintText;
  final TextInputType? textInputType;
  final bool isPassword;
  final TextEditingController controller;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChange;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isShow = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      maxLines: widget.maxLines,
      onChanged: widget.onChange,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.controller,
      validator: widget.validator,
      obscureText: widget.isPassword ? isShow : false,
      keyboardType: widget.textInputType,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            isShow ? Icons.visibility : Icons.visibility_off,
            color: theme.iconTheme.color,
          ),
          onPressed: () {
            setState(() {
              isShow = !isShow;
            });
          },
        )
            : null,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: theme.hintColor),
        filled: true,
        fillColor: isDark
            ? Colors.grey[800]
            : const Color(0xFFD3D8D9).withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
