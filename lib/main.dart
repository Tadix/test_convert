import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart' as sound;
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart' as ap;

void main() {
  runApp(const FlutterSound());
}

class FlutterSound extends StatelessWidget {
  const FlutterSound({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TestFlutterSound(),
    );
  }
}

class TestFlutterSound extends StatefulWidget {
  const TestFlutterSound({super.key});

  @override
  State<TestFlutterSound> createState() => _TestFlutterSoundState();
}

class _TestFlutterSoundState extends State<TestFlutterSound> {
  Uint8List? audioBytes;
  // Get the application documents directory
  final directory = getApplicationDocumentsDirectory();
  late File file = File("${directory}downM3.mp3");
  // final url =
  //     "http://184.174.38.111:8081/api/v1/data/messages/u317_1681643185_yOlAyjchfZieBhdcB0Vrb[…]4f4e49f6f524e6d973c947aeb4d7421677cc81d945eb2e5e3762a2319cf";
  final url =
      "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3";
  Future<void> loadAudio() async {
    final response = await http.get(Uri.parse(url));
    setState(() {
      audioBytes = response.bodyBytes;
      file.writeAsBytes(response.bodyBytes);
    });
  }

  AudioPlayer audioPlayer = AudioPlayer();
  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void _playFromAsset() async {
    await audioPlayer.setAsset('assets/audio.mp3');
    await audioPlayer.play();
  }

  void _playFromNetwork() async {
    await audioPlayer.setUrl(url);
    await audioPlayer.play();
  }

  void playFromFile({File? flie_}) {
    if (flie_ != null) {
      audioPlayer.setFilePath(flie_.path);
    } else {
      audioPlayer.setFilePath(file.path);
    }

    audioPlayer.play();
  }

  void _pause() async {
    await audioPlayer.pause();
  }

  void _stop() async {
    await audioPlayer.stop();
  }

//  void playFromBytes()async {
//   // byte array containing audio data.
//   final codec = Codec();
//   final dataBuffer = DataBuffer(bytes);
//   final source = await codec.createByteDataSource(dataBuffer);

//   await audioPlayer.setAudioSource(source);

//   // play();
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
                // onPressed: () => loadAudio().then((value) => playFromFile()),
                onPressed: () => _playFromNetwork(),
                child: Text("Play")),
            TextButton(
                // onPressed: () => loadAudio().then((value) => playFromFile()),
                onPressed: () => _pause(),
                child: Text("pause")),
            TextButton(
                // onPressed: () => loadAudio().then((value) => playFromFile()),
                onPressed: () => _stop(),
                child: Text("stop")),
            TextButton(
                // onPressed: () => loadAudio().then((value) => playFromFile()),
                onPressed: () => showAudioRecorder(context),
                child: Text("Record")),
          ],
        ),
      ),
    );
  }
}

Future<File> mp3Convertor(String media) async {
  String tempDir =
      "/data/user/0/com.example.test/app_flutter"; //await getApplicationDocumentsDirectory();
  final inputFile = File('${tempDir}/input.m4a');
  File _mp3File = File('${tempDir}/output.mp3');
  await inputFile.writeAsBytes(await File(media).readAsBytes());

  final ffmpegCommand = "ffmpeg -i $inputFile -c:a libmp3lame -q:a 8 $_mp3File";
  // '-i ${inputFile.path} -c:a libmp3lame ${_mp3File.path}';

  await FFmpegKit.executeAsync(ffmpegCommand).then((session) => log(session
      .getOutput()
      .then((value) => log("session: ${value ?? "null"}"))
      .toString()));

  return _mp3File;
}

