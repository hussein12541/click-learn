import 'package:flutter/material.dart';

import '../../../core/models/stage_group_schedule_model.dart';

Widget _buildTableCell(BuildContext context, String text, {bool isHeader = false}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        color: isHeader
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );
}

/// Displays group information in a professional table format.
Widget buildGroupInfoTable(BuildContext context, Groups? selectedGroups) {
  // Handle null case for selectedGroups
  if (selectedGroups == null) {
    return const Center(
      child: Text(
        'لا توجد بيانات للمجموعات',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.all(16.0), // Consistent padding for better layout
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display number of students
        Text(
          'عدد الطلاب المتاحين: ${selectedGroups.numberOfStudents ?? 'غير معروف'}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        // Table title

        selectedGroups.schedulesList?.isNotEmpty ?? false
            ? Table(
          border: TableBorder.all(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            width: 1,
          ),
          columnWidths: const {
            0: FlexColumnWidth(2), // Day column
            1: FlexColumnWidth(3), // Time column
          },
          children: [
            // Table header
            TableRow(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              children: [
                _buildTableCell(context, 'اليوم', isHeader: true),
                _buildTableCell(context, 'الوقت', isHeader: true),
              ],
            ),
            // Table rows for schedules
            ...selectedGroups.schedulesList!.map((schedule) {
              return TableRow(
                children: [
                  _buildTableCell(context, schedule.day ?? 'غير محدد'),
                  _buildTableCell(context, schedule.time ?? 'غير محدد'),
                ],
              );
            }),
          ],
        )
            : const Text(
          'لا توجد مواعيد متاحة',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}
