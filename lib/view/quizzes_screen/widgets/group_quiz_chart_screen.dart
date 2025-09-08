import 'package:e_learning/view/quizzes_screen/widgets/quizzess_average.dart';
import 'package:flutter/material.dart';
import '../../../core/models/score.dart';


class GroupQuizChartScreen extends StatelessWidget {
  final List<UserWithScoresModel> users;

  const GroupQuizChartScreen({super.key, required this.users});

  double get groupAverage {
    if (users.isEmpty) return 0;

    double totalAverage = 0;
    int validUsers = 0;

    for (var user in users) {
      if (user.quizCount > 0) {
        final userAvg = user.totalScore /
            user.score.fold(0, (sum, score) => sum + (score.quizzes?.questionsCount ?? 1));
        totalAverage += userAvg;
        validUsers++;
      }
    }

    return validUsers > 0 ? totalAverage / validUsers : 0;
  }

  Map<String, double> get quizAverages {
    Map<String, double> averages = {};
    Map<String, int> counts = {};

    for (var user in users) {
      for (var score in user.score) {
        final quizId = score.quizzes?.id ?? '';

        if (quizId.isNotEmpty) {
          final totalQuestions = score.quizzes?.questionsCount ?? 1;
          final percentage = score.score / totalQuestions;

          if (!averages.containsKey(quizId)) {
            averages[quizId] = 0.0;
            counts[quizId] = 0;
          }

          averages[quizId] = averages[quizId]! + percentage;
          counts[quizId] = counts[quizId]! + 1;
        }
      }
    }

    Map<String, double> result = {};
    averages.forEach((quizId, sum) {
      final count = counts[quizId] ?? 1;
      final quizTitle = users
          .expand((u) => u.score)
          .firstWhere((s) => s.quizzes?.id == quizId)
          .quizzes
          ?.tittle ?? 'اختبار';

      result['$quizTitle ($count طلاب)'] = sum / count;
    });

    return result;
  }

  List<UserWithScoresModel> get topPerformers {
    final sortedUsers = users.where((user) => user.quizCount > 0).toList()
      ..sort((a, b) {
        final aAvg = a.totalScore /
            a.score.fold(0, (sum, score) => sum + (score.quizzes?.questionsCount ?? 1));
        final bAvg = b.totalScore /
            b.score.fold(0, (sum, score) => sum + (score.quizzes?.questionsCount ?? 1));
        return bAvg.compareTo(aAvg);
      });

    return sortedUsers.take(5).toList(); // هنا بقى الحقيقي 💯
  }

  List<UserWithScoresModel> get bottomPerformers {
    return users.where((user) {
      if (user.quizCount == 0) return false;
      final avg = user.totalScore /
          user.score.fold(0, (sum, score) => sum + (score.quizzes?.questionsCount ?? 1));
      return avg < 0.5;
    }).toList();
  }


  String _getGrade(double avg) {
    if (avg >= 0.9) return 'ممتاز';
    if (avg >= 0.8) return 'جيد جداً';
    if (avg >= 0.65) return 'جيد';
    if (avg >= 0.5) return 'مقبول';
    return 'ضعيف';
  }

  String _getTrendDirection(List<UserWithScoresModel> users) {
    final allScores = users.expand((u) => u.score).toList()
      ..removeWhere((s) => s.quizzes?.createdAt == null);

    if (allScores.length < 4) return 'غير كافي'; // أقل من 4 درجات؟ قليل أوي نحكم عليه

    // ترتيب الدرجات حسب تاريخ إنشاء الكويز
    allScores.sort((a, b) =>
        DateTime.parse(a.quizzes!.createdAt!)
            .compareTo(DateTime.parse(b.quizzes!.createdAt!)));

    final mid = (allScores.length / 2).floor();

    final olderHalf = allScores.sublist(0, mid);
    final recentHalf = allScores.sublist(mid);

    final olderAvg = _averageOfScores(olderHalf);
    final recentAvg = _averageOfScores(recentHalf);

    if (recentAvg > olderAvg + 0.05) return 'تحسن 📈';
    if (recentAvg < olderAvg - 0.05) return 'تراجع 📉';
    return 'ثابت ➖';
  }

