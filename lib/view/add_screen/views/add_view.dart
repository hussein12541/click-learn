
import 'package:e_learning/core/logic/addCourse/add_course_cubit.dart';
import 'package:e_learning/view/add_screen/widgets/add_quiz.dart';
import 'package:e_learning/view/profle_screen/views/profle_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/logic/upload_posts/post_cubit.dart';
import '../../../core/logic/upload_quiz/upload_quiz_cubit.dart';
import '../widgets/add_course.dart';
import '../widgets/add_poll.dart';
import '../widgets/add_post.dart';
import '../widgets/add_story.dart';

class ChooseActionPage extends StatelessWidget {
  const ChooseActionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_ActionItem> actions = [
      _ActionItem(
        title: 'إضافة منشور',
        icon: Icons.post_add,
        type: 'post',
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => BlocProvider(
                      create: (context) => UploadPostCubit()..getAllStages(teacherId: Supabase.instance.client.auth.currentUser!.id),
                      child: AddPost(),
                    ),
              ),
            ),
      ),
      _ActionItem(
        title: 'استطلاع رأي',
        icon: Icons.poll,
        type: 'poll',
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => BlocProvider(
                      create: (context) => UploadPostCubit()..getAllStages(teacherId: Supabase.instance.client.auth.currentUser!.id),
                      child: AddPollScreen(),
                    ),
              ),
            ),
      ),
      _ActionItem(
        title: 'اختبار',
        icon: Icons.quiz,
        type: 'quiz',
        onTap:
            () => Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BlocProvider(
              create: (context) => UploadQuizCubit()..getAllStages(),
              child: AddQuizScreen(),
            ),
          ),
        ),
      ),
      _ActionItem(
        title: 'كورس',
        icon: Icons.school,
        type: 'course',
        onTap:
            () => Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BlocProvider(
              create: (context) => AddCourseCubit()..getAllStages(teacherId: Supabase.instance.client.auth.currentUser!.id),
              child: AddCourseScreen(),
            ),
          ),
        ),
      ),
      _ActionItem(
        title: 'قصة',
        icon: CupertinoIcons.photo_on_rectangle,
        type: 'course',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddStory(),)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('اختر نوع المحتوى'), centerTitle: true,actions: [IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(),)), icon:Icon(Icons.person))],),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // صفين
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return GestureDetector(
              onTap: action.onTap,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 6,
                color: Colors.blue.shade100,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(action.icon, size: 48, color: Colors.blue.shade900),
                      const SizedBox(height: 10),
                      Text(
                        action.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionItem {
  final String title;
  final IconData icon;
  final String type;
  final void Function() onTap;

  _ActionItem({
    required this.onTap,
    required this.title,
    required this.icon,
    required this.type,
  });
}
