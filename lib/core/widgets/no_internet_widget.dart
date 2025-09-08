import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const NoInternetWidget({
    super.key, required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // تحسين عرض الـ Lottie animation
            Container(
              child: Lottie.asset(
                'assets/json/no_internet.json',
                fit: BoxFit.contain, // ضبط الرسوم لتناسب الحاوية
                repeat: true, // تكرار الرسوم المتحركة
              ),
            ),
            const SizedBox(height: 24), // زيادة المسافة قليلاً للتناسق
            // تحسين النص باستخدام Theme وخط مخصص
            Text(
              "لا يوجد اتصال بالإنترنت، حاول مرة أخرى",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800], // لون داكن وأنيق
                letterSpacing: 0.5, // تباعد طفيف بين الحروف
              ),
              textAlign: TextAlign.center,
            ),
             SizedBox(height: 16.h),
            // إضافة زر لإعادة المحاولة لتحسين التجربة
            ElevatedButton(
              onPressed:onPressed ,
              style: ElevatedButton.styleFrom(
        
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // زوايا مستديرة
                ),
                elevation: 5, // ظل خفيف للزر
              ),
              child: const Text(
                "إعادة المحاولة",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
