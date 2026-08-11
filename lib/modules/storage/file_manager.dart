/// 文件管理器 — 本地文件系统操作

import 'dart:async';
import 'dart:typed_data';

import 'package:arphoto/shared/errors.dart';

/// 文件管理器
class FileManager {
  static const String _originalsDir = 'originals';
  static const String _cacheDir = 'cache';
  static const String _thumbnailsDir = 'thumbnails';

  String? _basePath;

  /// 初始化文件管理器
  Future<void> init(String basePath) async {
    _basePath = basePath;
    // MVP 阶段：模拟目录创建
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// 保存原始文件
  Future<String> saveOriginal(String contentId, List<int> bytes) async {
    _requireInit();
    final path = '$_basePath/$_originalsDir/$contentId';
    // MVP 阶段：模拟文件保存
    await Future.delayed(const Duration(milliseconds: 50));
    return path;
  }

  /// 读取原始文件
  Future<Uint8List> readOriginal(String contentId) async {
    _requireInit();
    // MVP 阶段：返回空数据
    await Future.delayed(const Duration(milliseconds: 50));
    return Uint8List(0);
  }

  /// 保存缓存文件
  Future<String> saveCache(String contentId, List<int> bytes) async {
    _requireInit();
    final path = '$_basePath/$_cacheDir/$contentId.mp4';
    // MVP 阶段：模拟文件保存
    await Future.delayed(const Duration(milliseconds: 50));
    return path;
  }

  /// 读取缓存文件
  Future<Uint8List> readCache(String contentId) async {
    _requireInit();
    // MVP 阶段：返回空数据
    await Future.delayed(const Duration(milliseconds: 50));
    return Uint8List(0);
  }

  /// 保存缩略图
  Future<String> saveThumbnail(String contentId, List<int> bytes) async {
    _requireInit();
    final path = '$_basePath/$_thumbnailsDir/$contentId.jpg';
    // MVP 阶段：模拟文件保存
    await Future.delayed(const Duration(milliseconds: 50));
    return path;
  }

  /// 读取缩略图
  Future<Uint8List> readThumbnail(String contentId) async {
    _requireInit();
    // MVP 阶段：返回空数据
    await Future.delayed(const Duration(milliseconds: 50));
    return Uint8List(0);
  }

  /// 删除文件
  Future<void> delete(String path) async {
    _requireInit();
    // MVP 阶段：模拟删除
    await Future.delayed(const Duration(milliseconds: 30));
  }

  /// 检查文件是否存在
  Future<bool> exists(String path) async {
    _requireInit();
    // MVP 阶段：返回 false
    return false;
  }

  /// 获取原始文件路径
  String getOriginalPath(String contentId) {
    return '$_basePath/$_originalsDir/$contentId';
  }

  /// 获取缓存路径
  String getCachePath(String contentId) {
    return '$_basePath/$_cacheDir/$contentId.mp4';
  }

  /// 获取缩略图路径
  String getThumbnailPath(String contentId) {
    return '$_basePath/$_thumbnailsDir/$contentId.jpg';
  }

  void _requireInit() {
    if (_basePath == null) {
      throw StorageException(
        code: 3002,
        message: 'FileManager not initialized',
      );
    }
  }
}