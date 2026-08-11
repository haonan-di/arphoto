/// 视频叠加层 — 播放 Live Photo / 视频覆盖在相机预览上

import 'package:flutter/material.dart';

/// 视频叠加 Widget
///
/// MVP 阶段：占位实现
/// 后续集成 video_player 进行实际视频播放
class VideoOverlay extends StatefulWidget {
  final String videoPath;
  final bool loop;
  final double opacity;

  const VideoOverlay({
    super.key,
    required this.videoPath,
    this.loop = true,
    this.opacity = 0.8,
  });

  @override
  State<VideoOverlay> createState() => _VideoOverlayState();
}

class _VideoOverlayState extends State<VideoOverlay> {
  @override
  Widget build(BuildContext context) {
    // MVP 阶段：显示视频路径占位
    // 后续替换为 VideoPlayer 组件
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 48,
              color: Colors.white54,
            ),
            const SizedBox(height: 8),
            Text(
              'Video: ${widget.videoPath}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}