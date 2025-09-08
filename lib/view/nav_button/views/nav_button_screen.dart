import 'package:e_learning/core/constant/constant.dart';

import 'package:e_learning/core/widgets/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import '../../../core/logic/get_user_data/get_user_data_cubit.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../add_screen/views/add_view.dart';
import '../../course_screen/views/stagess_view.dart';
import '../../course_screen/views/teacher_screen.dart';
import '../../course_screen/widgets/course_screen.dart';
import '../../main_screen/views/main_view.dart';
import '../../profle_screen/views/profle_view.dart';
import '../../quizzes_screen/view/quiz_view.dart';
import '../../quizzes_screen/view/stage_view.dart';
import '../../quizzes_screen/view/teachers_screen_quiz.dart';
import '../../removed_student/views/removed_student_view.dart';




class NavButton extends StatefulWidget {
  const NavButton({super.key});

  @override
  State<NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final id = Supabase.instance.client.auth.currentUser!.id;
    context.read<GetUserDataCubit>().fetchUserDataAndCheckExistence(id: id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<GetUserDataCubit, GetUserDataState>(
      builder: (context, state) {
        if (state is GetUserDataSuccess) {
          final cubit = context.read<GetUserDataCubit>();
          final isTeacher = cubit.isTeacher;
          final user = cubit.userModel;
          final exists = cubit.exists;
          final samePhone = cubit.samePhone;

          final pages = [
            const MainView(),
            isTeacher ? const ChooseActionPage() : TeachersScreenQuiz(),
            isTeacher ? StageListPage() :TeachersScreen(),
            isTeacher ? StageQuizListPage(teacherId: Supabase.instance.client.auth.currentUser!.id,) : const ProfileScreen(),
          ];

          if (!exists || !samePhone) return KickedOutPage(samePhone: samePhone);

          return Scaffold(
            body: pages[_selectedIndex],
            bottomNavigationBar: SafeArea(child: _buildNavBar(isDark, isTeacher)),
          );
        }

        if (state is GetUserDataLoading) {
          return const Scaffold(body: LoadingWidget());
        }

        return Scaffold(
          body: NoInternetWidget(
            onPressed: () {
              final id = Supabase.instance.client.auth.currentUser!.id;
              context.read<GetUserDataCubit>().fetchUserDataAndCheckExistence(id: id);
            },
          ),
        );
      },
    );
  }

  Widget _buildNavBar(bool isDark, bool isTeacher) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: GNav(
        selectedIndex: _selectedIndex,
        onTabChange: (index) => setState(() => _selectedIndex = index),
        haptic: true,
        tabBorderRadius: 15,
        activeColor: kLightPrimaryColor,
        rippleColor: kLightPrimaryColor,
        curve: Curves.easeOutExpo,
        duration: const Duration(milliseconds: 400),
        gap: 8,
        color: kLightPrimaryColor,
        iconSize: 24,
        tabBackgroundColor: kLightPrimaryColor.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tabs: [
          _navTab('الرئيسية', 'home.svg', 0),
          isTeacher
              ? _navTab('إضافة', 'add.svg', 1)
              : _navTab('الاختبارات', 'posts_icon.svg', 1),
          _navTab('الكورسات', 'myLearning.svg', 2),
          isTeacher
              ? _navTab('الاختبارات', 'posts_icon.svg', 3)
              : _navTab('حسابي', 'user.svg', 3),
        ],
      ),
    );
  }

  GButton _navTab(String text, String icon, int index) {
    return GButton(
      icon: Icons.circle,
      leading: _SvgIcon(
        'assets/images/images/$icon',
        _selectedIndex == index ? kLightPrimaryColor : Colors.grey[800],
      ),
      text: text,
    );
  }
}


class _SvgIcon extends StatelessWidget {
  final String assetName;
  final Color? color;

  const _SvgIcon(this.assetName, this.color);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      height: 24,
      width: 24,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}


