import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../login_screen/views/login_view.dart';
import '../../nav_button/views/nav_button_screen.dart';

// Primary Colors



class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Scale animation for logo
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Start animation
    _controller.forward();

    // Execute navigation after delay
    excuteNaviagtion();
    checkNotificationPermission();
  }
  static Future<void> checkNotificationPermission( ) async {
    final status = await Permission.notification.status;

    if (!status.isGranted) {
      // نطلب الإذن لأول مرة
      final result = await Permission.notification.request();

    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDarkMode
        ? [
      Color(0xFF0D1117), // داكن جدًا
      Color(0xFF0A162E), // أزرق داكن جدًا
      Color(0xFF12366D), // أزرق داكن فيسبوكي
      Color(0xFF1877F2), // الأزرق المميز لفيسبوك
    ]
        : [
      Color(0xFFEEF3FF), // أزرق باهت جدًا - خلفية ناعمة
      Color(0xFFD9E7FF), // أزرق هادئ
      Color(0xFFB0CCFF), // أزرق متوسط
      Color(0xFF1877F2), // أزرق فيسبوك
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background with Primary Colors
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:gradientColors,

              ),

            ),
            ),

          // Centered App Logo with Fade and Scale Animation
          // Center(
          //   child: FadeTransition(
          //     opacity: _fadeAnimation,
          //     child: ScaleTransition(
          //       scale: _scaleAnimation,
          //       child: SvgPicture.asset(
          //         'assets/images/images/vecteezy_graduate.svg',
          //         height: 240.h,
          //         width: 240.w,
          //         fit: BoxFit.contain,
          //       ),
          //     ),
          //   ),
          // ),

         Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Lottie.asset(
                    repeat: false,

                    height: 300.h,
                    width: 300.w,
                    'assets/json/splash.json'),

              ),
            ),
          ),
          // Developer Logo at Bottom
          Positioned(
            bottom: 20.h,
            left: MediaQuery.of(context).size.width * 0.5 - 60.w,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ClipOval(
                child: Image.asset(

                  'assets/images/logo/hussein.png',
                  width: 120.w,
                  height: 120.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Powered by text with Light Secondary Color
        ],
      ),
    );
  }

  void excuteNaviagtion() {
    Future.delayed(const Duration(seconds: 2), () {
      final SupabaseClient client = Supabase.instance.client;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => client.auth.currentUser != null
                ? const NavButton()
                : const LoginView(),
          ),
        );
      }
    });
  }
}