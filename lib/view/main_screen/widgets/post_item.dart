import 'package:e_learning/core/constant/constant.dart';
import 'package:e_learning/core/logic/addVote/add_vote_cubit.dart';
import 'package:e_learning/core/logic/get_posts/get_posts_cubit.dart';
import 'package:e_learning/core/models/post_model.dart';
import 'package:e_learning/core/widgets/showMessage.dart';
import 'package:e_learning/view/main_screen/widgets/post_action_button_with_count.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 🆕 إضافة المكتبة
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import '../../../core/models/poll_vote_model.dart';
import 'build_read_more_text.dart';

class PostCard extends StatefulWidget {
  final DateTime postTime;
  final String userName;
  final String userImageUrl;
  final String postText;
  final String groupName;
  final String postImageUrl;
  final int likesCount;
  final int commentsCount;
  final Future<void> Function()? onLikePressed;
  final Future<void> Function()? onDeleteLikePressed;
  final VoidCallback? onCommentPressed;
  final bool isLike;
  final bool isLoading;
  final PostModel post;

  const PostCard({
    super.key,
    required this.postTime,
    required this.userName,
    required this.userImageUrl,
    required this.postText,
    required this.postImageUrl,
    this.likesCount = 200,
    this.commentsCount = 200,
    this.onLikePressed,
    this.onDeleteLikePressed,
    this.onCommentPressed,
    required this.isLike,
    this.isLoading = false,
    required this.post, required this.groupName,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  bool isProcessing = false;
  int likesCount = 0;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isLike;
    likesCount = widget.likesCount;
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<GetUserDataCubit>().isTeacher;
    String currentUserId = Supabase.instance.client.auth.currentUser!.id;
    // Determine if the user has voted and which option they selected
    final hasVoted =
        widget.post.pollVotes.any((vote) => vote.userId == currentUserId);
    final userVotedOptionId =
        hasVoted
            ? widget.post.pollVotes
                .firstWhere((vote) => vote.userId == currentUserId)
                .optionId
            : null;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.only(left: 12.w, top: 12.h, right: 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Row
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24.r,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: widget.userImageUrl,
                            fit: BoxFit.cover,
                            width: 48.r,
                            height: 48.r,
                            placeholder: (context, url) => Skeletonizer(
                              enabled: true,
                              child: Container(
                                width: 48.r,
                                height: 48.r,
                                color: Colors.grey[300],
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userName,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          Text(
                            timeago.format(widget.postTime, locale: 'ar'),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ده هو الجزء الجديد بتاع PopupMenuButton
                isTeacher?PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      // هتكتب هنا الفنكشن بتاع تعديل البوست
                      // ممكن تفتح bottom sheet أو صفحة تعديل
                      _showEditPostSheet(context);
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('تأكيد الحذف'),
                          content: const Text('هل أنت متأكد من حذف هذا المنشور؟'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirm ?? false) {
                        await context.read<GetPostsCubit>().deletePost(post: widget.post);
                        ShowMessage.showToast(backgroundColor: Colors.green,'تم حذف المنشور');
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف'),
                        ],
                      ),
                    ),
                  ],
                ):SizedBox.shrink(),
              ],
            ),

            SizedBox(height: 12.h),

