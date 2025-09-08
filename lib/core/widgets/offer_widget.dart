// import 'package:e_commerce_app/core/constant/constant.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
//
// import 'offer_item_button.dart';
//
// class OfferWidget extends StatelessWidget {
//   const OfferWidget({super.key, required this.color});
//   final Color color;
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(4.r),
//       child: SizedBox(
//
//         width: MediaQuery.sizeOf(context).width * 0.9,
//         height: 158.h,
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             Align(alignment: Alignment.centerLeft,child: Image.asset('assets/image/images/test.png',fit: BoxFit.contain,)),
//             SvgPicture.asset(color: color,'assets/image/images/Ellipse.svg',alignment: Alignment.centerRight,),
//             Align(
//               alignment: Alignment.centerRight,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 8.0),
//                   child: // Inside the OfferWidget's Column
//                   Column(
//                     crossAxisAlignment: kIsArabic() ? CrossAxisAlignment.start : CrossAxisAlignment.end,
//                     children: [
//                       Expanded(child: Container()), // Top spacer
//                       Text(
//                         "عروض العيد",
//                         style: TextStyle(
//                           color: CupertinoColors.white.withOpacity(.8),
//                           fontSize: kFontSize13,
//                           fontWeight: FontWeight.w200,
//                           fontFamily: 'Cairo_regular',
//                         ),
//                       ),
//                       SizedBox(height: 15.h),
//                       Text(
//                         "خصم 25%",
//                         style: TextStyle(
//                           color: CupertinoColors.white,
//                           fontSize: kFontSize19,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       SizedBox(height: 10.h),
//                       SizedBox(
//                         height: 40.h, // Constrained button height
//                         child: OfferItemButton(onPressed: () {}),
//                       ),
//                       Expanded(child: Container()), // Bottom spacer
//                     ],
//                   )
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
