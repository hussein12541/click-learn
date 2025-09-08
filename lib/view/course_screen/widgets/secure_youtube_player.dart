import 'package:e_learning/core/constant/constant.dart';
import 'package:e_learning/core/models/lesson_model.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:screen_protector/screen_protector.dart';

class SecureYoutubePlayerPage extends StatefulWidget {
  final LessonModel lesson;

  const SecureYoutubePlayerPage({super.key, required this.lesson});

  @override
  State<SecureYoutubePlayerPage> createState() => _SecureYoutubePlayerPageState();
}

class _SecureYoutubePlayerPageState extends State<SecureYoutubePlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    // فعل حماية الشاشة (منع سكرين شوت وتسجيل الشاشة)
    ScreenProtector.preventScreenshotOn();
    ScreenProtector.protectDataLeakageOn();
    final videoId = YoutubePlayer.convertUrlToId(widget.lesson.vedioUrl!);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,

        mute: false,
        disableDragSeek: true,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    ScreenProtector.preventScreenshotOff(); // افصل الحماية لما تخرج من الصفحة
    ScreenProtector.protectDataLeakageOff(); // افصل الحماية لما تخرج من الصفحة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _controller),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(title: const Text('مشاهدة الفيديو')),
          body: Center(child: Column(
            children: [
              player,
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.lesson.name,style: TextStyle(fontSize: kFontSize16),),
              )
            ],
          )),
        );
      },
    );
  }
}
