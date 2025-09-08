import 'dart:developer';
import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:e_learning/core/logic/get_posts/get_posts_cubit.dart';
import 'package:e_learning/core/widgets/custom_text_field.dart';
import 'package:e_learning/core/widgets/loading_widget.dart';
import 'package:e_learning/core/widgets/showMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constant/constant.dart';
import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import '../../../core/logic/upload_posts/post_cubit.dart';
import '../../../core/models/stage_group_schedule_model.dart';
import '../../nav_button/views/nav_button_screen.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  DataList? selectedStage;
  List<Groups> groupList = [];
  Groups? selectedGroups;

  final TextEditingController _postTextController = TextEditingController();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    context.read<UploadPostCubit>().getAllStages(teacherId: Supabase.instance.client.auth.currentUser!.id);
    selectedGroups = null;
    _selectedImage = null;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
      log("Image selected: ${image.path}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منشور'),
        centerTitle: true,

      ),
      body: BlocConsumer<UploadPostCubit, PostState>(
        builder: (BuildContext context, state) {
          UploadPostCubit cubit = context.read<UploadPostCubit>();

          if (state is GetStagesSuccess ) {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// Dropdown المرحلة
                      CustomDropdown<DataList>(
                        hintText: 'اختر المرحلة',
                        items: cubit.dataListDropdownItems,
                        onChanged: (value) {
                          setState(() {
                            selectedStage = value!;
                            groupList = value.groupsList ?? [];
                            selectedGroups = null;
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
                            selectedGroups = value!;
                          });
                        },
                        decoration: _dropdownDecoration(context),
                      ),
                      SizedBox(height: kHeight16),

                      /// TextField النص
                      Form(
                        key: formKey,
                        child: CustomTextFormField(
                          maxLines: 7,
                          controller: _postTextController,
                          hintText: 'اكتب محتوى المنشور',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'من فضلك اكتب محتوى المنشور';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: kHeight16),

                      /// زر اختيار صورة
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.image),
                        label: Text('اختر صورة'),
                      ),
                      SizedBox(height: 8),

                      if (_selectedImage != null)
                        Stack(
                          children: [
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.file(
                                File(_selectedImage!.path),
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black.withOpacity(0.6),
                                radius: 16,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                    ],
                  ),
                ),

              ),
              bottomNavigationBar:SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate() && selectedGroups != null) {
                        String podtId = Uuid().v4();
                        await context.read<UploadPostCubit>().uploadPost(
                          teacherName: context.read<GetUserDataCubit>().userModel?.name??"المدرس",
                          imageFile:
                          _selectedImage != null
                              ? File(_selectedImage!.path)
                              : null,
                          group_id: selectedGroups!.id ?? '',
                          text: _postTextController.text,
                          post_id: podtId,
                        );
                        setState(() {
                          _postTextController.text = '';
                        });
                        context.read<GetPostsCubit>()
                            .getPosts(groups:context.read<GetUserDataCubit>().groups, isTeacher: true);
                      }else {
                        ShowMessage.showToast('املأ كل البيانات المطلوبة');
                      }
                    },
                    child: Text('نشر'),
                  ),
                ),
              ),

            );
          } else {
            return LoadingWidget();
          }
        },
        listener: (BuildContext context, PostState state) {
          if (state is UploadPostError) {
            ShowMessage.showToast('حدث خطأ غير متوقع');
          }
          if (state is UploadPostSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NavButton()),
            );
            ShowMessage.showToast(
              'تمت عملية النشر بنجاح',
              backgroundColor: Colors.green,
            );
          }
        },
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
