import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp()
    ),
  );
}

final toggleSNP =
    StateNotifierProvider<ToggleSN, bool>((ref) => ToggleSN());

class ToggleSN extends StateNotifier<bool> {
  ToggleSN() : super(true) {
    // superには初期値を渡す
    soundPlayerInit();
  }

  void soundPlayerInit() async {
    // 音楽プレーヤーを初期化したりする
    state = true;
    soundControl();
  }

  void toggle() {
    state = !state;
    soundControl();
  }

  void change({required bool flag}) {
    state = flag;
    soundControl();
  }

  void soundControl() {
    if (state == true) {
      debugPrint('[soundControl]PLAY');
    } else {
      debugPrint('[soundControl]STOP');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
    } catch(e) {
      debugPrint(e as String?);
    }
  }

  // 再生・停止
  Future<void> _play(ref) async {
    // state==true:再生中, state==false:停止中
    ref.read(toggleSNP.notifier).toggle();
    ref.read(toggleSNP.notifier).state ?
      await _player.stop() : await _player.play();
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
            Consumer(builder: (context, ref, child) {
              final isFlag = ref.watch(toggleSNP);
              return FilledButton(
                onPressed: () async => await _play(ref),
                child: Icon((isFlag) ? Icons.play_arrow : Icons.pause),
              );
            }),
          ],
        ),
      ),
    );
  }
}
