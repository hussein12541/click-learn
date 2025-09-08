import 'package:e_learning/view/login_screen/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KickedOutWidget extends StatefulWidget {
  final bool samePhone;
  const KickedOutWidget({super.key, required this.samePhone});

  @override
  State<KickedOutWidget> createState() => _KickedOutWidgetState();
}

class _KickedOutWidgetState extends State<KickedOutWidget> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Camera animation
                Lottie.asset(
                  'assets/json/camera1.json',
                  height: 120.h,
                  width: 120.w,
                  fit: BoxFit.contain,
                  repeat: true,























                ),
                // Security animation
                Column(
                  children: [
                    Lottie.asset(
                      'assets/json/security.json',

                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                    SizedBox(height: 24.h),
                    // Warning text
                    Text(
                      !widget.samePhone?"لا يمكنك التسجيل على هذا الهاتف":"تم طردك من المجموعة",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.redAccent,
                        letterSpacing: 0.5,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    // Additional description
                    Text(
                      !widget.samePhone?"هذا الحساب مسجل على هاتف آخر. إذا كان هذا هاتفك يرجى التواصل مع الدعم لحل المشكلة.":"لقد تم استبعادك من المجموعة. يرجى التواصل مع المدرس لمزيد من التفاصيل.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h,)

                  ],
                ),
                // Action button
                ElevatedButton(
                  onPressed: ()async {
                    // Add navigation or action here (e.g., go back or contact admin)
                    await Supabase.instance.client.auth.signOut();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginView(),));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    "تسجيل الخروج",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 24.h,)

              ],


            ),

          ),
        ),
      ),
    );
  }
}