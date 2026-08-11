/// WebView 容器管理

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// WebView 容器状态
enum WebViewState {
  loading,
  loaded,
  error,
}

/// WebView 容器配置
class WebViewConfig {
  final String baseUrl;
  final String entryPath;
  final bool enableDebug;
  final bool enableJavaScript;

  const WebViewConfig({
    this.baseUrl = '',
    this.entryPath = 'index.html',
    this.enableDebug = false,
    this.enableJavaScript = true,
  });
}

/// WebView 容器 — 承载 H5 UI 层
///
/// MVP 阶段使用 Flutter 内置 WebView 占位
/// 后续集成 flutter_inappwebview 或各平台原生 WebView
class WebViewContainer extends StatefulWidget {
  final WebViewConfig config;
  final MethodChannel? bridgeChannel;
  final void Function(WebViewState state)? onStateChange;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const WebViewContainer({
    super.key,
    required this.config,
    this.bridgeChannel,
    this.onStateChange,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  WebViewState _state = WebViewState.loading;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _state = WebViewState.loading);
    widget.onStateChange?.call(WebViewState.loading);

    try {
      // MVP 阶段：加载本地 H5 包
      // 后续集成 flutter_inappwebview 后替换为真实 WebView
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      setState(() => _state = WebViewState.loaded);
      widget.onStateChange?.call(WebViewState.loaded);
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = WebViewState.error);
      widget.onStateChange?.call(WebViewState.error);
    }
  }

  Future<void> reload() async {
    await _loadContent();
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case WebViewState.loading:
        return widget.loadingWidget ??
            const Center(child: CircularProgressIndicator());
      case WebViewState.error:
        return widget.errorWidget ??
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Failed to load UI'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
      case WebViewState.loaded:
        // MVP 占位：显示 H5 加载成功
        // 替换为真实 WebView Widget
        return const Center(
          child: Text(
            'H5 UI Container (WebView)',
            style: TextStyle(color: Colors.grey),
          ),
        );
    }
  }
}

/// 离线包管理器
class OfflinePackager {
  final String localPath;
  final String remoteUrl;
  String? _version;

  OfflinePackager({
    required this.localPath,
    required this.remoteUrl,
  });

  /// 当前离线包版本
  String? get version => _version;

  /// 初始化：检查本地包，可选更新
  Future<void> init() async {
    // MVP 阶段：使用本地内置包
    _version = '1.0.0';
  }

  /// 检查 CDN 更新
  Future<String?> checkUpdate() async {
    // MVP 阶段：返回 null
    return null;
  }

  /// 下载并替换离线包
  Future<void> downloadAndReplace(String version) async {
    // MVP 阶段：空实现
    _version = version;
  }

  /// 获取入口文件路径
  String getEntryPath() {
    return '$localPath/index.html';
  }
}