Future<dynamic>? showAudioRecorder(context) {
  bool isRecord = false;
  bool showPlayer = false;
  ap.AudioSource? audioSource;
  String path2 = "";
  AudioPlayer audioPlayer = AudioPlayer();
  void playFromFile({File? flie_}) {
    if (flie_ != null) {
      audioPlayer.setFilePath(flie_.path);
    } else {
      log("file : $flie_");
    }

    audioPlayer.play();
  }

  showGeneralDialog(
    barrierLabel: "Audio recorder",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 300),
    context: context,
    pageBuilder: (_, __, ___) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black38,
          body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  Container(
                      height: 250,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          )),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 200,
                            child: AudioRecorder(
                              onStop: (String path) {
                                File record = File(path);
                                log(path);
                                playFromFile(flie_: File(path));
                                // mp3Convertor(path).then(
                                //     (value) => );
                              },
                            ),
                          ),

                          // !isRecord
                          //     ? Container(
                          //         height: 100,
                          //         width: 100,
                          //         decoration: BoxDecoration(
                          //             color: secondaryGray.withOpacity(0.2),
                          //             borderRadius: BorderRadius.circular(200)),
                          //         child: InkWell(
                          //             onTap: () {
                          //               setState(() {
                          //                 isRecord = true;
                          //               });
                          //             },
                          //             child: Icon(Icons.mic_sharp,color: accentColor,size:40,)))
                          //     : Container(
                          //         height: 100,
                          //         width: 100,
                          //         decoration: BoxDecoration(
                          //             color: secondaryGray.withOpacity(0.2),
                          //             borderRadius: BorderRadius.circular(200)),
                          //         child: InkWell(
                          //             onTap: () {
                          //               setState(() {
                          //                 isRecord = false;
                          //               });
                          //             },
                          //             child: Icon(Icons.stop_circle,size:40,color:negativeColor))),
                        ],
                      ))
                ],
              ),
            );
          }),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      const begin = Offset(0.0, 0.7);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = anim.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({required this.onStop, Key? key}) : super(key: key);

  final void Function(String path) onStop;

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        ObjectFlagProperty<void Function(String path)>.has('onStop', onStop));
  }
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;
  final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();

  Amplitude? _amplitude;

  @override
  void initState() {
    _isRecording = false;
    _start();

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ampTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildRecordStopControl(),
              const SizedBox(width: 20),
              _buildPauseResumeControl(),
              const SizedBox(width: 20),
              // _buildText(),
            ],
          ),
          if (_amplitude != null) ...<Widget>[
            const SizedBox(height: 40),
            _buildTimer()
          ],
        ],
      ),
    );
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    if (_isRecording || _isPaused) {
      icon = Icon(Icons.send,
          color: Colors.greenAccent.withOpacity(0.1), size: 30);
      color = Colors.greenAccent.withOpacity(0.1);
    } else {
      final ThemeData theme = Theme.of(context);
      icon = Icon(Icons.send,
          color: Colors.greenAccent.withOpacity(0.1), size: 30);
      color = Colors.greenAccent.withOpacity(0.1).withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(
              width: 56,
              height: 56,
              child: _isRecording ? icon : SizedBox.shrink()),
          onTap: () {
            _isRecording ? _stop() : null; //_start();
          },
        ),
      ),
    );
  }

  Widget _buildPauseResumeControl() {
    if (!_isRecording && !_isPaused) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;

    if (!_isPaused) {
      icon = Icon(Icons.pause,
          color: Colors.greenAccent.withOpacity(0.1), size: 30);
      color = Colors.greenAccent.withOpacity(0.1).withOpacity(0.1);
    } else {
      final ThemeData theme = Theme.of(context);
      icon = Icon(Icons.play_arrow,
          color: Colors.greenAccent.withOpacity(0.1), size: 30);
      color = Colors.greenAccent.withOpacity(0.1).withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            _isPaused ? _resume() : _pause();
          },
        ),
      ),
    );
  }

  // Widget _buildText() {
  //   if (_isRecording || _isPaused) {
  //     return _buildTimer();
  //   }

  //   return const Text('Waiting to record');
  // }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Color.fromARGB(255, 49, 177, 175)),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  Future<void> _start() async {
    late String path;
    getLocalPath().then((value) => path = value);
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
            path: path + '/myFile.m4a', encoder: AudioEncoder.AAC);

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
          _recordDuration = 0;
        });

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    final String? path = await _audioRecorder.stop();

    widget.onStop(path!);

    setState(() => _isRecording = false);

    Navigator.of(context).pop();
  }

  Future<void> _pause() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    await _audioRecorder.pause();

    setState(() => _isPaused = true);
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();

    setState(() => _isPaused = false);
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });

    _ampTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      _amplitude = await _audioRecorder.getAmplitude();
      setState(() {});
    });
  }
  //   @override
  // void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  //   super.debugFillProperties(properties);

  //   properties
  //       .add(DiagnosticsProperty<ap.AudioSource?>('audioSource', audioSource));
  // }
}


