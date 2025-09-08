import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';
import '../../../core/models/score.dart';

class QuizzesAverage extends StatelessWidget {
  final List<UserWithScoresModel> users;

  const QuizzesAverage({super.key, required this.users});

  Map<String, double> get quizAverages => _calculateAverages().$1;
  Map<String, int> get quizCounts => _calculateAverages().$2;
  Map<String, ScoreModel> get quizSample => _calculateAverages().$3;

  // ⬇️ استخراج المتوسطات + عدد الطلاب لكل اختبار + مثال ScoreModel لكل اختبار
  (Map<String, double>, Map<String, int>, Map<String, ScoreModel>) _calculateAverages() {
    Map<String, double> averages = {};
    Map<String, int> counts = {};
    Map<String, ScoreModel> samples = {};

    for (var user in users) {
      for (var score in user.score) {
        final quizId = score.quizzes?.id ?? '';
        if (quizId.isNotEmpty) {
          final totalQuestions = score.quizzes?.questionsCount ?? 1;
          final percentage = score.score / totalQuestions;

          averages[quizId] = (averages[quizId] ?? 0) + percentage;
          counts[quizId] = (counts[quizId] ?? 0) + 1;

          // احتفظ بأي مثال من الـ score
          samples.putIfAbsent(quizId, () => score);
        }
      }
    }

    Map<String, double> result = {};
    averages.forEach((quizId, sum) {
      final count = counts[quizId]!;
      result[quizId] = sum / count;
    });

    return (result, counts, samples);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedEntries = quizAverages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 400,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: sortedEntries.length * 90,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BarChart(
                    BarChartData(
                      minY: 0,
                      maxY: 100,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final entry = sortedEntries[group.x.toInt()];
                            final quizId = entry.key;
                            final scoreExample = quizSample[quizId];
                            final quiz = scoreExample?.quizzes;
                            final questions = quiz?.questionsCount ?? 1;
                            final percentage = entry.value * 100;

                            return BarTooltipItem(
                              '${quiz?.tittle ?? 'اختبار'}\n'
                                  'متوسط الدرجة: ${percentage.toStringAsFixed(1)}%',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                            );
                          },
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: theme.textTheme.bodySmall),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < sortedEntries.length) {
                                final quizId = sortedEntries[index].key;
                                final quiz = quizSample[quizId]?.quizzes;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    quiz?.tittle ?? '',
                                    style: theme.textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      barGroups: sortedEntries.mapIndexed((index, entry) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value * 100,
                              width: 22,
                              borderRadius: BorderRadius.circular(4),
                              color: _getBarColor(entry.value),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 100,
                                color: Colors.grey.withOpacity(0.45),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      alignment: BarChartAlignment.spaceAround,
                      groupsSpace: 28,
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 500),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBarColor(double value) {
    if (value >= 0.9) return const Color(0xFF4CAF50);
    if (value >= 0.8) return const Color(0xFF2196F3);
    if (value >= 0.65) return const Color(0xFFFFC107);
    if (value >= 0.5) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}
