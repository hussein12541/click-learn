import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:e_learning/core/constant/constant.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../data_base/crud.dart';
import '../../data_base/my_sql_database.dart';
import '../../models/story_model.dart'hide UserModel;

import '../../notification/cloud_messaging.dart';
import '../upload_posts/post_cubit.dart';

part 'stories_state.dart';

class StoriesCubit extends Cubit<StoriesState> {
  StoriesCubit() : super(StoriesInitial());
  String? fileUrl;

  String? deleteFileUrl;
  int? duration;

  final ApiServices _api = ApiServices();

  Future<void> uploadFileToSupabase(File file) async {
    final supabase = Supabase.instance.client;
    final bucketName = 'postsimages';

    // توليد UUID
    var uuid = Uuid();
    String uniqueId = uuid.v4();

    // ناخد الامتداد بتاع الملف
    String fileExtension = file.path.split('.').last;

    // نعمل اسم جديد للملف فيه UUID + الامتداد
    String fileName = '$uniqueId.$fileExtension';

    final response = await supabase.storage
        .from(bucketName)
        .upload(fileName, file);

    fileUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
    deleteFileUrl = fileName;
    print('✅ Uploaded with UUID! URL: $fileUrl');
  }

  Future<void> deleteImageFromSupabase(String fileName) async {
    final supabase = Supabase.instance.client;

    const bucketName = 'postsimages'; // غيرها لو انت مسمي الـ bucket باسم مختلف

    final response = await supabase.storage.from(bucketName).remove([fileName]);
    print('✅ الصورة اتحذفت يا ريس!');
  }

