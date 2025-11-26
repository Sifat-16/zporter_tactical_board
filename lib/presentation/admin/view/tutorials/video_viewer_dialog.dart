import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class VideoViewerDialog extends StatefulWidget {
  final String videoUrl;
  const VideoViewerDialog({super.key, required this.videoUrl});

  @override
  State<VideoViewerDialog> createState() => _VideoViewerDialogState();
}

class _VideoViewerDialogState extends State<VideoViewerDialog> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  bool _isYoutube = false;
  bool _isChewiePlayerReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl.contains("youtube.com") ||
        widget.videoUrl.contains("youtu.be")) {
      _isYoutube = true;
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
              autoPlay: true, mute: false, forceHD: true, enableCaption: false),
        );
      }
    } else {
      _isYoutube = false;
      final videoUri = Uri.parse(widget.videoUrl);
      _videoPlayerController = VideoPlayerController.networkUrl(videoUri);

      _videoPlayerController!.initialize().then((_) {
        if (!mounted) return;
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          looping: false,
          allowedScreenSleep: false,
          aspectRatio: _videoPlayerController!.value.aspectRatio,

          // --- CHANGE 1: CUSTOMIZE THE PROGRESS BAR COLORS HERE ---
          materialProgressColors: ChewieProgressColors(
            playedColor: ColorManager.yellow, // The main progress color
            handleColor:
                ColorManager.yellowLight, // The color of the draggable handle
            backgroundColor:
                Colors.grey.shade700, // The background of the progress bar
            bufferedColor: Colors.grey.shade500, // The color for buffered video
          ),
          placeholder: Container(
            color: Colors.black, // Background while loading
          ),
          // ----------------------------------------------------

          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(errorMessage,
                  style: const TextStyle(color: Colors.white)),
            );
          },
        );
        setState(() {
          _isChewiePlayerReady = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Center(child: _buildPlayer()),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    if (_isYoutube) {
      return _youtubeController != null
          ? YoutubePlayer(controller: _youtubeController!)
          : _buildErrorWidget("Invalid YouTube URL.");
    } else {
      if (_isChewiePlayerReady && _chewieController != null) {
        // --- CHANGE 2: WRAP CHEWIE IN A THEME TO CHANGE THE LOADING SPINNER ---
        return Theme(
          data: Theme.of(context).copyWith(
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: ColorManager.yellow,
            ),
          ),
          child: Chewie(controller: _chewieController!),
        );
        // -----------------------------------------------------------------
      }
      // The default CircularProgressIndicator will now also be yellow due to the Theme widget above,
      // but we can make it explicit here too for clarity.
      return const CircularProgressIndicator(color: ColorManager.yellow);
    }
  }

  Widget _buildErrorWidget(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