// import 'dart:async';

// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:test/common.dart';

// // You might want to provide this using dependency injection rather than a
// // global variable.
// late AudioHandler _audioHandler;

// Future<void> main() async {
//   _audioHandler = await AudioService.init(
//     builder: () => AudioPlayerHandler(),
//     config: const AudioServiceConfig(
//       androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
//       androidNotificationChannelName: 'Audio playback',
//       androidNotificationOngoing: true,
//     ),
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Audio Service Demo',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const MainScreen(),
//     );
//   }
// }

// class MainScreen extends StatelessWidget {
//   const MainScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Audio Service Demo'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Play/pause/stop buttons.
//             StreamBuilder<bool>(
//               stream: _audioHandler.playbackState
//                   .map((state) => state.playing)
//                   .distinct(),
//               builder: (context, snapshot) {
//                 final playing = snapshot.data ?? false;
//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (playing)
//                       Container(
//                         color: Colors.grey,
//                         child: _button(
//                           Icons.pause,
//                           _audioHandler.pause,
//                         ),
//                       )
//                     else
//                       _button(Icons.play_arrow, _audioHandler.play),
//                     StreamBuilder<MediaState>(
//                       stream: _mediaStateStream,
//                       builder: (context, snapshot) {
//                         final mediaState = snapshot.data;
//                         return SeekBar(
//                           bufferedPosition: Duration.zero,
//                           duration:
//                               mediaState?.mediaItem?.duration ?? Duration.zero,
//                           position: mediaState?.position ?? Duration.zero,
//                           onChangeEnd: (newPosition) {
//                             _audioHandler.seek(newPosition);
//                           },
//                         );
//                       },
//                     ),
//                   ],
//                 );
//               },
//             ),
//             // A seek bar.
//           ],
//         ),
//       ),
//     );
//   }

//   /// A stream reporting the combined state of the current media item and its
//   /// current position.
//   Stream<MediaState> get _mediaStateStream =>
//       Rx.combineLatest2<MediaItem?, Duration, MediaState>(
//           _audioHandler.mediaItem,
//           AudioService.position,
//           (mediaItem, position) => MediaState(mediaItem, position));

//   Container _button(IconData iconData, VoidCallback onPressed) => Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//           border: Border.all(color: false ? Colors.white : Colors.black),
//           borderRadius: BorderRadius.circular(40)),
//       child: Center(
//           child: IconButton(
//               onPressed: () async {
//                 onPressed();
//                 // loadAudio().then((value) async => await audioPlayer.stop());
//                 // setState(() {
//                 //   isReading = false;
//                 // });
//                 // if (!_chatController.isLoadingAudio) {
//                 //  ;
//                 // }
//               },
//               icon: Icon(iconData,
//                   size: 20, color: true ? Colors.black : Colors.black))));
// }

// class MediaState {
//   final MediaItem? mediaItem;
//   final Duration position;

//   MediaState(this.mediaItem, this.position);
// }

