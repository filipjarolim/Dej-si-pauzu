import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'app_service.dart';

/// Video service for preloading and managing AI Chat background video
class VideoService extends AppService {
  static final VideoService _instance = VideoService._();
  factory VideoService() => _instance;
  
  VideoService._();

  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPreloading = false;

  /// Get video controller (null if not initialized)
  VideoPlayerController? get controller => _controller;

  /// Check if video is initialized and ready
  bool get isReady => _isInitialized && _controller != null && _controller!.value.isInitialized;

  /// Initialize service and preload video
  @override
  Future<void> initialize() async {
    if (_isPreloading || _isInitialized) return;
    
    _isPreloading = true;
    
    try {
      debugPrint('VideoService: Preloading video...');
      
      _controller = VideoPlayerController.asset('assets/videos/sceneaichatanimated1.mp4');
      
      await _controller!.initialize();
      
      // Set video to mute
      await _controller!.setVolume(0.0);
      
      // Set video to loop
      _controller!.setLooping(true);
      
      // Pre-buffer video for smoother playback
      await _controller!.seekTo(Duration.zero);
      
      // Start playing immediately to buffer
      await _controller!.play();
      
      // Wait longer to ensure video is fully buffered
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Pause after buffering (will be played when needed)
      await _controller!.pause();
      await _controller!.seekTo(Duration.zero);
      
      _isInitialized = true;
      debugPrint('VideoService: Video preloaded successfully');
    } catch (e) {
      debugPrint('VideoService: Error preloading video: $e');
      if (_controller != null) {
        await _controller?.dispose();
        _controller = null;
      }
      _isInitialized = false;
    } finally {
      _isPreloading = false;
    }
  }

  /// Start playing video
  Future<void> play() async {
    if (!isReady) {
      debugPrint('VideoService: Video not ready, cannot play');
      return;
    }
    
    try {
      await _controller!.play();
    } catch (e) {
      debugPrint('VideoService: Error playing video: $e');
    }
  }

  /// Pause video
  Future<void> pause() async {
    if (!isReady) {
      return;
    }
    
    try {
      await _controller!.pause();
    } catch (e) {
      debugPrint('VideoService: Error pausing video: $e');
    }
  }

  /// Dispose service resources
  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _isPreloading = false;
  }
}