  double _averageOfScores(List<ScoreModel> scores) {
    if (scores.isEmpty) return 0;
    double total = 0;
    int totalQuestions = 0;

    for (var score in scores) {
      final qCount = score.quizzes?.questionsCount ?? 1;
      total += score.score;
      totalQuestions += qCount;
    }

    return totalQuestions > 0 ? total / totalQuestions : 0;
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupAvgPercentage = (groupAverage * 100);
    final quizAvgs = quizAverages;
    final sortedEntries = quizAvgs.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topFive = sortedEntries.take(5).map((entry) {
      return _buildQuizItem(context, entry.key, entry.value);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('أداء المجموعة'),
        centerTitle: true,
      ),
      body: users.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد بيانات طلاب متاحة',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'ملخص أداء المجموعة',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildSummaryItem(
                              'عدد الطلاب',
                              users.length.toString(),
                              Icons.people,
                              Colors.blue,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildSummaryItem(
                              'متوسط المجموعة',
                              '${groupAvgPercentage.toStringAsFixed(1)}%',
                              Icons.bar_chart,
                              Colors.green,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildSummaryItem(
                              'أفضل اختبار',
                              _getBestQuiz(quizAvgs),
                              Icons.emoji_events,
                              Colors.amber,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildSummaryItem(
                              'التقدير العام',
                              _getGrade(groupAverage),
                              Icons.grade,
                              _getColorForPercentage(groupAverage),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildSummaryItem(
                              'الاتجاه العام',
                              _getTrendDirection(users),
                              Icons.trending_up,
                              Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // متوسطات الاختبارات
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16,),
                    Text("متوسط الإختبارات"
                      ,style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                    QuizzesAverage(users: users,),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildLegendItem('ممتاز (≥90%)', const Color(0xFF4CAF50)),
                        _buildLegendItem(
                          'جيد جداً (≥80%)',
                          const Color(0xFF2196F3),
                        ),
                        _buildLegendItem('جيد (≥65%)', const Color(0xFFFFC107)),
                        _buildLegendItem('مقبول (≥50%)', const Color(0xFFFF9800)),
                        _buildLegendItem('ضعيف (<50%)', const Color(0xFFF44336)),
                      ],
                    ),
                    SizedBox(height: 16,),

                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أفضل الاختبارات',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...topFive,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // أفضل الطلاب
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أفضل الطلاب',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...topPerformers.map((user) => _buildStudentItem(user, true)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // الطلاب المحتاجون للدعم
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الطلاب المحتاجون للدعم',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...bottomPerformers.map((user) => _buildStudentItem(user, false)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildQuizItem(BuildContext context, String title, double average) {
    final percentage = (average * 100).toStringAsFixed(1);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getColorForPercentage(average),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentItem(UserWithScoresModel user, bool isTop) {
    final userAvg = user.quizCount == 0
        ? 0
        : user.totalScore /
        user.score.fold(0, (sum, score) => sum + (score.quizzes?.questionsCount ?? 1));

    final percentage = (userAvg * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isTop ? Colors.amber.withOpacity(0.2) : Colors.red.withOpacity(0.2),
            child: Text(
              user.name.substring(0, 1),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isTop ? Colors.amber : Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getColorForPercentage(userAvg.toDouble()),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForPercentage(double value) {
    if (value >= 0.9) return const Color(0xFF4CAF50);
    if (value >= 0.8) return const Color(0xFF2196F3);
    if (value >= 0.65) return const Color(0xFFFFC107);
    if (value >= 0.5) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String _getBestQuiz(Map<String, double> quizAverages) {
    if (quizAverages.isEmpty) return 'لا يوجد';

    final bestEntry = quizAverages.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
    );

    final title = bestEntry.key.split(' (')[0];
    return title.length > 15 ? '${title.substring(0, 15)}...' : title;
  }
}
Widget _buildLegendItem(String label, Color color) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}