// /// An [AudioHandler] for playing a single item.
// class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
//   static final _item = MediaItem(
//     id: 'http://184.174.38.111:8081/api/v1/data/messages/u317_1681643185_yOlAyjchfZieBhdcB0Vrb7eOtL6PjpXX6oA43FMF.m4a?signature=4807f4f4e49f6f524e6d973c947aeb4d7421677cc81d945eb2e5e3762a2319cf',
//     album: "Science Friday",
//     title: "A Salute To Head-Scratching Science",
//     artist: "Science Friday and WNYC Studios",
//     duration: const Duration(milliseconds: 5739820),
//     artUri: Uri.parse(
//         'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
//   );

//   final _player = AudioPlayer();

//   /// Initialise our audio handler.
//   AudioPlayerHandler() {
//     // So that our clients (the Flutter UI and the system notification) know
//     // what state to display, here we set up our audio handler to broadcast all
//     // playback state changes as they happen via playbackState...
//     _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
//     // ... and also the current media item via mediaItem.
//     mediaItem.add(_item);

//     // Load the player.
//     // AudioSource.uri(Uri.parse(_item.id)
//     _player.setAudioSource(AudioSource.uri(Uri.parse(
//         'http://184.174.38.111:8081/api/v1/data/messages/u317_1681643185_yOlAyjchfZieBhdcB0Vrb7eOtL6PjpXX6oA43FMF.m4a?signature=4807f4f4e49f6f524e6d973c947aeb4d7421677cc81d945eb2e5e3762a2319cf')));
//   }

//   // In this simple example, we handle only 4 actions: play, pause, seek and
//   // stop. Any button press from the Flutter UI, notification, lock screen or
//   // headset will be routed through to these 4 methods so that you can handle
//   // your audio playback logic in one place.

//   @override
//   Future<void> play() => _player.play();

//   @override
//   Future<void> pause() => _player.pause();

//   @override
//   Future<void> seek(Duration position) => _player.seek(position);

//   @override
//   Future<void> stop() => _player.stop();

//   /// Transform a just_audio event into an audio_service state.
//   ///
//   /// This method is used from the constructor. Every event received from the
//   /// just_audio player will be transformed into an audio_service state so that
//   /// it can be broadcast to audio_service clients.
//   PlaybackState _transformEvent(PlaybackEvent event) {
//     return PlaybackState(
//       controls: [
//         MediaControl.rewind,
//         if (_player.playing) MediaControl.pause else MediaControl.play,
//         MediaControl.stop,
//         MediaControl.fastForward,
//       ],
//       systemActions: const {
//         MediaAction.seek,
//         MediaAction.seekForward,
//         MediaAction.seekBackward,
//       },
//       androidCompactActionIndices: const [0, 1, 3],
//       processingState: const {
//         ProcessingState.idle: AudioProcessingState.idle,
//         ProcessingState.loading: AudioProcessingState.loading,
//         ProcessingState.buffering: AudioProcessingState.buffering,
//         ProcessingState.ready: AudioProcessingState.ready,
//         ProcessingState.completed: AudioProcessingState.completed,
//       }[_player.processingState]!,
//       playing: _player.playing,
//       updatePosition: _player.position,
//       bufferedPosition: _player.bufferedPosition,
//       speed: _player.speed,
//       queueIndex: event.currentIndex,
//     );
//   }
// }

// // import 'package:flutter/material.dart';

// // void main() {
// //   runApp(const TestAudioOnIOS());
// // }

// // class TestAudioOnIOS extends StatefulWidget {
// //   const TestAudioOnIOS({super.key});

// //   @override
// //   State<TestAudioOnIOS> createState() => _TestAudioOnIOSState();
// // }

// // class _TestAudioOnIOSState extends State<TestAudioOnIOS> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         body: Center(

// //           child: Text("test")),
// //       ),
// //     );
// //   }
// // }

// // // import 'dart:async';

