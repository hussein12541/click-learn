import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:e_learning/core/logic/add_poll/add_poll_cubit.dart';
import 'package:e_learning/core/logic/get_posts/get_posts_cubit.dart';
import 'package:e_learning/core/logic/get_user_data/get_user_data_cubit.dart';
import 'package:e_learning/core/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constant/constant.dart';
import '../../../core/logic/upload_posts/post_cubit.dart';
import '../../../core/models/stage_group_schedule_model.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/showMessage.dart';
import '../../nav_button/views/nav_button_screen.dart';

class AddPollScreen extends StatefulWidget {
  const AddPollScreen({super.key});

  @override
  State<AddPollScreen> createState() => _AddPollScreenState();
}

class _AddPollScreenState extends State<AddPollScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _questionController = TextEditingController();

  DataList? selectedStage;
  List<Groups> groupList = [];
  Groups? selectedGroup;

  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<UploadPostCubit>().getAllStages(teacherId: Supabase.instance.client.auth.currentUser!.id);
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers.removeAt(index);
      });
    } else {
      ShowMessage.showToast('يجب أي يكون على الأقل اختيارين!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddPollCubit>(
      create:(context) =>AddPollCubit() ,
      child: Scaffold(
        appBar: AppBar(
          title: Text('إضافة استطلاع رأي'),
          centerTitle: true,
        ),
        body: BlocBuilder<UploadPostCubit, PostState>(
          builder: (context, state) {
            final cubit = context.read<AddPollCubit>();

            if (state is GetStagesSuccess) {
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          /// Dropdown المرحلة
                          CustomDropdown<DataList>(
                            hintText: 'اختر المرحلة',
                            items: context.read<UploadPostCubit>().dataListDropdownItems,
                            onChanged: (value) {
                              setState(() {
                                selectedStage = value!;
                                groupList = value.groupsList ?? [];
                                selectedGroup = null;
                              });
                            },
                            decoration: _dropdownDecoration(context),
                          ),
                          SizedBox(height: kHeight16),

                          /// Dropdown المجموعة
                          CustomDropdown<Groups>(
                            hintText: 'اختر المجموعة',
                            items: groupList,
                            onChanged: (value) {
                              setState(() {
                                selectedGroup = value!;
                              });
                            },
                            decoration: _dropdownDecoration(context),
                          ),
                          SizedBox(height: kHeight16),


                          CustomTextFormField(
                            controller: _questionController,
                            hintText: 'اكتب سؤال الاستطلاع',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'من فضلك اكتب سؤال الاستطلاع';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          /// كل الاختيارات
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _optionControllers.length,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: CustomTextFormField(
                                      controller: _optionControllers[index],
                                      hintText: 'الاختيار رقم ${index + 1}',
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'من فضلك اكتب هذا الاختيار';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle, color: Colors.red),
                                    onPressed: () => _removeOption(index),
                                  ),
                                ],
                              );
                            }, separatorBuilder: (BuildContext context, int index) {
                              return  SizedBox(height: kHeight16,);
                          },
                          ),
                          const SizedBox(height: 12),

                          ElevatedButton.icon(
                            onPressed: _addOption,
                            icon: Icon(Icons.add),
                            label: Text('إضافة اختيار جديد'),
                          ),
                          const SizedBox(height: 24),

                          /// معاينة الاستطلاع
                          if (_questionController.text.isNotEmpty &&
                              _optionControllers.every((c) => c.text.isNotEmpty))
                            FlutterPolls(
                              pollId: "preview",
                              hasVoted: false,
                              userVotedOptionId: "1",
                              onVoted: (option, _) async {
                                ShowMessage.showToast('ده مجرد عرض 😂');
                                return false;
                              },
                              pollTitle: Text(_questionController.text),
                              pollOptions: _optionControllers
                                  .asMap()
                                  .entries
                                  .map((entry) => PollOption(
                                id: "${entry.key + 1}",
                                title: Text(entry.value.text),
                                votes: 0,
                              ))
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() && selectedGroup != null) {
                          final options = _optionControllers.map((c) => c.text).toList();
                  
                          if (options.length < 2 || options.any((o) => o.trim().isEmpty)) {
                            ShowMessage.showToast('من فضلك تأكد من وجود اختيارين على الأقل ومليانين');
                            return;
                          }
                  
                          String podtId=Uuid().v4();
                          await context.read<UploadPostCubit>().uploadPost(
                              teacherName: context.read<GetUserDataCubit>().userModel?.name??"المدرس",
                  
                              imageFile: null, text: _questionController.text, group_id: selectedGroup!.id??'', post_id: podtId);
                          for (var item in options) {
                            await context.read<AddPollCubit>().addPolls(post_id: podtId, option_text: item);
                          }
                  
                  
                          await context.read<GetPostsCubit>().getPosts(groups:context.read<GetUserDataCubit>().groups, isTeacher: true);
                  
                  
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => NavButton()),
                          );
                          ShowMessage.showToast('تم نشر الاستطلاع بنجاح!', backgroundColor: Colors.green);
                  
                  
                        } else {
                          ShowMessage.showToast('املأ كل البيانات المطلوبة');
                        }
                      },
                      child: Text('نشر'),
                    ),
                  ),
                ),
              );
            }

            return LoadingWidget();
          },
        ),
      ),
    );
  }
  CustomDropdownDecoration _dropdownDecoration(BuildContext context) {
    return CustomDropdownDecoration(
      closedFillColor:
      Theme.of(context).inputDecorationTheme.fillColor ??
          Colors.transparent,
      expandedFillColor: Theme.of(context).cardColor,
      closedShadow: [
        BoxShadow(
          color:
          Theme.of(context).brightness == Brightness.dark
              ? Color(0xff424242)
              : Color(0xffF2F3F3),
        ),
      ],
      hintStyle:
      Theme.of(context).inputDecorationTheme.hintStyle ??
          TextStyle(color: Theme.of(context).hintColor),
      listItemStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
      searchFieldDecoration: SearchFieldDecoration(
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
      ),
    );
  }
}