  Future<void> uploadImageToImgBB(File imageFile) async {
    final dio = Dio();
    final apiKey = 'cc7a90a66b3de75b4769a57876a44395';

    // نحول الصورة لـ MultipartFile عشان نرفعها
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      "key": apiKey,
    });

    final response = await dio.post(
      'https://api.imgbb.com/1/upload',
      data: formData,
    );

    fileUrl = response.data['data']['url'];
    deleteFileUrl = response.data['data']['delete_url'];

    log(response.data['data'].toString());
  }


  Future<int?> getVideoDuration(File file) async {
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    final duration = controller.value.duration;
    await controller.dispose();
    return duration.inSeconds;
  }

  Future<void> sendNotifications({
    required String body,
    required String title,
    required String teacherId,
  }) async {
    List<UserModel> users = [];

    // 🟢 جلب المستخدمين مع بيانات الجروبات والجروب
    Response response = await _api.getData(
      path: 'users?select=*,user_groups(*,groups(*))',
    );

    for (var userJson in response.data) {
      users.add(UserModel.fromJson(userJson));
    }

    // ✅ فلترة المستخدمين اللي ليهم علاقة بالمدرس و ليهم FCM Token
    final validUsers = users.where((user) {
      final hasToken = user.fcmToken != null && user.fcmToken!.isNotEmpty;
      final subscribedToTeacherGroup = user.user_groups.any(
            (ug) => ug?.group != null && ug!.group!.teacher_id == teacherId,
      );
      return hasToken && subscribedToTeacherGroup;
    }).toList();

    const int batchSize = 100;

    for (int i = 0; i < validUsers.length; i += batchSize) {
      final batch = validUsers.skip(i).take(batchSize).toList();

      // ⏳ تجهيز دفعة الإشعارات
      List<Future> futures = batch.map((user) {
        return NotificationService.sendNotification(
          user.fcmToken!,
          title,
          body,
        );
      }).toList();

      // 🚀 إرسال الدفعة
      await Future.wait(futures);

      // ⏱️ راحة خفيفة بين الدُفعات (نص ثانية)
      if (i + batchSize < validUsers.length) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }




  Future<void> uploadStory({
    required bool isVideo,
    required String teacherName,
    required bool isImage,
    required File? file,
    required String text,
  }) async {
    try {
      String? imgUrl;
      String? vedioUrl;
      fileUrl = null;
      deleteFileUrl = null;
      duration = null;
      emit(AddStoryLoading());
      if (file != null) {
        if (isImage) {
          try {
            // المحاولة الأولى
            await uploadImageToImgBB(file);
            // لو نجح نكمل
            print('✅ تم رفع الصورة من أول مرة');
          } catch (e) {
            print('⚠️ فشل الرفع أول مرة: $e');
            try {
              // المحاولة الثانية
              await uploadFileToSupabase(file);
              print('✅ تم رفع الصورة من المحاولة التانية');
            } catch (secondError) {
              emit(AddStoryError());
              print('❌ فشل الرفع مرتين: $secondError');
              rethrow;
            }
          }
        }
        if (isVideo) {
          try {
            // المحاولة الثانية
            duration = await getVideoDuration(file);

            await uploadFileToSupabase(file);
            print('✅ تم رفع الفيديو');
          } catch (e) {
            emit(AddStoryError());
            print('❌ فشل رفع الفيديو : $e');
            rethrow;
          }
        }
      }
      if (isVideo) {
        vedioUrl = fileUrl;
      }
      if (isImage) {
        imgUrl = fileUrl;
      }
      await _api.postData(
        path: 'stories',
        data: {
          "text": text,
          "img_url": imgUrl,
          "vedio_url": vedioUrl,
          "duration": duration,
          "user_id": Supabase.instance.client.auth.currentUser!.id,
          "delete_file_url": deleteFileUrl,
        },
      );
      try {
        await sendNotifications(body: 'لقد قام ${teacherName} بنشر حالة جديد', title: text, teacherId: Supabase.instance.client.auth.currentUser!.id, );
      } on Exception catch (e) {
        log(e.toString());
      }

      emit(AddStorySuccess());
    } catch (e) {
      log(e.toString());
      emit(AddStoryError());
    }
  }
  List<StoryModel> stories = [];
  Map<TeacherModel, List<StoryModel>> storiesByTeacher = {};

  Future<void> getStories({
    required bool isTeacher,
    required String userId,
    List<String> teacherIds = const [],
  }) async {
    try {
      stories = [];
      storiesByTeacher = {};
      emit(GetStoriesLoading());

      late String path;

      if (isTeacher) {
        path =
        'stories?select=*,users(*,teachers(*))&user_id=eq.$userId&order=created_at.desc';
      } else {
        if (teacherIds.isEmpty) {
          emit(GetStoriesSuccess());
          return;
        }

        final teachersFilter =
        teacherIds.map((id) => 'user_id.eq.$id').join(',');
        path =
        'stories?select=*,users(*,teachers(*))&or=($teachersFilter)&order=created_at.desc';
      }

      final response = await _api.getData(path: path);

      for (var storyJson in response.data) {
        StoryModel story = StoryModel.fromJson(storyJson);

        DateTime createdAt = story.createdAt;
        DateTime now = DateTime.now();

        Duration diff = now.difference(createdAt);
        if (diff.inHours >= 24) {
          await deleteStories(story: story);
        } else {
          stories.add(story);

          // 🧑‍🏫 استخرج TeacherModel من story.user
          final teacher = story.user.teacher!;
          if (!storiesByTeacher.containsKey(teacher)) {
            storiesByTeacher[teacher] = [];
          }
          storiesByTeacher[teacher]!.add(story);
        }
      }

      await loadStoriesWithSeenStatus(stories);

      emit(GetStoriesSuccess());
    } catch (e) {
      log("Error in getStories: $e");
      emit(GetStoriesError());
    }
  }



  Future<void> deleteStories({required StoryModel story}) async {
    try {
      emit(DeleteStoryLoading());
      if (story.delete_file_url != null) {
        if (!story.delete_file_url!.startsWith('http')) {
          await deleteImageFromSupabase(story.delete_file_url!);
        }
      }

      await _api.deleteData(path: 'stories?id=eq.${story.id}');
      emit(DeleteStorySuccess());
    } on Exception catch (e) {
      // TODO
      log(e.toString());
      emit(DeleteStoryError());
    }
  }

  MySqlDataBase sql=MySqlDataBase();

  Future<void> addStoryToSeen({required String id}) async {
    await sql.insert(tableName: kStoryTableName, values: {
      "id": id,
    });

    // ✅ حدّث في قائمة stories
    final index = stories.indexWhere((element) => element.id == id);
    if (index != -1) {
      final updatedStory = stories[index].copyWith(isSeen: true);
      stories[index] = updatedStory;

      // ✅ حدّث كمان في storiesByTeacher
      final teacher = updatedStory.user.teacher!;
      if (storiesByTeacher.containsKey(teacher)) {
        final teacherStories = storiesByTeacher[teacher]!;
        final teacherIndex = teacherStories.indexWhere((e) => e.id == id);
        if (teacherIndex != -1) {
          teacherStories[teacherIndex] = updatedStory;
          storiesByTeacher[teacher] = List.from(teacherStories); // علشان الـ UI يحصل له rebuild
        }
      }

      emit(GetStoriesSuccess()); // 🔥 تحدث الواجهة
    }
  }


  Future<void> deleteStoryFromSeen({required String id})async{
    await sql.delete(tableName: kStoryTableName, id: id, ColumnIDName: 'id');
  }




  Future<List<String>> getSeenStoriesIdsFromLocal() async {
    final result = await sql.select(tableName: kStoryTableName, where: null);
    return result.map((e) => e['id'].toString()).toList();
  }
  Future<bool> isStorySeen(String id) async {
    final result = await sql.select(
      tableName: kStoryTableName,
      where: "id = '$id'",
    );
    return result.isNotEmpty;
  }

  Future<void> loadStoriesWithSeenStatus(List<StoryModel> storiesFromServer) async {
    List<String> seenStoriesIds = await getSeenStoriesIdsFromLocal();

    // نحدد الـ IDs اللي على السيرفر
    final serverIds = storiesFromServer.map((story) => story.id).toSet();

    for (final id in seenStoriesIds) {
      if (!serverIds.contains(id)) {
        await deleteStoryFromSeen(id: id);
        print('🗑️ تم حذف القصة $id من الـ local لأنها مش موجودة على السيرفر');
      }
    }

    // نحدث الحالات بالـ isSeen
    List<StoryModel> updatedStories = storiesFromServer.map((story) {
      final isSeen = seenStoriesIds.contains(story.id);
      return story.copyWith(isSeen: isSeen);
    }).toList();

    // نحدّث الـ list العامة
    stories = updatedStories;

    // 🧠 نبني الـ Map من جديد
    final Map<TeacherModel, List<StoryModel>> grouped = {};

    for (var story in updatedStories) {
      final teacher = story.user.teacher!;
      grouped.putIfAbsent(teacher, () => []);
      grouped[teacher]!.add(story);
    }

    // نحدّث الماب العالمي
    storiesByTeacher = grouped;
  }

}