// // // import 'package:audio_service/audio_service.dart';
// // // // import 'package:example/audio_player.dart';
// // // import 'package:flutter/foundation.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_sound_record/flutter_sound_record.dart';
// // // import 'package:just_audio/just_audio.dart' as ap;
// // // import 'package:audio_service/audio_service.dart';
// // // import 'package:just_audio/just_audio.dart';
// // // // import 'package:audio_service_example/common.dart';

// // // class AudioRecorder extends StatefulWidget {
// // //   const AudioRecorder({required this.onStop, Key? key}) : super(key: key);

// // //   final void Function(String path) onStop;

// // //   @override
// // //   _AudioRecorderState createState() => _AudioRecorderState();
// // //   @override
// // //   void debugFillProperties(DiagnosticPropertiesBuilder properties) {
// // //     super.debugFillProperties(properties);
// // //     properties.add(ObjectFlagProperty<void Function(String path)>.has('onStop', onStop));
// // //   }
// // // }

// // // class _AudioRecorderState extends State<AudioRecorder> {
// // //   bool _isRecording = false;
// // //   bool _isPaused = false;
// // //   int _recordDuration = 0;
// // //   Timer? _timer;
// // //   Timer? _ampTimer;
// // //   final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();
// // //   Amplitude? _amplitude;

