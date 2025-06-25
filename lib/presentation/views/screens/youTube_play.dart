// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../utils/screen_size.dart';

class YouTubePlay extends StatefulWidget {
  YouTubePlay({super.key, required this.id, required this.title});

  String id;
  String title;

  @override
  State<YouTubePlay> createState() => _YouTubePlayState();
}

class _YouTubePlayState extends State<YouTubePlay> {
  late YoutubePlayerController _ytController;

  @override
  void initState() {
    //가로, 세로모드 모두 허용!!
    //dispose()에 가로모드 금지를 해야 나머지 화면에 가로모드 금지가 활성화된다.
    SystemChrome.setPreferredOrientations([]);

    _ytController = YoutubePlayerController(
      initialVideoId: widget.id,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        captionLanguage: 'ko',
        forceHD: true,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    //가로모드 금지
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(
              fontSize: ScreenSize.sWidth * 25,
              fontWeight: FontWeight.bold,
              color: Colors.indigoAccent,
            ),
          ),
          centerTitle: true,
        ),
        body: YoutubePlayer(
          key: ObjectKey(_ytController),
          controller: _ytController,
          liveUIColor: Colors.amber,
        ));
  }
}
