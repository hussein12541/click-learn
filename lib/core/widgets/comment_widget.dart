// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
//
//
// class CommentWidget extends StatefulWidget {
//   const CommentWidget({
//     super.key,
//     required this.name,
//     required this.date,
//     required this.comment,
//     this.reply, // الرد الواحد فقط
//   });
//
//   final String name;
//   final String date;
//   final String comment;
//   final String? reply; // الرد الواحد فقط وليس List
//
//   @override
//   State<CommentWidget> createState() => _CommentWidgetState();
// }
//
// class _CommentWidgetState extends State<CommentWidget> {
//   bool showReply = false; // يتم تحديد ما إذا كان الرد سيظهر أم لا
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(12.r),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 8.r,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// الاسم والتاريخ
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 widget.name,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 15,
//                   color: Colors.black87,
//                 ),
//               ),
//               Text(
//                 widget.date,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8.h),
//
//           /// نص التعليق
//           Text(
//             widget.comment,
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.grey[800],
//               height: 1.6,
//             ),
//           ),
//
//           /// زر عرض الرد (فقط إذا كان هناك رد)
//           if (widget.reply != null) ...[
//             SizedBox(height: 10.h),
//             GestureDetector(
//               onTap: () {
//                 setState(() {
//                   showReply = !showReply; // التبديل بين إظهار الرد وإخفائه
//                 });
//               },
//               child: Text(
//                 showReply ? "إخفاء الردود" : "عرض الردود",
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.blue,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//
//           /// الرد نفسه (يُعرض فقط إذا تم الضغط على الزر)
//           if (showReply && widget.reply != null) ...[
//             SizedBox(height: 12.h),
//             Container(
//
//               padding: EdgeInsets.only(left: 12.w),
//               child: Padding(
//                 padding: EdgeInsets.only(top: 8.h),
//                 child: Text(
//                   widget.reply!, // عرض الرد فقط
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[800],
//                     height: 1.5,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
