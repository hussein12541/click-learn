import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_learning/core/models/story_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

class StoryItem extends StatelessWidget {
  final List<StoryModel> stories;

  const StoryItem({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    final firstStory = stories.first;
    final teacherImage = firstStory.user.teacher?.imageUrl ??
        "https://i.pinimg.com/736x/c5/ff/24/c5ff2457ef6665855ff0148cbfac6dfd--instagram-feed-angel.jpg";
    final teacherName = firstStory.user.name;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // ✅ الدائرة الخارجية اللي فيها تقسيم
            CustomPaint(
              painter: StoryBorderPainter(stories: stories),
              child: Container(
                width: 68.w,
                height: 68.h,
              ),
            ),

            // ✅ صورة المدرس
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: CachedNetworkImageProvider(teacherImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        SizedBox(
          width: 60.w,
          child: Text(
            teacherName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}


class StoryBorderPainter extends CustomPainter {
  final List<StoryModel> stories;

  StoryBorderPainter({required this.stories});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 3.0;

    // ✅ ناخد أصغر بعد علشان نضمن دايرة سليمة
    final dimension = min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = dimension / 2;

    final total = stories.length;
    final sweep = 2 * pi / total;

    for (int i = 0; i < total; i++) {
      final story = stories[i];
      final isSeen = story.isSeen;

      final paint = Paint()
        ..color = isSeen ? Colors.grey : Colors.blueAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final startAngle = -pi / 2 + (sweep * i);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep - 0.15, // فراغ بين الأجزاء
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
