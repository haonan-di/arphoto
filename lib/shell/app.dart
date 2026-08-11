/// 壳工程 — App 启动、Module 注册、整体协调

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bridge/bridge_handler.dart';
import 'webview/webview_container.dart';
import 'router/route_mapper.dart';
import '../modules/camera/camera_module.dart';
import '../modules/camera/camera_config.dart';
import '../modules/dct/dct_module.dart';
import '../modules/ar/ar_module.dart';
import '../modules/storage/storage_module.dart';

/// 壳工程
///
/// 职责：
/// 1. 启动时注册所有原生 Module 到 Bridge
/// 2. 管理 WebView 容器生命周期
/// 3. 协调 H5 路由与原生页面
/// 4. 管理离线包
class ARPhotoShell extends StatefulWidget {
  final Widget Function()? splashBuilder;

  const ARPhotoShell({super.key, this.splashBuilder});

  @override
  State<ARPhotoShell> createState() => _ARPhotoShellState();
}

class _ARPhotoShellState extends State<ARPhotoShell> {
  late final BridgeHandler _bridge;
  late final RouteMapper _router;
  late final OfflinePackager _packager;
  late final WebViewConfig _webviewConfig;

  late final CameraModule _cameraModule;
  late final DCTModule _dctModule;
  late final ARModule _arModule;
  late final StorageModule _storageModule;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _bridge = BridgeHandler();
    _router = RouteMapper();
    _packager = OfflinePackager(
      localPath: 'assets/h5',
      remoteUrl: 'https://cdn.arphoto.app/h5',
    );
    _webviewConfig = const WebViewConfig(
      baseUrl: 'https://arphoto.app',
      entryPath: 'index.html',
      enableDebug: true,
    );

    _cameraModule = CameraModule();
    _dctModule = DCTModule();
    _arModule = ARModule();
    _storageModule = StorageModule();

    _init();
  }

  Future<void> _init() async {
    // 1. 初始化离线包
    await _packager.init();

    // 2. 初始化 StorageModule（需要基路径）
    await _storageModule.init('/app/sandbox');

    // 3. 注册所有 Module 到 Bridge
    _registerModules();

    // 4. 设置 Bridge 通信 Channel
    const channel = MethodChannel('arphoto/bridge');
    _bridge.attachChannel(channel);

    if (!mounted) return;
    setState(() => _initialized = true);
  }

  void _registerModules() {
    // CameraModule
    _bridge.registerAll(_cameraModule.registerBridgeHandlers());

    // DCTModule
    _bridge.registerAll(_dctModule.registerBridgeHandlers());

    // ARModule
    _bridge.registerAll(_arModule.registerBridgeHandlers());

    // StorageModule
    _bridge.registerAll(_storageModule.registerBridgeHandlers());
  }

  /// 获取 Bridge 实例（供外部 Module 注册）
  BridgeHandler get bridge => _bridge;

  /// 获取路由映射器
  RouteMapper get router => _router;

  /// 处理 H5 发起的原生页面跳转
  void handleRoute(String path) {
    if (!_router.requiresNative(path)) return;

    final target = _router.getNativeTarget(path);
    if (target == null) return;

    // 根据 target 唤起对应原生页面
    // 例如：target == 'camera' → 打开相机全屏页
    debugPrint('Route to native: $target');
  }

  @override
  void dispose() {
    _cameraModule.dispose();
    _dctModule.dispose();
    _arModule.dispose();
    _storageModule.dispose();
    _bridge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return widget.splashBuilder?.call() ??
          const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
    }

    return Scaffold(
      body: WebViewContainer(
        config: _webviewConfig,
        bridgeChannel: const MethodChannel('arphoto/bridge'),
      ),
    );
  }
}