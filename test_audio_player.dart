import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(AudioPlayerTestApp());
}

class AudioPlayerTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Player Test',
      home: AudioPlayerTestPage(),
    );
  }
}

class AudioPlayerTestPage extends StatefulWidget {
  @override
  _AudioPlayerTestPageState createState() => _AudioPlayerTestPageState();
}

class _AudioPlayerTestPageState extends State<AudioPlayerTestPage> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _audioPlayer = AudioPlayer();
    
    _audioPlayer!.onPositionChanged.listen((Duration position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer!.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer!.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  Future<void> _playTestAudio() async {
    try {
      // Test with a sample audio URL (this is a public domain sample)
      const testUrl = 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav';
      
      await _audioPlayer!.setSourceUrl(testUrl);
      await _audioPlayer!.resume();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playing test audio...')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }

  Future<void> _pauseAudio() async {
    try {
      await _audioPlayer!.pause();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error pausing audio: $e')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Player Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Audio Player Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Status: ${_isPlaying ? "Playing" : "Stopped"}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Position: ${_formatDuration(_position)} / ${_formatDuration(_duration)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _playTestAudio,
                  child: Text('Play Test Audio'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isPlaying ? _pauseAudio : null,
                  child: Text('Pause'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              child: LinearProgressIndicator(
                value: _duration.inMilliseconds > 0 
                    ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
                    : 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 