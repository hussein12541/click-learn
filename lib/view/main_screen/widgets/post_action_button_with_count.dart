import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionButtonWithCount extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final int count;
  final VoidCallback? onPressed;

  const ActionButtonWithCount({
    super.key,
    this.icon,
    this.iconWidget,
    required this.count,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: iconWidget ??
              Icon(
                icon,
                size: 20.r,
                color: Theme.of(context).colorScheme.primary,
              ),
          splashRadius: 20.r,
        ),
        Text(
          count.toString(),
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}
