import 'dart:developer';
import 'dart:io';

import 'package:e_learning/core/logic/stories/stories_cubit.dart';
import 'package:e_learning/core/widgets/loading_widget.dart';
import 'package:e_learning/core/widgets/showMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import '../../nav_button/views/nav_button_screen.dart';


class AddStory extends StatefulWidget {
  const AddStory({super.key});

  @override
  State<AddStory> createState() => _AddStoryState();
}

class _AddStoryState extends State<AddStory> {
  final TextEditingController _storyTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  XFile? _selectedFile;
  bool isVideo = false;

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('صورة'),
            onTap: () async {
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  _selectedFile = image;
                  isVideo = false;
                });
              }
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('فيديو'),
            onTap: () async {
              final video = await picker.pickVideo(source: ImageSource.gallery);
              if (video != null) {
                setState(() {
                  _selectedFile = video;
                  isVideo = true;
                });
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitStory() async {
    if (_storyTextController.text.trim().isEmpty && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب حاجة أو اختار صورة/فيديو')),
      );
      return;
    }


    log('Text: ${_storyTextController.text}');
    log('Media: ${_selectedFile?.path ?? 'No Media'}');
    log('Type: ${isVideo ? 'Video' : 'Image'}');

    await context.read<StoriesCubit>().uploadStory(
        teacherName: context.read<GetUserDataCubit>().userModel?.name??"المدرس",

        isVideo: isVideo, isImage: (_selectedFile!=null&&isVideo==false), file:(_selectedFile != null)? File(_selectedFile!.path):null, text: _storyTextController.text);

    ShowMessage.showToast('تم رفع الحالة',backgroundColor: Colors.green);
    await context.read<StoriesCubit>().getStories(isTeacher: true,teacherIds: [],userId: Supabase.instance.client.auth.currentUser!.id);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NavButton()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة حالة'),
        centerTitle: true,

      ),
      body: BlocBuilder<StoriesCubit,StoriesState>(
      builder: (context, state) => (state is AddStoryLoading )?LoadingWidget():Scaffold(
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _storyTextController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'اكتب حالتك هنا (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickMedia,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('اختيار صورة أو فيديو'),
              ),
              const SizedBox(height: 16),
              if (_selectedFile != null)
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: isVideo
                          ? const Center(child: Icon(Icons.videocam, size: 50))
                          : Image.file(
                        File(_selectedFile!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.6),
                        child: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _selectedFile = null;
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
        bottomNavigationBar:
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _submitStory,
              child: const Text('نشر'),
            ),
          ),
        ),
      ),
      ),
    );
  }
}