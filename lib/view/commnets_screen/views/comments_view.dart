import 'package:e_learning/core/logic/get_comments/get_comments_cubit.dart';
import 'package:e_learning/core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import '../../../core/models/comments_model.dart';
import '../../../core/models/replay_model.dart';
import '../widgets/comment_tile.dart'; // Ensure you have this in pubspec.yaml




class CommentsPage extends StatefulWidget {
  final List<CommentModel> comments;
  final String post_id;

  const CommentsPage({super.key, required this.comments, required this.post_id});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}


class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  final Map<String, TextEditingController> _replyControllers = {};
  String? _replyingToCommentId; // Using _ for private member
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    // Initialize timeago locales if you haven't elsewhere
    timeago.setLocaleMessages('ar', timeago.ArMessages());
  }

  Future<void> _addComment(BuildContext context,) async {
    if (_commentController.text.trim().isEmpty) return;
    String id = Uuid().v4();
    final newComment = CommentModel(
      comment: _commentController.text.trim(),
      postId: widget.post_id,
      userId: Supabase.instance.client.auth.currentUser!.id,
      createdAt: DateTime.now(),
      replay: [],
      user: context.read<GetUserDataCubit>().userModel?? UserModel(
        id: Supabase.instance.client.auth.currentUser!.id,
        email: '',
        name: '',
        phone: '',
        user_groups: [ ], stageId: '', parent_phone: '',
      ),
      id: id,
    );

    await context.read<GetCommentsCubit>().addComment(
      post_id: widget.post_id,
      comment: _commentController.text.trim(), comment_id:newComment.id,
    );

    if (!mounted) return; // 🚑 الإسعافات الأولية قبل الـ setState

    setState(() {
      widget.comments.insert(0, newComment);
      _commentController.clear();
      if (widget.comments.length > 1) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  Future<void> _addReply(String commentId) async {
    final controller = _replyControllers[commentId];
    if (controller == null || controller.text.trim().isEmpty) return;

    final commentIndex =
    widget.comments.indexWhere((comment) => comment.id == commentId);

    if (commentIndex != -1) {
      final newReply = ReplayModel(
        id: UniqueKey().toString(), // Consider UUID
        replay: controller.text.trim(),
        commentId: commentId,
        userId: 'user_reply_test', // Placeholder: Replace with actual user ID/name
        createdAt: DateTime.now(), user:  context.read<GetUserDataCubit>().userModel??UserModel(id: '', email: '', name: '', phone: '', user_groups: [], stageId: '', parent_phone: ''),
      );
      await context.read<GetCommentsCubit>().addReplay(
        comment_id:commentId ,
        replay: controller.text.trim(),
      );
      setState(() {
        widget.comments[commentIndex].replay.insert(0, newReply); // Insert at beginning for newest first
        controller.clear();
        _replyingToCommentId = null; // Hide reply input after sending
      });
    }
  }

  Future<void> _deleteComment(BuildContext context, String commentId) async {
    await context.read<GetCommentsCubit>().deleteComment(comment_id: commentId);

    if (!mounted) return; // 🚑 الإسعافات الأولية قبل أي حاجة

    setState(() {
      // حذف التعليق من القائمة
      widget.comments.removeWhere((comment) => comment.id == commentId);

      // مسح خانة التعليق لو فيها حاجة
      _commentController.clear();

      // لو في تعليقات كتير، نرجّع السكرول لفوق
      if (widget.comments.length > 1) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _deleteReply(BuildContext context, String replyId) async {
    await context.read<GetCommentsCubit>().deleteReplay(replay_id: replyId);

    if (!mounted) return;

    setState(() {
      // نمر على كل تعليق ونشيل الرد اللي id بتاعه هو replyId
      for (var comment in widget.comments) {
        comment.replay.removeWhere((reply) => reply.id == replyId);
      }
    });
  }




  @override
  void dispose() {
    _commentController.dispose();
    _replyControllers.forEach((_, controller) => controller.dispose());
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Set default locale for timeago for this widget tree, if needed
    // This is useful if your app supports multiple languages.
    // For Arabic specifically:
    timeago.setDefaultLocale('ar');


    return Scaffold(
      appBar: AppBar(
        title: const Text('التعليقات'),
        elevation: 1.0, // Subtle elevation for AppBar
        backgroundColor: theme.colorScheme.surface, // Use theme colors
        foregroundColor: theme.colorScheme.onSurface, // Use theme colors
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: false, // Set to false to show newest comments at the top with insert(0, ...)
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: widget.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.comments[index];
                // Ensure a controller exists for each comment's reply input
                _replyControllers.putIfAbsent(comment.id, () => TextEditingController());

                return CommentTile(
                  comment: comment,
                  isReplying: _replyingToCommentId == comment.id,
                  replyController: _replyControllers[comment.id]!,
                  onReplyPressed: () {
                    setState(() {
                      _replyingToCommentId =
                      _replyingToCommentId == comment.id ? null : comment.id;
                    });
                  },
                  onSendReply: () => _addReply(comment.id), onDeleteComment:() => _deleteComment(context, comment.id), onDeleteReply: (String replyId) async {
                    await _deleteReply(context, replyId);
                } ,
                );
              },
            ),
          ),
          if (_replyingToCommentId == null)
            _buildCommentInputArea(context),
        ],
      ),
    );
  }

  // Extracted comment input area to a separate method for clarity
  Widget _buildCommentInputArea(BuildContext context,) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;


    return Container(
      padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 8.0,
          bottom: MediaQuery.of(context).padding.bottom + 8.0 // Handle safe area
      ),
      decoration: BoxDecoration(
        color: theme.cardColor, // Or theme.scaffoldBackgroundColor for seamless look
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1), // Shadow on top
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'أكتب تعليقك...',
                fillColor: theme.colorScheme.surface.withOpacity(0.5),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
              keyboardType:TextInputType.multiline ,
              onSubmitted: (_) async => await _addComment(context,),
              minLines: 1,
              maxLines: 5, // Allow multi-line comments
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon( Icons.send, color: theme.colorScheme.primary),
            onPressed: ()async => await _addComment(context),
            tooltip: 'إرسال',
          ),
        ],
      ),
    );
  }
}



