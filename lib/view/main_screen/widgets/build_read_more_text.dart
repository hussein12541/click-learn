import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readmore/readmore.dart';

class BuildReadMoreText extends StatelessWidget {
  const BuildReadMoreText({
    super.key,
    required this.postText,
  });

  final String postText;

  @override
  Widget build(BuildContext context) {
    return ReadMoreText(
      postText,
      trimLines: 3,
      trimMode: TrimMode.Line,
      trimCollapsedText: 'قراءة المزيد',
      trimExpandedText: 'عرض أقل',
      style: GoogleFonts.cairo(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyMedium?.color,
        height: 1.5,
      ),
      moreStyle: GoogleFonts.cairo(
        fontSize: 11,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      lessStyle: GoogleFonts.cairo(
        fontSize: 11,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}