            // Post Text
            BuildReadMoreText(postText: widget.postText),
            if (widget.postImageUrl.trim().isNotEmpty) SizedBox(height: 12.h),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.post.polls.isNotEmpty)
                  BlocBuilder<AddVoteCubit, AddVoteState>(
                    builder:
                        (context, state) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: FlutterPolls(
                            pollId:  widget.post.id,
                            // Fallback to post.id if pollId is null
                            pollTitle: Text(''),
                            votedBackgroundColor:  Theme.of(context).colorScheme.primary.withOpacity(0.2),

                            pollOptions:
                                widget.post.polls
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => PollOption(
                                        id: entry.value.id,
                                        title: Text(
                                          entry.value.optionText,

                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                        ),
                                        votes:
                                            widget.post.pollVotes
                                                .where(
                                                  (vote) =>
                                                      vote.optionId ==
                                                      entry.value.id,
                                                )
                                                .length, // Count votes for this option
                                      ),
                                    )
                                    .toList(),
                            onVoted: (
                              PollOption pollOption,
                              int newTotal,
                            ) async {

                              await context.read<AddVoteCubit>().addVote(
                                post_id: widget.post.id,
                                option_id: pollOption.id!,
                                user_id:
                                    Supabase
                                        .instance
                                        .client
                                        .auth
                                        .currentUser!
                                        .id,
                              );

                              final updatedPost = widget.post.copyWith(
                                pollVotes: [
                                  ...widget.post.pollVotes,
                                  PollVoteModel(
                                    id: '',
                                    postId: widget.post.id,
                                    createdAt: DateTime.now(),
                                    userId: Supabase.instance.client.auth.currentUser!.id,
                                    optionId: pollOption.id!,
                                    user: widget.post.user,
                                  ),
                                ],
                              );

                              context.read<GetPostsCubit>().updatePost(updatedPost);

                              return true;

                            },
                            pollOptionsHeight: 36.h,
                            pollOptionsBorderRadius: BorderRadius.circular(
                              8.r,
                            ),
                            pollOptionsFillColor:
                                Theme.of(context).colorScheme.surfaceContainerHighest,
                            voteInProgressColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            hasVoted: hasVoted,
                            userVotedOptionId: userVotedOptionId,
                          ),
                        ),
                  ),
                // Post Image
                if (widget.postImageUrl.trim().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: GestureDetector(
                      onTap: () {
                        showImageViewer(
                          context,
                          CachedNetworkImageProvider(
                            widget.postImageUrl.trim(),
                          ),
                          swipeDismissible: true,
                          doubleTapZoomable: true,
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: widget.postImageUrl.trim(),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200.h,
                        placeholder:
                            (context, url) => Skeletonizer(
                              enabled: true,
                              child: Container(
                                width: double.infinity,
                                height: 200.h,
                                color: Colors.grey[300],
                              ),
                            ),
                        errorWidget:
                            (context, url, error) =>
                                const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 12.h),

            // Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // خلي Row ده عادي بدون Expanded
                Row(
                  children: [
                    ActionButtonWithCount(
                      icon: isLiked ? Icons.favorite_outlined : Icons.favorite_border,
                      count: likesCount,
                      onPressed: widget.isLoading || isProcessing
                          ? null
                          : () async {
                        if (isProcessing) return;

                        setState(() {
                          isProcessing = true;
                        });

                        try {
                          if (isLiked) {
                            await widget.onDeleteLikePressed?.call();
                          } else {
                            await widget.onLikePressed?.call();
                          }

                          setState(() {
                            isLiked = !isLiked;
                            isLiked ? likesCount++ : likesCount--;
                          });
                        } catch (e) {
                          debugPrint('🔥 Error: $e');
                          ShowMessage.showToast('حدث خطأ');
                        } finally {
                          setState(() {
                            isProcessing = false;
                          });
                        }
                      },
                    ),
                    ActionButtonWithCount(
                      iconWidget: widget.isLoading
                          ? const Icon(Icons.comment)
                          : SvgPicture.asset(
                        'assets/images/images/Chat.svg',
                        height: 20.h,
                        width: 20.w,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      count: widget.commentsCount,
                      onPressed: widget.onCommentPressed,
                    ),
                  ],
                ),

                // ده اللي نديه Expanded عشان يملأ المساحة الباقية
                Expanded(
                  child: Text(
                    widget.groupName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: kPrimaryColor,
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
  void _showEditPostSheet(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: widget.postText);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // عشان يطلع مع الكيبورد
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 16.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تعديل نص المنشور',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller,
                maxLines: null,
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  hintText: 'اكتب النص الجديد هنا...',
                ),
              ),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: () async {
                  final newText = controller.text.trim();
                  if (newText.isEmpty) {

                    ShowMessage.showToast('النص لا يمكن أن يكون فارغًا');

                    return;
                  }
                  // هنا هنعمل تحديث للبوست بالنص الجديد
                  final updatedPost = widget.post.copyWith(text: newText);

                  try {
                    // افترض ان عندك method لتحديث البوست في GetPostsCubit
                    await context.read<GetPostsCubit>().updateTextPost(id:widget.post.id,name:newText );
                     context.read<GetPostsCubit>().updatePost(updatedPost );
                    Navigator.pop(context); // غلق البوتوم شيت

                    ShowMessage.showToast(backgroundColor: Colors.green,'تم تحديث المنشور');

                  } catch (e) {
                    ShowMessage.showToast('حدث خطأ');

                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 44.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text('حفظ'),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }

}
