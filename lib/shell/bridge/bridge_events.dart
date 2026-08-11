/// Bridge 事件的类型常量

class BridgeEventTypes {
  BridgeEventTypes._();

  /// 相机帧回调（缩略图，非像素数据）
  static const String frame = 'frame';

  /// 解码结果
  static const String decodeResult = 'decodeResult';

  /// AR 状态变更
  static const String arStateChange = 'arStateChange';

  /// 相机状态变更
  static const String cameraState = 'cameraState';

  /// 存储操作完成
  static const String storageComplete = 'storageComplete';

  /// 错误通知
  static const String error = 'error';
}