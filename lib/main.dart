import 'package:e_learning/core/logic/get_posts/get_posts_cubit.dart';
import 'package:e_learning/core/logic/get_user_data/get_user_data_cubit.dart';
import 'package:e_learning/core/logic/score/score_cubit.dart';
import 'package:e_learning/view/splash_screen/splash_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'core/constant/constant.dart';
import 'core/logic/addVote/add_vote_cubit.dart';
import 'core/logic/add_poll/add_poll_cubit.dart';
import 'core/logic/auth/auth_cubit.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/logic/get_courses/get_courses_cubit.dart';
import 'core/logic/get_quizzes/get_quizzes_cubit.dart';
import 'core/logic/get_teachers/get_teachers_cubit.dart';
import 'core/logic/stories/stories_cubit.dart';
import 'core/logic/theme/theme_cubit.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission(); // 👈 ه
  timeago.setLocaleMessages('ar', timeago.ArMessages());


  await Supabase.initialize(
    url: kUrlSupabase,
    anonKey:kAnonKey,
  );

  await initializeLocalNotifications();
  setupFCMListener(); // بس كده


  runApp(
      BlocProvider(
        create: (_) => ThemeCubit(),
        child: const MyApp(),
  ));
}
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void setupFCMListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    final data = message.data;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: data['route'], // علشان تستخدمه في التنقل بعد كده
      );
    }
  });

}

Future<void> initializeLocalNotifications() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel',
    'Default',
    description: 'القناة الافتراضية للإشعارات',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              create: (context) => AuthCubit(),
            ),

            BlocProvider<GetTeachersCubit>(

            create: (context) => GetTeachersCubit(),
            )
            ,BlocProvider<GetUserDataCubit>(
              create: (context) => GetUserDataCubit()..fetchUserDataAndCheckExistence(id:Supabase.instance.client.auth.currentUser!.id ),
            ),
              BlocProvider<AddPollCubit>(
              create: (context) => AddPollCubit(),
            ), BlocProvider<GetQuizzesCubit>(
              create: (context) => GetQuizzesCubit()..getAllQuizzes(isTeacher: context.read<GetUserDataCubit>().isTeacher,teacherIdsForStudent: context
                  .read<GetUserDataCubit>()
                  .groups
                  .map((e) => e.teacher_id)
                  .whereType<String>()
                  .toList(), teacherId: Supabase.instance.client.auth.currentUser!.id,
              ),
            ),

            BlocProvider<GetPostsCubit>(

              create: (context) => GetPostsCubit()..getPosts(groups:context.read<GetUserDataCubit>().groups, isTeacher:context.read<GetUserDataCubit>().isTeacher ),
            ),
            BlocProvider<AddVoteCubit>(
              create: (context) => AddVoteCubit(),
            ),    BlocProvider<StoriesCubit>(
              create: (context) => StoriesCubit()..getStories(isTeacher:context.read<GetUserDataCubit>().isTeacher , userId: Supabase.instance.client.auth.currentUser!.id,teacherIds:context.read<GetUserDataCubit>().groups
            .map((group) => group.teacher_id)
            .toSet()
            .toList()
        ),
            ),
            BlocProvider<GetCoursesCubit>(
              create: (context) => GetCoursesCubit()..getAllStages()..getAllCourses(isTeacher: context.read<GetUserDataCubit>().isTeacher,teacherIdsForStudent: context
                  .read<GetUserDataCubit>()
                  .groups
                  .map((e) => e.teacher_id)
                  .whereType<String>()
                  .toList(), teacher_id: Supabase.instance.client.auth.currentUser!.id,
              ),

            ), BlocProvider<ScoreCubit>(
              create: (context) =>ScoreCubit(),
            ),

          ],
          child:     BlocBuilder<ThemeCubit, bool>(
            builder: (context, isDark) {return MaterialApp(
              title: 'Click&Learn',
              locale: const Locale('ar'),
              // 👈 اللغة العربية
              supportedLocales: const [
                Locale('ar'), // 👈 تدعم العربية فقط
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              themeMode:  isDark ? ThemeMode.dark : ThemeMode.light,
              theme: ThemeData(
                brightness: Brightness.light,
                fontFamily: "Cairo",
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.light,
                ),
                scaffoldBackgroundColor: Color(0xFFEEEFEF),

                appBarTheme: const AppBarTheme(
                  centerTitle: true,

                  backgroundColor: Color(0xFFEEEFEF),
                  foregroundColor: Colors.black,
                  elevation: 0,
                ),
                cardTheme: CardThemeData (
                  color: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.black),
                  bodyMedium: TextStyle(color: Colors.black),
                ),
              ),

              darkTheme: ThemeData(
                brightness: Brightness.dark,
                fontFamily: "Cairo",
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blueGrey,
                  brightness: Brightness.dark,
                ),
                scaffoldBackgroundColor: const Color(0xFF121212),
                appBarTheme: const AppBarTheme(
                  centerTitle: true,
                  backgroundColor: Color(0xFF121212),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                cardTheme: CardThemeData (
                  color: const Color(0xFF1E1E1E),
                  // لون أغمق شوية للكارت
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.white),
                  bodyMedium: TextStyle(color: Colors.white),
                ),
              ),

              home: SplashView(),
            );},
          ),
        );
      },
    );
  }
}
