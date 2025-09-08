import 'dart:developer';

import 'package:e_learning/core/logic/get_posts/get_posts_cubit.dart';
import 'package:e_learning/core/models/comments_model.dart';
import 'package:e_learning/core/models/post_model.dart' hide UserPostModel;
import 'package:e_learning/core/models/user_model.dart';
import 'package:e_learning/view/main_screen/widgets/post_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constant/constant.dart';
import '../../../core/logic/get_comments/get_comments_cubit.dart';
import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import '../../commnets_screen/views/comments_view.dart';

class PostsBody extends StatelessWidget {
  const PostsBody({
    super.key,
    required this.posts,
    required this.isLoading, required this.isTeacher,
  });

  final List<PostModel> posts;
  final bool isLoading;
  final bool isTeacher;

  @override
  Widget build(BuildContext context) {
    log(Supabase.instance.client.auth.currentUser!.id);

    if (posts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("لا توجد منشورات متاحة.."),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final post = posts[index];
          return PostCard(
            postTime: post.createdAt,
            userName: post.user.name,
            userImageUrl: post.user.teachers.isNotEmpty
                ? post.user.teachers[0].imageUrl
                : 'https://via.placeholder.com/150', // أو صورة افتراضية في الأصول

            postText: post.text,
            postImageUrl: post.imageUrl ?? '',
            likesCount: post.likes.length,
            commentsCount: post.comments.length,
            onLikePressed: () async {
              await context.read<GetPostsCubit>().addLike(post_id: post.id);
            },
            onDeleteLikePressed: () async {
              await context.read<GetPostsCubit>().deleteLike(post_id: post.id);
            },
            onCommentPressed: () {
              final commentCubit = GetCommentsCubit();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: commentCubit..getComments(post_id: post.id),
                    child: BlocBuilder<GetCommentsCubit, GetCommentsState>(
                      builder: (context, state) {
                        if (state is GetCommentsSuccess) {
                          return CommentsPage(
                            comments: commentCubit.comments,
                            post_id: post.id,
                          );
                        } else {
                          return Skeletonizer(
                            enabled: true,
                            child: CommentsPage(
                              post_id: post.id,
                              comments: List.generate(
                                3,
                                    (index) => CommentModel(
                                  user: UserModel(
                                    id: 'id',
                                    email: 'email',
                                    name: 'name',
                                    phone: 'phone',
                                    user_groups: [], stageId: '', parent_phone: 'parent_phone',
                                  ),
                                  id: 'id',
                                  comment: 'loading...',
                                  postId: 'postId',
                                  userId: 'userId',
                                  createdAt: DateTime.now(),
                                  replay: [],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ).then((_) {
                context.read<GetPostsCubit>().getPosts(groups:context.read<GetUserDataCubit>().groups, isTeacher: isTeacher);
              });
            },
            isLike: post.likes.any((like) => like.userId == Supabase.instance.client.auth.currentUser!.id),
            isLoading: isLoading,
            post: post, groupName:isTeacher? "${post.group.name}/${post.group.stages.name}":"",
          );
        },
        childCount: posts.length,
      ),
    );
  }
}
