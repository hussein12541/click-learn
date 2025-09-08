import 'package:e_learning/view/quizzes_screen/widgets/user_quiz_scores_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_learning/core/logic/score/score_cubit.dart';
import 'package:lottie/lottie.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/models/score.dart';
import '../../../core/models/user_model.dart';
import 'group_quiz_chart_screen.dart';

class LeaderboardScreen extends StatelessWidget {
  final String stageId;
  final String teacherId;
  const LeaderboardScreen({super.key, required this.stageId, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoreCubit, ScoreState>(
      builder: (context, state) {
        final cubit = context.read<ScoreCubit>();

        if (state is GetScoreLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('لوحة الشرف 🏆')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Skeletonizer(
                enabled: true,
                child: Column(
                  children: [
                    Column(
                      children: [
                        // الطالب الأول (في القمة 🥇)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  child:  Text('text', style: TextStyle(fontSize: 24)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'user.name',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                                Text(
                                  'المجموع: ${'user.totalScore'}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // الطالب التاني والتالت (القاعدة 🥈🥉)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    child:  Text('text', style: TextStyle(fontSize: 24)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    ' user.name',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                  Text(
                                    'المجموع: ${'user.totalScore'}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    child:  Text('text', style: TextStyle(fontSize: 24)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'user.na',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                  Text(
                                    'المجموع: ${'user.totalScore'}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'الترتيب الكامل',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // قائمة الطلاب العاديين وهميين
                    Expanded(
                      child: ListView.separated(
                        itemCount: 6,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: const ListTile(
                              leading: CircleAvatar(),
                              title: Text('اسم الطالب'),
                              subtitle: Text('الاختبارات: -- | المجموع: --'),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        const gold = Color(0xFFFFD700);
        const silver = Color(0xFFC0C0C0);
        const bronze = Color(0xFFCD7F32);
        const tileColor = Color(0xFFF7F7F7);

        if (state is GetScoreError) {
          return RefreshIndicator(
            onRefresh: () async => await cubit.getScoreForTeacher(teacherId: teacherId),
            child: const Scaffold(
              body: Center(child: Text('حدث خطأ أثناء تحميل البيانات')),
            ),
          );
        }

        final sortedUsers = List.of(
          cubit.scores.where((e) {
            if (e.groups.isEmpty) return false;
            return e.groups.first.stageId == stageId;
          }),
        )..sort((a, b) => b.totalScore.compareTo(a.totalScore));


        if (sortedUsers.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('لوحة الشرف 🏆'),


            ),
            body: const Center(
              child: Text('لا يوجد طلاب بعد ', style: TextStyle(fontSize: 18)),
            ),
          );
        }

        final topThree = sortedUsers.take(3).toList();
        final others = sortedUsers.length > 3 ? sortedUsers.sublist(3) : [];

        Widget _buildMedalUserItem(BuildContext context, UserWithScoresModel user,
            {required String text, required Color? color}) {
          final maxWidth = MediaQuery.of(context).size.width * 0.38;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserQuizScoresScreen(user: user)),
              );
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Card(
                elevation: 6,
                color: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Lottie.asset(
                          repeat: false,
                          text,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                          color: tileColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'المجموع: ${user.totalScore}',
                        style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        Widget topThreeWidget() {
          switch (topThree.length) {
            case 1:
              return Center(
                child: _buildMedalUserItem(
                  context,
                  topThree[0],
                  text: "assets/json/first.json",
                  color: gold,
                ),
              );
            case 2:
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMedalUserItem(
                    context,
                    topThree[0],
                    text: "assets/json/first.json",
                    color: gold,
                  ),
                  _buildMedalUserItem(
                    context,
                    topThree[1],
                    text: "assets/json/second.json",
                    color: silver,
                  ),
                ],
              );
            default:
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: _buildMedalUserItem(
                          context,
                          topThree[1],
                          text: "assets/json/second.json",
                          color: silver,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: _buildMedalUserItem(
                          context,
                          topThree[2],
                          text: "assets/json/third.json",
                          color: bronze,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Center(
                      child: _buildMedalUserItem(
                        context,
                        topThree[0],
                        text: "assets/json/first.json",
                        color: gold,
                      ),
                    ),
                  ),

                ],
              );
          }
        }

        return RefreshIndicator(
          onRefresh: () async => await cubit.getScoreForTeacher(teacherId:teacherId),
          child: Scaffold(
            appBar: AppBar(title: const Text('لوحة الشرف 🏆'), centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.bar_chart_rounded),
                  tooltip: 'عرض الرسم البياني',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupQuizChartScreen(users: sortedUsers),
                      ),
                    );
                  },
                )
              ],

            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  topThreeWidget(),
                  const SizedBox(height: 24),
                  Text(
                    'الترتيب الكامل',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(others.length, (index) {
                    final user = others[index];
                    final actualIndex = index + 4;
                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                            Colors.primaries[actualIndex % Colors.primaries.length],
                            child: Text(
                              '$actualIndex',
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(user.name),
                          subtitle: Text(
                              'الاختبارات: ${user.quizCount} | المجموع: ${user.totalScore}'),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserQuizScoresScreen(user: user),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
