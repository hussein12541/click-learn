import 'package:e_learning/core/logic/get_courses/get_courses_cubit.dart';
import 'package:e_learning/core/logic/stories/stories_cubit.dart';
import 'package:e_learning/core/models/post_model.dart';
import 'package:e_learning/core/models/story_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/logic/get_posts/get_posts_cubit.dart';
import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import '../../../core/models/post_model.dart'   hide TeacherPostModel;
import '../../../core/models/user_model.dart'  hide UserModel;
import '../../../core/widgets/no_internet_widget.dart';
import '../widgets/posts_body.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../widgets/stories.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final postsCubit = context.read<GetPostsCubit>();
    final coursesCubit = context.read<GetCoursesCubit>();
    final storiesCubit = context.read<StoriesCubit>();


    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("الرئيسية"),
      ),
      body: StreamBuilder<ConnectivityResult>(
        stream: Connectivity().onConnectivityChanged.map(
          (eventList) => eventList.first,
        ),

        builder: (context, snapshot) {
          final isTeacher = context.watch<GetUserDataCubit>().isTeacher;
          final teacherIds = context.watch<GetUserDataCubit>().groups
              .map((group) => group.teacher_id)
              .toSet()
              .toList();

          // أول حاجة اتأكد إن الداتا وصلت
          if (!snapshot.hasData) {
            // ممكن تعرض مؤشر تحميل أو شاشة فاضية لحد ما ييجي النت
            return Center(child: CircularProgressIndicator());
          }

          final connectivityResult = snapshot.data!;

          if (connectivityResult == ConnectivityResult.none) {
            // مفيش نت يا معلم
            return  NoInternetWidget(
              onPressed: () async {
                await postsCubit.getPosts(groups:context.watch<GetUserDataCubit>().groups, isTeacher: isTeacher);

                await coursesCubit.getAllCourses(isTeacher: context.read<GetUserDataCubit>().isTeacher,teacherIdsForStudent: context
                    .read<GetUserDataCubit>()
                    .groups
                    .map((e) => e.teacher_id)
                    .whereType<String>()
                    .toList(), teacher_id: Supabase.instance.client.auth.currentUser!.id,
                );

                await storiesCubit.getStories(isTeacher: isTeacher,userId: Supabase.instance.client.auth.currentUser!.id,teacherIds: teacherIds);
              },
            );
          }

          // لو فيه نت كمل عرض الصفحة العادية
          final state = context.watch<GetPostsCubit>().state;
          final stateSory = context.watch<StoriesCubit>().state;

          bool isLoading =
              state is GetPostsLoading ||
                  stateSory is GetStoriesLoading ||
              !snapshot.hasData ||
              state is DeletePostLoading ||
                  stateSory is DeleteStoryLoading ||
              state is UpdatePostLoading;

          bool isError =
              state is DeletePostError ||
              state is GetPostsError ||
                  stateSory is GetStoriesError;

          return isError
              ?  NoInternetWidget(
            onPressed: () async {
              await postsCubit.getPosts(groups:context.watch<GetUserDataCubit>().groups, isTeacher: isTeacher);

              await coursesCubit.getAllCourses(isTeacher: context.read<GetUserDataCubit>().isTeacher,teacherIdsForStudent: context
                  .read<GetUserDataCubit>()
                  .groups
                  .map((e) => e.teacher_id)
                  .whereType<String>()
                  .toList(), teacher_id: Supabase.instance.client.auth.currentUser!.id,
              );


              await storiesCubit.getStories(isTeacher: isTeacher,userId: Supabase.instance.client.auth.currentUser!.id,teacherIds: teacherIds);
            },
          )
              : RefreshIndicator(
                onRefresh: () async {
                  await postsCubit.getPosts(groups:context.read<GetUserDataCubit>().groups, isTeacher: isTeacher);

                  await storiesCubit.getStories(isTeacher: isTeacher,userId: Supabase.instance.client.auth.currentUser!.id,teacherIds: teacherIds);
                },
                child: Skeletonizer(
                  enabled: isLoading,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: BlocBuilder<StoriesCubit, StoriesState>(
                          builder: (context, state) {
                            if (state is GetStoriesLoading ||
                                state is GetStoriesError|| isLoading) {

                              return StoriesBar(
                                storiesByTeacher: {
                                  TeacherModel(
                                    id: '1',
                                    imageUrl: 'https://i.pravatar.cc/100?img=1',
                                    createdAt: DateTime.now(),
                                  ): [
                                    StoryModel(
                                      userId: "u1",
                                      id: "s1",
                                      createdAt: DateTime.now(),
                                      isSeen: false,
                                      user: UserModel(id: 'u1', name: 'الأستاذ حسنين', email: '', phone: '', stageId: '', parent_phone: ''),
                                    ),
                                  ],

                                  TeacherModel(
                                    id: '2',
                                    imageUrl: 'https://i.pravatar.cc/100?img=2',
                                    createdAt: DateTime.now(),
                                  ): [
                                    StoryModel(
                                      userId: "u2",
                                      id: "s2",
                                      createdAt: DateTime.now(),
                                      isSeen: false,
                                      user: UserModel(id: 'u2', name: 'الأستاذ شوقي', email: '', phone: '', stageId: '', parent_phone: ''),
                                    ),
                                  ],

                                  TeacherModel(
                                    id: '3',
                                    imageUrl: 'https://i.pravatar.cc/100?img=3',
                                    createdAt: DateTime.now(),
                                  ): [
                                    StoryModel(
                                      userId: "u3",
                                      id: "s3",
                                      createdAt: DateTime.now(),
                                      isSeen: false,
                                      user: UserModel(id: 'u3', name: 'الأستاذ لطفي', email: '', phone: '', stageId: '', parent_phone: ''),
                                    ),
                                  ],
                                },
                              );

                            } else if (context
                                .read<StoriesCubit>()
                                .stories
                                .isEmpty) {
                              return const SizedBox.shrink();
                            } else {
                              return StoriesBar(
                                storiesByTeacher: context.watch<StoriesCubit>().storiesByTeacher,
                              );
                            }
                          },
                        ),
                      ),
                      PostsBody(
                        isTeacher: isTeacher,
                        posts: isLoading ? _dummyPosts : postsCubit.posts,

                        // posts: isLoading ? _dummyPosts :isTeacher? postsCubit.posts:postsCubit.posts.where((element) => user!.user_groups.any((e) => e?.id==element.group.id,),).toList(),
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
              );
        },
      ),
    );
  }

  List<PostModel> get _dummyPosts => List.generate(
    2,
    (index) => PostModel(
      id: '',
      createdAt: DateTime.now(),
      text: '',
      imageUrl:
          'https://cdn.pixabay.com/photo/2023/07/03/22/56/teaching-8105121_1280.jpg',
      deleteImageUrl:
          'https://cdn.pixabay.com/photo/2023/07/03/22/56/teaching-8105121_1280.jpg',
      groupId: '',
      userId: '',
      user: UserPostModel(
        id: 'id',
        email: 'email',
        name: 'name',
        phone: 'phone',
        stageId: '', password: '', deviceId: '', fcmToken: '', createdAt: DateTime.now(), teachers: [],
      ),
      comments: [],
      likes: [],
      polls: [],
      pollVotes: [], group: GroupModel(id: '', name: '' , stages: StageModel(id: '', name: '', createdAt: DateTime.now()), stageId: '', createdAt: DateTime.now(), numberOfStudents: '', teacher_id: '',teacher:TeacherPostModel(
      id: '',
      imageUrl: '',
      createdAt: DateTime.now(),
      user: UserPostModel(id: '', name: '', email: '', phone: '', stageId: '', password: '', deviceId: '', fcmToken: '', createdAt: DateTime.now(), teachers: []),

    ),  ),
    ),
  );
}

