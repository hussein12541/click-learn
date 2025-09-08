import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readmore/readmore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/models/comments_model.dart';
import '../../../core/models/replay_model.dart';

class CommentTile extends StatefulWidget {
  final CommentModel comment;
  final bool isReplying;
  final TextEditingController replyController;
  final VoidCallback onReplyPressed;
  final VoidCallback onSendReply;
  final VoidCallback onDeleteComment;
  final Future<void> Function(String replyId) onDeleteReply;




  const CommentTile({
    super.key,
    required this.comment,
    required this.isReplying,
    required this.replyController,
    required this.onReplyPressed,
    required this.onSendReply, required this.onDeleteComment, required this.onDeleteReply,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool _showReplies = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2.0, // Subtle elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(context, widget.comment.user.name, widget.comment.createdAt,true),
             SizedBox(height: 16.h),

            ReadMoreText(

              widget.comment.comment,


              trimLines: 3,
              trimMode: TrimMode.Line,
              trimCollapsedText: 'قراءة المزيد',
              trimExpandedText: 'عرض أقل',
             style:  theme.textTheme.bodyMedium?.copyWith(height: 1.4), // Improved line height
              moreStyle: GoogleFonts.cairo(
                fontSize: 11,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              lessStyle: GoogleFonts.cairo(
                fontSize: 11,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),


             SizedBox(height: 4.h),
            Align(
              alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
              child: TextButton.icon(
                icon: Icon(Icons.reply, size: 18, color: theme.colorScheme.primary),
                label: Text(
                  widget.isReplying ? 'إلغاء الرد' : 'رد',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
                onPressed: widget.onReplyPressed,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            if (widget.isReplying) _buildReplyInput(context, theme, isRtl),
            if (widget.comment.replay.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showReplies = !_showReplies;
                  });
                },
                child: Text(
                  _showReplies ? 'إخفاء الردود' : 'عرض الردود (${widget.comment.replay.length})',

                ),
              ),

            // الردود نفسها تظهر عند الضغط على الزر
            if (_showReplies)
              _buildReplies(context, theme, widget.comment.replay, isRtl),

          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, String name, DateTime createdAt,bool isComment) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U', // Placeholder avatar
            style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name, // In a real app, this would be the user's display name
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                timeago.format(createdAt, locale: 'ar'), // Ensure locale is set
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
    Spacer(),
       (widget.comment.user.id==Supabase.instance.client.auth.currentUser!.id && isComment)? IconButton(onPressed: widget.onDeleteComment, icon: Icon(CupertinoIcons.delete,color: Colors.red,))

        // Potentially add a more options button (e.g., for reporting, deleting)
        // IconButton(icon: Icon(Icons.more_vert), onPressed: () { /* ... */ })
      :SizedBox.shrink()],
    );
  }

  Widget _buildReplyInput(BuildContext context, ThemeData theme, bool isRtl) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.replyController,
              autofocus: true, // Autofocus when reply input appears
              decoration: InputDecoration(
                hintText: 'اكتب ردك...',
                filled: true,
                fillColor: theme.colorScheme.surface.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              ),
              minLines: 1,
              maxLines: 3,

              textInputAction: TextInputAction.send,
              onSubmitted: (_) => widget.onSendReply(),
            ),
          ),
          const SizedBox(width: 4),
          Align(
            alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
            child: IconButton(
              onPressed: widget.onSendReply,
              icon: Icon(Icons.send, ),
              tooltip:"إرسال",
              style: ElevatedButton.styleFrom(
                // backgroundColor: theme.colorScheme.primary,
                // foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplies(BuildContext context, ThemeData theme, List<ReplayModel> replies, bool isRtl) {
    return Padding(
      // Indent replies slightly more than the main comment text
      padding: EdgeInsets.only(top: 12.0, left: isRtl ? 0 : 20.0, right: isRtl ? 20.0 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: replies.map((reply) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            margin: const EdgeInsets.only(bottom: 8.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3), // Slightly different background for replies
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfo(context, reply.user.name, reply.createdAt,false),
                       SizedBox(height: 6.h),
                      Padding(
                        padding: EdgeInsets.only(left: isRtl ? 0 : 30.0, right: isRtl ? 30.0 : 0), // Further indent reply text
                        child:ReadMoreText(
                  
                              reply.replay,
                  
                  
                          trimLines: 3,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: 'قراءة المزيد',
                          trimExpandedText: 'عرض أقل',
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
                          moreStyle: GoogleFonts.cairo(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          lessStyle: GoogleFonts.cairo(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                  
                  
                  
                  
                      ),
                    ],
                  ),
                ),
                reply.user.id==Supabase.instance.client.auth.currentUser!.id? IconButton(onPressed:() async =>  await widget.onDeleteReply(reply.id), icon: Icon(CupertinoIcons.delete,color: Colors.red,)):SizedBox.shrink()
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
