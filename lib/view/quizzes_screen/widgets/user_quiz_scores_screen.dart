import 'package:flutter/material.dart';
import '../../../core/models/score.dart';
import 'user_quiz_chart_screen.dart';

class UserQuizScoresScreen extends StatelessWidget {
  final UserWithScoresModel user;

  const UserQuizScoresScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('نتائج ${user.name}')

          ,actions: [
          IconButton(
          icon: const Icon(Icons.bar_chart_rounded),
      tooltip: 'عرض الرسم البياني',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserQuizChartScreen(user: user),
          ),
        );
      },
    )
        ],
      ),
      body: user.score.isEmpty
          ? const Center(child: Text('لم يقم هذا الطالب بأي اختبار بعد 🙃'))
          : ListView.separated(
        itemCount: user.score.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final quizScore = user.score[index];
          final quizTitle = quizScore.quizzes?.tittle ?? 'بدون عنوان';

          return ListTile(
            leading: const Icon(Icons.assignment_turned_in_outlined),
            title: Text(quizTitle),
            subtitle: Text('الدرجة: ${quizScore.score} / ${quizScore.quizzes?.questionsCount??''}'),
            trailing: Text(
              quizScore.createdAt.substring(0, 10) ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
