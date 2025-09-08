import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_view/story_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import '../../../core/logic/stories/stories_cubit.dart';
import '../../../core/models/story_model.dart';

class StoryViewerPage extends StatefulWidget {
  final List<StoryModel> stories;


  const StoryViewerPage({super.key, required this.stories});

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  final StoryController _controller = StoryController();
  late List<StoryItem> _storyItems;
  int _currentIndex = 0; // لتعقب الستوري الحالي

  @override
  void initState() {
    super.initState();

    _storyItems = widget.stories.map((story) {
      if (story.imgUrl != null) {
        return StoryItem.pageImage(
          url: story.imgUrl!,
          caption: Text(
            story.text ?? "",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          controller: _controller,
        );
      } else if (story.videoUrl != null) {
        return StoryItem.pageVideo(
          story.videoUrl!,
          duration:(story.duration==null)?null: Duration(milliseconds: (story.duration! * 1000).round()) ,

          caption: Text(
            story.text ?? "",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          controller: _controller,
        );
      } else if (story.text != null) {
        return StoryItem.text(
          title: story.text!,
          backgroundColor: Colors.blueGrey,
        );
      } else {
        return StoryItem.text(
          title: "",
          backgroundColor: Colors.red,
        );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<GetUserDataCubit>().isTeacher;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            StoryView(
              storyItems: _storyItems,
              controller: _controller,
              onComplete: () => Navigator.pop(context),
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
              repeat: false,
              onStoryShow: (storyItem, index) async {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  setState(() {
                    _currentIndex = index;
                  });

                  // نضيف الستوري في المشاهَدة
                  final story = widget.stories[index];
                  final cubit = context.read<StoriesCubit>();
                  final isAlreadySeen = await cubit.isStorySeen(story.id);
                  if (!isAlreadySeen) {
                    await cubit.addStoryToSeen(id: story.id);
                    print('✅ تم تسجيل القصة ${story.id} كمشوفة');
                  }
                });
              },


            ),


            // زر الحذف في الأعلى يمين
            isTeacher?BlocBuilder<StoriesCubit,StoriesState>(
              builder:(context, state) =>  Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 16,
                child: IconButton(
                  color: Colors.red,
                  onPressed: () async {
                    _controller.pause();
                    await context.read<StoriesCubit>().deleteStories(story: widget.stories[_currentIndex] );
                    // لو عايز بعد الحذف ترجع للخلف (تخرج من الستوري)
                    await context.read<StoriesCubit>().getStories(isTeacher: true, userId: Supabase.instance.client.auth.currentUser!.id);
                    Navigator.pop(context);
                  },
                  icon:(state is DeleteStoryLoading)?CircularProgressIndicator(backgroundColor: Colors.transparent,color: Colors.red,) :Icon(CupertinoIcons.delete_simple, ),

                ),
              ),
            ):SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
