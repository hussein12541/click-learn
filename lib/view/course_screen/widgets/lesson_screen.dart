import 'package:e_learning/core/constant/constant.dart';
import 'package:e_learning/core/models/lesson_model.dart';
import 'package:e_learning/view/course_screen/widgets/pdf_view.dart';
import 'package:e_learning/view/course_screen/widgets/secure_youtube_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LessonPage extends StatelessWidget {
  final LessonModel lesson;

  const LessonPage({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(lesson.name), centerTitle: true),
      body: Column(
        children: [
          (lesson.vedioUrl!=null)?customLessonItem('الفيديو', isDark, context, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SecureYoutubePlayerPage(lesson: lesson),
              ),
            );
          }, 'assets/images/images/video.svg'):SizedBox.shrink(),
          (lesson.pdf_url!=null)? customLessonItem("الملف", isDark, context, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PdfView(lesson: lesson),
              ),
            );
          }, 'assets/images/images/Vector (1).svg'):SizedBox.shrink(),
        ],
      ),
    );
  }

  Card customLessonItem(
    String tittle,
    bool isDark,
    BuildContext context,
    void Function() onTap,
    String svgIcon,
  ) {
    return Card(
      color: isDark ? Colors.grey[900] : Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: SvgPicture.asset(
          svgIcon,
          color: isDark ? Colors.white : kLightPrimaryColor,
        ),
        title: Text(
          tittle,
          style: TextStyle(
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),

        onTap: onTap,
      ),
    );
  }
}
