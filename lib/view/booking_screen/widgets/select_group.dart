import 'package:e_learning/core/widgets/showMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/logic/get_teachers/get_teachers_cubit.dart';
import '../../../core/models/teacher_model.dart';
import 'book_screen.dart';

class SelectGroup extends StatelessWidget {
  final List<GroupModel> groups;

  const SelectGroup({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المجموعات"), centerTitle: true),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if(int.parse(group.numberOfStudents)>=1){

                  Navigator.push(context, MaterialPageRoute(builder: (context) => BookGroup(group: group,),));
                }else{
                  ShowMessage.showToast("هذة المجموعة ممتلئة");
                }
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.group, color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    group.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "عدد الطلاب المتاحين: ${group.numberOfStudents}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (group.createdAt != null)
                              Text(
                                "تم الإنشاء في: ${group.createdAt!.toLocal().toString().split(' ')[0]}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),

                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
