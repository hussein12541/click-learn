import 'package:e_learning/core/logic/score/score_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constant/constant.dart';
import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import '../../../core/logic/theme/theme_cubit.dart';
import '../../../main.dart';
import '../../booking_screen/views/booking_view.dart';
import '../../quizzes_screen/widgets/user_quiz_chart_screen.dart';
import '../widgets/Payment.dart';
import '../widgets/change_password.dart';
import '../widgets/change_profile.dart';
import '../widgets/qr_screen.dart';
import '../widgets/select_teacher_payment.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  void openWhatsApp(String phone) async {
    final Uri whatsappUrl = Uri.parse("https://wa.me/$phone");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      // لو الواتساب مش متسطب أو في مشكلة في الفتح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح الواتساب حالياً')),
      );
    }
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  Future<void> _toggleThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = context.watch<ThemeCubit>().state;
    return Scaffold(
      body: BlocBuilder<GetUserDataCubit, GetUserDataState>(
        builder: (context, state) {
          if (state is GetUserDataLoading || state is GetUserDataError) {
            // هنا العرض في حالة الانتظار
            return const Center(child: CircularProgressIndicator());
          } else if (state is GetUserDataSuccess) {
            // هنا العرض لما البيانات جاهزة
            final user = state.userModel;
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                SizedBox(height: 50.h),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        child: SvgPicture.asset(
                          'assets/images/images/user.svg',
                          height: 30.r,
                          width: 30.r,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.name ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 10),

                      /// زر التعديل ✏️
                      TextButton.icon(
                        onPressed: () {
                          // هنا تروح لشاشة التعديل
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                name: user?.name ?? "",
                                phone: user?.phone ?? "",
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 20),
                        label: const Text('تعديل الملف الشخصي'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                const Text(
                  'الإعدادات العامة',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildSwitchItem(
                  title: 'الوضع الليلي',
                  icon: Icons.dark_mode,
                  value: isDark,
                  onChanged: (newVal) async {
                    await context.read<ThemeCubit>().toggleTheme();
                  },
                ),
                !context.read<GetUserDataCubit>().isTeacher?_buildMenuItem(
                  title: 'الحجز',
                  icon: Icon(Icons.how_to_reg,
                    color: kLightPrimaryColor,

                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookingView()),
                    );
                  },
                ):SizedBox.shrink(),
                BlocListener<ScoreCubit, ScoreState>(
                  listener: (context, state) {
                    if (state is GetStudentScoreSuccess) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserQuizChartScreen(user: state.studentScores.first),
                        ),
                      );
                    }
                  },
                  child: !context.read<GetUserDataCubit>().isTeacher
                      ? BlocBuilder<ScoreCubit, ScoreState>(
                    builder: (context, state) => _buildMenuItem(
                      title: 'تقرير بحالة الطالب',
                      icon: (state is GetStudentScoreLoading)
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.bar_chart, color: kLightPrimaryColor),
                      onTap: () {
                        context.read<ScoreCubit>().getScoreForStudent(
                            studentId: Supabase.instance.client.auth.currentUser!.id);
                      },
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
                !context.read<GetUserDataCubit>().isTeacher?_buildMenuItem(
                  title: 'الدفع',
                  icon: Icon(Icons.payment,
                    color: kLightPrimaryColor,

                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TeachersScreenPayment()),
                    );
                  },
                ):SizedBox.shrink(),  !context.read<GetUserDataCubit>().isTeacher?_buildMenuItem(
                  title: 'QR Code',
                  icon: Icon(Icons.qr_code_2,
                    color: kLightPrimaryColor,

                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QrScreen()),
                    );
                  },
                ):SizedBox.shrink(),


                _buildMenuItem(
                  title: 'الدعم الفني',
                  icon: Icon(Icons.support_agent, color: kLightPrimaryColor),
                  onTap: () {
                    openWhatsApp('994409773547');
                  },
                ),

                _buildMenuItem(
                  title: 'تغيير كلمة المرور',
                  icon: Icon(Icons.password_sharp, color: kLightPrimaryColor),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                _buildAboutItem(),
                SizedBox(height: 16.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    minimumSize: const Size.fromHeight(48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    final prefs = await SharedPreferences.getInstance();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MyApp()),
                      (route) => false,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("تسجيل الخروج"),
                      SizedBox(width: 18.w),
                      Icon(Icons.logout, size: 18.h),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildAboutItem() {
    return AboutListTile(
      icon: const Icon(Icons.info_outline),
      applicationIcon: const Icon(Icons.school, size: 40),
      applicationName: 'منصة التعليم',
      applicationVersion: 'الإصدار 1.0.0',
      applicationLegalese: '© جميع الحقوق محفوظة لمنصة التعليم',
      aboutBoxChildren: const [
        SizedBox(height: 12),
        Text(
          'هذا التطبيق هو منصة تعليمية متكاملة تهدف إلى تسهيل الوصول إلى المحتوى الدراسي، ومتابعة التقدم، وتقديم اختبارات تفاعلية.\n\nسواء كنت طالب أو معلم، تقدر تستخدم التطبيق لتبادل المعرفة، حل الأسئلة، ومتابعة كل جديد بطريقة سهلة وبسيطة. 💡📚',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String title,
    required Widget? icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon,
      title: Text(
        title,
        style: const TextStyle(color: Color(0xff949D9E), fontSize: 14),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

Widget _buildSwitchItem({
  required String title,
  required IconData icon,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return SwitchListTile(
    secondary: Icon(icon, color: kLightPrimaryColor),
    title: Text(title),
    value: value,
    onChanged: onChanged,
  );
}
