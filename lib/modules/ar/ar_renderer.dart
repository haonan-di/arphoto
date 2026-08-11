/// AR 渲染器 — 管理渲染层栈

import 'package:flutter/material.dart';

import 'package:arphoto/shared/types.dart';

import 'emoji_painter.dart';
import 'video_overlay.dart';

/// AR 渲染层顺序
enum ARLayer {
  camera,   // 底层：相机预览
  video,    // 中层：视频叠加
  emoji,    // 中上层：Emoji 悬浮
  hud,      // 最上层：H5 UI 半透明操作栏
}

/// AR 渲染器 — 管理各层的叠加与生命周期
class ARRenderer {
  final List<ARLayer> _activeLayers = [];

  /// 激活指定层
  void activateLayer(ARLayer layer) {
    if (!_activeLayers.contains(layer)) {
      _activeLayers.add(layer);
    }
  }

  /// 停用指定层
  void deactivateLayer(ARLayer layer) {
    _activeLayers.remove(layer);
  }

  /// 当前激活的层
  List<ARLayer> get activeLayers => List.unmodifiable(_activeLayers);

  /// 获取 Flutter Widget 层
  ///
  /// MVP 阶段：返回占位 Widget
  /// 后续实现实际的渲染 Pipeline
  Widget buildOverlay({
    required Widget cameraPreview,
    String? videoPath,
    List<EmojiConfig> emojis = const [],
    bool showHUD = true,
  }) {
    return Stack(
      children: [
        // 底层：相机预览
        if (_activeLayers.contains(ARLayer.camera))
          Positioned.fill(child: cameraPreview),

        // 中层：视频叠加
        if (_activeLayers.contains(ARLayer.video) && videoPath != null)
          Positioned.fill(
            child: VideoOverlay(videoPath: videoPath),
          ),

        // 中上层：Emoji 悬浮
        if (_activeLayers.contains(ARLayer.emoji) && emojis.isNotEmpty)
          Positioned.fill(
            child: EmojiPainter(emojis: emojis),
          ),

        // 最上层：HUD 操作栏占位
        if (_activeLayers.contains(ARLayer.hud) && showHUD)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildHUD(),
          ),
      ],
    );
  }

  Widget _buildHUD() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
        ),
      ),
      child: const Center(
        child: Text(
          'AR HUD (H5 WebView overlay)',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ),
    );
  }

  void dispose() {
    _activeLayers.clear();
  }
}