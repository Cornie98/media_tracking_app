import 'package:audioplayers/audioplayers.dart';

class MusicPlayerService {
  static AudioPlayer? _audioPlayer;
  static bool _isPlaying = false;
  static String? _currentUrl;
  static Duration _position = Duration.zero;
  static Duration _duration = Duration.zero;
  static bool _isInitialized = false;

  // Getter for current state
  static bool get isPlaying => _isPlaying;
  static Duration get position => _position;
  static Duration get duration => _duration;
  static String? get currentUrl => _currentUrl;

  // Initialize the player
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    _audioPlayer = AudioPlayer();
    
    // Listen to position changes
    _audioPlayer!.onPositionChanged.listen((Duration position) {
      _position = position;
    });

    // Listen to duration changes
    _audioPlayer!.onDurationChanged.listen((Duration duration) {
      _duration = duration;
    });

    // Listen to player state changes
    _audioPlayer!.onPlayerStateChanged.listen((PlayerState state) {
      _isPlaying = state == PlayerState.playing;
    });
    
    _isInitialized = true;
  }

  // Play audio from URL
  static Future<void> play(String url) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      if (_currentUrl != url) {
        // Stop current playback if different URL
        await stop();
        _currentUrl = url;
        await _audioPlayer!.setSourceUrl(url);
      }
      
      await _audioPlayer!.resume();
      _isPlaying = true;
    } catch (e) {
      print('Error playing audio: $e');
      _isPlaying = false;
    }
  }

  // Pause audio
  static Future<void> pause() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.pause();
        _isPlaying = false;
      }
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  // Stop audio
  static Future<void> stop() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        _isPlaying = false;
        _position = Duration.zero;
        _currentUrl = null;
      }
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  // Seek to position
  static Future<void> seek(Duration position) async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.seek(position);
      }
    } catch (e) {
      print('Error seeking audio: $e');
    }
  }

  // Dispose resources
  static Future<void> dispose() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.dispose();
        _audioPlayer = null;
        _isInitialized = false;
        _isPlaying = false;
        _position = Duration.zero;
        _duration = Duration.zero;
        _currentUrl = null;
      }
    } catch (e) {
      print('Error disposing audio player: $e');
    }
  }
} 