// // //   @override
// // //   void initState() {
// // //     _isRecording = false;
// // //     super.initState();
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _timer?.cancel();
// // //     _ampTimer?.cancel();
// // //     _audioRecorder.dispose();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       home: Scaffold(
// // //         body: Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: <Widget>[
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: <Widget>[
// // //                 _buildRecordStopControl(),
// // //                 const SizedBox(width: 20),
// // //                 _buildPauseResumeControl(),
// // //                 const SizedBox(width: 20),
// // //                 _buildText(),
// // //               ],
// // //             ),
// // //             if (_amplitude != null) ...<Widget>[
// // //               const SizedBox(height: 40),
// // //               Text('Current: ${_amplitude?.current ?? 0.0}'),
// // //               Text('Max: ${_amplitude?.max ?? 0.0}'),
// // //             ],
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildRecordStopControl() {
// // //     late Icon icon;
// // //     late Color color;

// // //     if (_isRecording || _isPaused) {
// // //       icon = const Icon(Icons.stop, color: Colors.red, size: 30);
// // //       color = Colors.red.withOpacity(0.1);
// // //     } else {
// // //       final ThemeData theme = Theme.of(context);
// // //       icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
// // //       color = theme.primaryColor.withOpacity(0.1);
// // //     }

// // //     return ClipOval(
// // //       child: Material(
// // //         color: color,
// // //         child: InkWell(
// // //           child: SizedBox(width: 56, height: 56, child: icon),
// // //           onTap: () {
// // //             _isRecording ? _stop() : _start();
// // //           },
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildPauseResumeControl() {
// // //     if (!_isRecording && !_isPaused) {
// // //       return const SizedBox.shrink();
// // //     }

// // //     late Icon icon;
// // //     late Color color;

// // //     if (!_isPaused) {
// // //       icon = const Icon(Icons.pause, color: Colors.red, size: 30);
// // //       color = Colors.red.withOpacity(0.1);
// // //     } else {
// // //       final ThemeData theme = Theme.of(context);
// // //       icon = const Icon(Icons.play_arrow, color: Colors.red, size: 30);
// // //       color = theme.primaryColor.withOpacity(0.1);
// // //     }

// // //     return ClipOval(
// // //       child: Material(
// // //         color: color,
// // //         child: InkWell(
// // //           child: SizedBox(width: 56, height: 56, child: icon),
// // //           onTap: () {
// // //             _isPaused ? _resume() : _pause();
// // //           },
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildText() {
// // //     if (_isRecording || _isPaused) {
// // //       return _buildTimer();
// // //     }

// // //     return const Text('Waiting to record');
// // //   }

// // //   Widget _buildTimer() {
// // //     final String minutes = _formatNumber(_recordDuration ~/ 60);
// // //     final String seconds = _formatNumber(_recordDuration % 60);

// // //     return Text(
// // //       '$minutes : $seconds',
// // //       style: const TextStyle(color: Colors.red),
// // //     );
// // //   }

// // //   String _formatNumber(int number) {
// // //     String numberStr = number.toString();
// // //     if (number < 10) {
// // //       numberStr = '0$numberStr';
// // //     }

// // //     return numberStr;
// // //   }

// // //   Future<void> _start() async {
// // //     try {
// // //       if (await _audioRecorder.hasPermission()) {
// // //         await _audioRecorder.start();

// // //         bool isRecording = await _audioRecorder.isRecording();
// // //         setState(() {
// // //           _isRecording = isRecording;
// // //           _recordDuration = 0;
// // //         });

// // //         _startTimer();
// // //       }
// // //     } catch (e) {
// // //       if (kDebugMode) {
// // //         print(e);
// // //       }
// // //     }
// // //   }

// // //   Future<void> _stop() async {
// // //     _timer?.cancel();
// // //     _ampTimer?.cancel();
// // //     final String? path = await _audioRecorder.stop();

// // //     widget.onStop(path!);

// // //     setState(() => _isRecording = false);
// // //   }

// // //   Future<void> _pause() async {
// // //     _timer?.cancel();
// // //     _ampTimer?.cancel();
// // //     await _audioRecorder.pause();

// // //     setState(() => _isPaused = true);
// // //   }

// // //   Future<void> _resume() async {
// // //     _startTimer();
// // //     await _audioRecorder.resume();

// // //     setState(() => _isPaused = false);
// // //   }

// // //   void _startTimer() {
// // //     _timer?.cancel();
// // //     _ampTimer?.cancel();

// // //     _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
// // //       setState(() => _recordDuration++);
// // //     });

// // //     _ampTimer = Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
// // //       _amplitude = await _audioRecorder.getAmplitude();
// // //       setState(() {});
// // //     });
// // //   }
// // // }
// // // late AudioHandler _audioHandler;
// // // void main()async {
// // //   //  _audioHandler = await AudioService.init(
// // //   //   builder: () => AudioPlayerHandler(),
// // //   //   config: const AudioServiceConfig(
// // //   //     androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
// // //   //     androidNotificationChannelName: 'Audio playback',
// // //   //     androidNotificationOngoing: true,
// // //   //   ),
// // //   // );
// // //   runApp(const MyApp());
// // // }

// // // class MyApp extends StatefulWidget {
// // //   const MyApp({Key? key}) : super(key: key);

// // //   @override
// // //   _MyAppState createState() => _MyAppState();
// // // }

// // // class _MyAppState extends State<MyApp> {
// // //   bool showPlayer = false;
// // //   ap.AudioSource? audioSource;

// // //   @override
// // //   void initState() {
// // //     showPlayer = false;
// // //     super.initState();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       home: Scaffold(
// // //         body: Center(
// // //           child: showPlayer
// // //               ?
// // //               SizedBox()
// // //               // Padding(
// // //               //     padding: const EdgeInsets.symmetric(horizontal: 25),
// // //               //     child: AudioPlayer(
// // //               //       source: audioSource!,
// // //               //       onDelete: () {
// // //               //         setState(() => showPlayer = false);
// // //               //       },
// // //               //     ),
// // //               //   )
// // //               : AudioRecorder(
// // //                   onStop: (String path) {
// // //                     setState(() {
// // //                       audioSource = ap.AudioSource.uri(Uri.parse(path));
// // //                       showPlayer = true;
// // //                     });
// // //                   },
// // //                 ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void debugFillProperties(DiagnosticPropertiesBuilder properties) {
// // //     super.debugFillProperties(properties);
// // //     properties.add(DiagnosticsProperty<bool>('showPlayer', showPlayer));
// // //     properties.add(DiagnosticsProperty<ap.AudioSource?>('audioSource', audioSource));
// // //   }
// // // }
