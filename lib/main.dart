import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(
      const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RelaxMusicPlayer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Relax BGM Player'),
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
        case ProcessingState.loading:
          debugPrint('オーディオファイルをロード中だよ');
        case ProcessingState.buffering:
          debugPrint('バッファリング(読み込み)中だよ');
        case ProcessingState.ready:
          debugPrint('再生できるよ');
        case ProcessingState.completed:
          debugPrint('再生終了したよ');
      }
    });
  }

  // セッションの設定
  Future<void> _setupSession() async {
    _player = AudioPlayer();
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await _loadAudioFile();
  }

  // 音声ファイルの読み込み
  Future<void> _loadAudioFile() async {
    try {
      await _player.setAsset('assets/audio/bgm_sea.mp3');
    } on Exception catch(e) {
      debugPrint(e as String?);
    }
  }

  // 再生・停止
  void _playMusic(PlayerState playerState) {
    if(playerState.playing) {
      _player.stop();
    } else {
      _player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You can start BGM !!',
            ),
            // ボタンアイコンを再生状態によって変化させるためのストリーム
            StreamBuilder(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                return _playerButton(playerState!);
              },),
          ],
        ),
      ),
    );
  }

  // 再生状態によってアイコンが変化するボタン
  Widget _playerButton(PlayerState playerState) {
    return
      FilledButton(
        onPressed: () => _playMusic(playerState),
        child: Icon(playerState.playing ? Icons.pause : Icons.play_arrow,),
      );
  }
}
