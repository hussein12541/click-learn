import 'package:e_learning/core/models/story_model.dart';
import 'package:e_learning/view/main_screen/widgets/story_item.dart';
import 'package:e_learning/view/main_screen/widgets/story_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StoriesBar extends StatelessWidget {
  final Map<TeacherModel, List<StoryModel>> storiesByTeacher;

  const StoriesBar({super.key, required this.storiesByTeacher});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: storiesByTeacher.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final teacher = storiesByTeacher.keys.elementAt(index);
          final stories = storiesByTeacher[teacher]!;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoryViewerPage(stories: stories),
                    ),
                  );
                },
                child: StoryItem(stories: stories), // أول قصة للعرض
              ),
            ],
          );
        },
      ),
    );
  }
}
