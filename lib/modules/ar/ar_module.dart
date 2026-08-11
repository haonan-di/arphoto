/// ARModule — AR 叠加渲染

import 'dart:async';

import 'package:arphoto/shared/errors.dart';
import 'package:arphoto/shared/types.dart';

/// AR 模块接口
abstract class IARModule {
  /// 当前 AR 状态
  ARState get state;

  /// 启动 AR 叠加
  Future<void> startAR(ARConfig config);

  /// 更新 Emoji 位置/动画
  void updateEmoji(List<EmojiConfig> emojis);

  /// 停止 AR
  Future<void> stopAR();

  /// 暂停
  void pause();

  /// 恢复
  void resume();
}

/// AR 状态
enum ARState {
  idle,
  loading,
  playing,
  paused,
  error,
}

/// AR 模块实现
class ARModule implements IARModule {
  ARState _state = ARState.idle;
  ARConfig? _currentConfig;
  StreamSubscription? _videoSubscription;

  @override
  ARState get state => _state;

  @override
  Future<void> startAR(ARConfig config) async {
    _state = ARState.loading;
    _currentConfig = config;

    try {
      // MVP 阶段：模拟加载视频
      await Future.delayed(const Duration(milliseconds: 300));
      _state = ARState.playing;
    } catch (e) {
      _state = ARState.error;
      throw ARException(
        code: 4002,
        message: 'Failed to start AR: $e',
      );
    }
  }

  @override
  void updateEmoji(List<EmojiConfig> emojis) {
    if (_currentConfig == null) return;
    _currentConfig = ARConfig(
      contentId: _currentConfig!.contentId,
      videoPath: _currentConfig!.videoPath,
      emojis: emojis,
      autoPlay: _currentConfig!.autoPlay,
    );
  }

  @override
  Future<void> stopAR() async {
    await _videoSubscription?.cancel();
    _videoSubscription = null;
    _currentConfig = null;
    _state = ARState.idle;
  }

  @override
  void pause() {
    if (_state == ARState.playing) {
      _state = ARState.paused;
    }
  }

  @override
  void resume() {
    if (_state == ARState.paused) {
      _state = ARState.playing;
    }
  }

  /// 获取当前配置
  ARConfig? get currentConfig => _currentConfig;

  /// 注册 Bridge 处理器
  Map<String, dynamic> registerBridgeHandlers() {
    return {
      'ar.start': (params) async {
        final config = ARConfig(
          contentId: params['contentId'] as String,
          videoPath: params['videoPath'] as String,
          emojis: _parseEmojis(params['emojis']),
          autoPlay: params['autoPlay'] as bool? ?? true,
        );
        await startAR(config);
        return {'state': _state.name};
      },
      'ar.stop': (params) async {
        await stopAR();
        return {'state': _state.name};
      },
      'ar.pause': (params) {
        pause();
        return {'state': _state.name};
      },
      'ar.resume': (params) {
        resume();
        return {'state': _state.name};
      },
      'ar.updateEmoji': (params) {
        final emojis = _parseEmojis(params['emojis']);
        updateEmoji(emojis);
        return {'state': _state.name};
      },
      'ar.status': (params) {
        return {
          'state': _state.name,
          'hasVideo': _currentConfig != null,
          'emojiCount': _currentConfig?.emojis.length ?? 0,
        };
      },
    };
  }

  List<EmojiConfig> _parseEmojis(dynamic emojisJson) {
    if (emojisJson == null) return [];
    final list = emojisJson as List;
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return EmojiConfig(
        emoji: m['emoji'] as String? ?? '😀',
        x: (m['x'] as num?)?.toDouble() ?? 0.0,
        y: (m['y'] as num?)?.toDouble() ?? 0.0,
        scale: (m['scale'] as num?)?.toDouble() ?? 1.0,
        rotation: (m['rotation'] as num?)?.toDouble() ?? 0.0,
        opacity: (m['opacity'] as num?)?.toDouble() ?? 1.0,
      );
    }).toList();
  }

  void dispose() {
    _videoSubscription?.cancel();
    _currentConfig = null;
    _state = ARState.idle;
  }
}