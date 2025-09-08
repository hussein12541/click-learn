import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/score.dart';

class UserQuizChartScreen extends StatelessWidget {
  final UserWithScoresModel user;

  const UserQuizChartScreen({super.key, required this.user});

  double get average => user.quizCount == 0
      ? 0
      : user.totalScore /
            user.score
                .map((e) => e.quizzes?.questionsCount ?? 1)
                .fold(0, (a, b) => a + b);

  String getGrade(double avg) {
    if (avg >= 0.9) return 'ممتاز 🏆';
    if (avg >= 0.8) return 'جيد جداً ⭐';
    if (avg >= 0.65) return 'جيد 😊';
    if (avg >= 0.5) return 'مقبول 😐';
    return 'ضعيف 😢';
  }

  Color _getBarColor(double ratio) {
    if (ratio >= 0.9) return const Color(0xFF4CAF50);
    if (ratio >= 0.8) return const Color(0xFF2196F3);
    if (ratio >= 0.65) return const Color(0xFFFFC107);
    if (ratio >= 0.5) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }


  String getPerformanceTrend() {
    final sortedScores = [...user.score]
      ..removeWhere((s) => s.quizzes?.createdAt == null)
      ..sort((a, b) => DateTime.parse(a.quizzes!.createdAt!)
          .compareTo(DateTime.parse(b.quizzes!.createdAt!)));

    if (sortedScores.length < 2) return 'غير كافي للحكم';

    List<double> diffs = [];
    for (int i = 1; i < sortedScores.length; i++) {
      final prev = sortedScores[i - 1];
      final curr = sortedScores[i];

      final prevRatio = prev.score / (prev.quizzes?.questionsCount ?? 1);
      final currRatio = curr.score / (curr.quizzes?.questionsCount ?? 1);

      diffs.add(currRatio - prevRatio);
    }

    final avgDiff = diffs.reduce((a, b) => a + b) / diffs.length;

    if (avgDiff > 0.05) return 'في تحسن   📈';
    if (avgDiff < -0.05) return 'في تراجع   📉';
    return 'ثابت المستوى   ➖';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avgPercentage = (average * 100);
    final grade = getGrade(average);
    final gradeColor = _getBarColor(average);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'أداء الاختبارات - ${user.name}',

        ),
        centerTitle: true,
      ),
      body: user.quizCount == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد بيانات اختبارات متاحة',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سيظهر الرسم البياني عند إجراء الاختبارات',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: SizedBox(
                 height: isPortrait
                      ? MediaQuery.of(context).size.height // لو معدول
                      : MediaQuery.of(context).size.width , // لو مقلوب
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Overall Summary Cards
                      Wrap(
                        spacing: 12, // المسافة بين الكروت
                        runSpacing: 12, // لو الكروت نزلت تحت بعضها
                        children: [
                          _buildSummaryCard(
                            context,
                            'المعدل العام',
                            '${avgPercentage.toStringAsFixed(1)}%',
                            grade,
                            gradeColor,
                          ),
                          _buildTrendCard(context),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Stats Cards
                      _buildStatsRow(context),
                      const SizedBox(height: 24),

                      // Chart Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'أداء الاختبارات الفردية',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Chart Container
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: user.score.length * 80,
                                // ← يتحسب تلقائي حسب عدد الامتحانات
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 24.0,
                                    right: 16.0,
                                    left: 16.0,
                                    bottom: 16.0,
                                  ),
                                  child: BarChart(
                                    BarChartData(
                                      minY: 0,
                                      maxY: 100,
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData: BarTouchTooltipData(
                                          fitInsideHorizontally: true,
                                          fitInsideVertically: true,
                                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                            final score = user.score[groupIndex];
                                            final questions = score.quizzes?.questionsCount ?? 1;
                                            final percentage = (score.score / questions) * 100;
                                            return BarTooltipItem(
                                              '${score.quizzes?.tittle ?? 'اختبار'}\n'
                                                  'الدرجة: ${score.score}/$questions\n'
                                                  '(${percentage.toStringAsFixed(1)}%)',
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
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.1),
                                          strokeWidth: 1,
                                        ),
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border.all(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 20,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                '${value.toInt()}%',
                                                style: theme.textTheme.bodySmall,
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              final index = value.toInt();
                                              if (index < user.score.length) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(
                                                    top: 8.0,
                                                  ),
                                                  child: Text(
                                                    user
                                                            .score[index]
                                                            .quizzes
                                                            ?.tittle ??
                                                        '',
                                                    style:
                                                        theme.textTheme.bodySmall,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }
                                              return const Text('');
                                            },
                                            reservedSize: 40,
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                      ),
                                      barGroups: user.score.asMap().entries.map((
                                        entry,
                                      ) {
                                        final index = entry.key;
                                        final s = entry.value;
                                        final questions =
                                            s.quizzes?.questionsCount ?? 1;
                                        final percentage =
                                            (s.score / questions) * 100;

                                        return BarChartGroupData(
                                          x: index,
                                          barRods: [
                                            BarChartRodData(
                                              toY: percentage,
                                              width: 22,
                                              borderRadius: BorderRadius.circular(
                                                4,
                                              ),
                                              color: _getBarColor(percentage / 100),
                                              backDrawRodData:
                                                  BackgroundBarChartRodData(
                                                    show: true,
                                                    toY: 100,
                                                    color:  Colors.grey.withOpacity(0.45), // ← هنا غير اللون حسب مزاجك 😎
                                                  ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                      alignment: BarChartAlignment.spaceAround,
                                      groupsSpace: 28,
                                    ),
                                    swapAnimationDuration: const Duration(
                                      milliseconds: 500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Average Line Indicator
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Container(height: 2, width: 24, color: gradeColor),
                            const SizedBox(width: 8),
                            Text(
                              'المعدل العام: ${avgPercentage.toStringAsFixed(1)}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Color Legend
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
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard(BuildContext context) {
    final theme = Theme.of(context);
    final trend = getPerformanceTrend();
    Color color;
    IconData icon;

    if (trend.contains('تحسن')) {
      color = const Color(0xFF4CAF50);
      icon = Icons.trending_up;
    } else if (trend.contains('تراجع')) {
      color = const Color(0xFFF44336);
      icon = Icons.trending_down;
    } else {
      color = const Color(0xFFFFC107);
      icon = Icons.trending_flat;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اتجاه الأداء',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  trend,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 20),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'عدد الاختبارات',
            user.quizCount.toString(),
            Icons.assignment_turned_in,
            const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'إجمالي الدرجات',
            user.totalScore.toString(),
            Icons.star,
            const Color(0xFFFFC107),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'أفضل نتيجة',
            '${_getBestPercentage().toStringAsFixed(1)}%',
            Icons.emoji_events,
            const Color(0xFF4CAF50),
          ),
        ),

      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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

  double _getBestPercentage() {
    if (user.score.isEmpty) return 0;

    return user.score
        .map((e) => e.score / (e.quizzes?.questionsCount ?? 1))
        .reduce((a, b) => a > b ? a : b) *
        100;
  }

}
