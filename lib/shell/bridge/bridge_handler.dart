/// JS Bridge — H5 ↔ 原生通信桥接

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../../shared/errors.dart';
import '../../shared/types.dart';

/// Bridge 请求（来自 H5）
class BridgeRequest {
  final String action;
  final String requestId;
  final Map<String, dynamic> params;

  const BridgeRequest({
    required this.action,
    required this.requestId,
    required this.params,
  });

  factory BridgeRequest.fromJson(Map<String, dynamic> json) => BridgeRequest(
        action: json['action'] as String,
        requestId: json['requestId'] as String,
        params: (json['params'] as Map<String, dynamic>?) ?? {},
      );
}

/// Bridge 响应（发回 H5）
class BridgeResponse {
  final String requestId;
  final int code;
  final dynamic data;
  final String? error;

  const BridgeResponse({
    required this.requestId,
    this.code = 0,
    this.data,
    this.error,
  });

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'code': code,
        if (data != null) 'data': data,
        if (error != null) 'error': error,
      };
}

/// Bridge 主动事件（原生 → H5）
class BridgeEvent {
  final String type;
  final dynamic data;

  const BridgeEvent({required this.type, required this.data});

  Map<String, dynamic> toJson() => {'type': type, 'data': data};
}

/// 模块处理函数签名
typedef ModuleHandler = Future<dynamic> Function(Map<String, dynamic> params);

/// JS Bridge 核心
class BridgeHandler {
  final Map<String, ModuleHandler> _handlers = {};
  final _pendingRequests = <String, Completer<BridgeResponse>>{};
  MethodChannel? _channel;

  /// 注册模块处理方法
  void register(String action, ModuleHandler handler) {
    _handlers[action] = handler;
  }

  /// 批量注册
  void registerAll(Map<String, ModuleHandler> handlers) {
    _handlers.addAll(handlers);
  }

  /// 设置 MethodChannel（与 WebView 通信）
  void attachChannel(MethodChannel channel) {
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
  }

  /// 处理来自 H5 的请求
  Future<BridgeResponse> handleRequest(BridgeRequest request) async {
    final handler = _handlers[request.action];
    if (handler == null) {
      return BridgeResponse(
        requestId: request.requestId,
        code: 5001,
        error: 'Unknown action: ${request.action}',
      );
    }

    try {
      final result = await handler(request.params);
      return BridgeResponse(
        requestId: request.requestId,
        data: result,
      );
    } on ModuleException catch (e) {
      return BridgeResponse(
        requestId: request.requestId,
        code: e.code,
        error: e.message,
      );
    } catch (e) {
      return BridgeResponse(
        requestId: request.requestId,
        code: 9999,
        error: e.toString(),
      );
    }
  }

  /// 主动推送事件到 H5
  Future<void> emitEvent(BridgeEvent event) async {
    try {
      await _channel?.invokeMethod('emitEvent', jsonEncode(event.toJson()));
    } catch (_) {
      // WebView 未就绪时静默失败
    }
  }

  /// 从 MethodChannel 接收调用
  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method != 'handleRequest') return null;

    final request = BridgeRequest.fromJson(
      jsonDecode(call.arguments as String) as Map<String, dynamic>,
    );
    final response = await handleRequest(request);
    return jsonEncode(response.toJson());
  }

  /// 发送请求并等待响应（壳工程内部使用）
  Future<BridgeResponse> sendRequest(BridgeRequest request) async {
    final completer = Completer<BridgeResponse>();
    _pendingRequests[request.requestId] = completer;

    try {
      await _channel?.invokeMethod(
        'sendRequest',
        jsonEncode({
          'action': request.action,
          'requestId': request.requestId,
          'params': request.params,
        }),
      );
      return await completer.future.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw BridgeException.timeout;
    } finally {
      _pendingRequests.remove(request.requestId);
    }
  }

  /// 处理来自 H5 的响应
  void handleResponse(BridgeResponse response) {
    final completer = _pendingRequests.remove(response.requestId);
    completer?.complete(response);
  }

  void dispose() {
    _handlers.clear();
    _pendingRequests.clear();
    _channel?.setMethodCallHandler(null);
    _channel = null;
  }
}