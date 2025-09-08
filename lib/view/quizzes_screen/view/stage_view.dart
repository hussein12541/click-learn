import 'package:e_learning/core/constant/constant.dart';
import 'package:e_learning/core/logic/get_quizzes/get_quizzes_cubit.dart';
import 'package:e_learning/core/logic/score/score_cubit.dart';
import 'package:e_learning/view/quizzes_screen/view/quiz_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/score.dart';
import '../../../core/models/stage_group_schedule_model.dart';
import '../widgets/group_quiz_chart_screen.dart';

class StageQuizListPage extends StatelessWidget {
  const StageQuizListPage({super.key, required this.teacherId});
  final String teacherId;
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('الاختبارات'), centerTitle: true,
          actions: [
          BlocBuilder<ScoreCubit,ScoreState>(
            builder: (context, state) =>
            IconButton(
            icon: (state is GetScoreLoading)? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ):const Icon(Icons.bar_chart_rounded),
                  tooltip: 'عرض الرسم البياني',
                  onPressed: () async {
              await  context
              .read<ScoreCubit>()
              .getScoreForTeacher(teacherId: teacherId);
                    Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupQuizChartScreen(users: context
                  .read<ScoreCubit>()
                  .scores ),
            ),
                    );
                  },
                ),
          )
    ],

    ),
      body: RefreshIndicator(
        onRefresh: () async {

          await context.read<GetQuizzesCubit>().getAllQuizzes(
            isTeacher: true,
            teacherId: Supabase.instance.client.auth.currentUser!.id,
            teacherIdsForStudent: [],
          );
        },
        child: BlocBuilder<GetQuizzesCubit, GetQuizzesState>(
          builder: (context, state) {
            if (state is GetQuizzesSuccess) {

              List<DataList> stages = context
                  .watch<GetQuizzesCubit>()
                  .dataListDropdownItems;
              return ListView.builder(
                itemCount: stages.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final stage = stages[index];
                  return Card(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: SvgPicture.asset(
                        'assets/images/images/Vector (1).svg',
                        color: isDark ? Colors.white : kLightPrimaryColor,
                      ),
                      title: Text(
                        stage.name ?? "", // هنا خليك دايمًا تستخدم الخاصية الصح
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizzesScreen(
                              stageId: stage.id ?? '',
                              teacherId:
                                  Supabase.instance.client.auth.currentUser!.id,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
            {
              return Skeletonizer(
                child: ListView.builder(
                  itemCount: 3,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) => Card(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.book),
                      title: Text(
                        'course.name??',
                        // هنا خليك دايمًا تستخدم الخاصية الصح
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
