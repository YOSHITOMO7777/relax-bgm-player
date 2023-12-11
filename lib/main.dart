import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _setupSession();

    // AudioPlayerの状態を取得
    _player.playbackEventStream.listen((event) {
      switch(event.processingState) {
        case ProcessingState.idle:
          debugPrint('オーディオファイルをロードしていないよ');
          break;
        case ProcessingState.loading:
          debugPrint('オーディオファイルをロード中だよ');
          break;
        case ProcessingState.buffering:
          debugPrint('バッファリング(読み込み)中だよ');
          break;
        case ProcessingState.ready:
          debugPrint('再生できるよ');
          break;
        case ProcessingState.completed:
          debugPrint('再生終了したよ');
          break;
        default:
          debugPrint(event.processingState.toString());
          break;
      }
    });
  }

  Future<void> _setupSession() async {
    _player = AudioPlayer();
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await _loadAudioFile();
  }

  Future<void> _loadAudioFile() async {
    try {
      await _player.setAsset('assets/audio/bgm_sea.mp3');
    } catch(e) {
      debugPrint(e as String?);
    }
  }

  Future<void> _playBgm() async {
    debugPrint('再生ボタンが押されました');
    await _player.play();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You can start BGM !!',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => await _playBgm(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
