/// 数据库助手 — SQLite 操作

import 'dart:async';

import 'package:arphoto/shared/errors.dart';

import 'models/content.dart';

/// 数据库回调
class DatabaseHelper {
  static const String _dbName = 'ar_index.db';
  static const int _dbVersion = 1;

  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// 初始化数据库
  Future<void> init() async {
    if (_initialized) return;

    try {
      // MVP 阶段：模拟数据库初始化
      // 后续集成 sqflite 或 drift
      // final db = await openDatabase(await getDbPath(), version: _dbVersion);
      // await _createTables(db);
      await Future.delayed(const Duration(milliseconds: 50));
      _initialized = true;
    } catch (e) {
      throw StorageException(
        code: 3002,
        message: 'Database init failed: $e',
      );
    }
  }

  /// 创建表结构
  Future<void> _createTables(dynamic db) async {
    // MVP 阶段：后续集成真实数据库
    // await db.execute('''
    //   CREATE TABLE IF NOT EXISTS content (
    //     id TEXT PRIMARY KEY,
    //     creator_id TEXT NOT NULL,
    //     title TEXT DEFAULT '',
    //     file_type TEXT DEFAULT 'live_photo',
    //     file_path TEXT,
    //     thumbnail_path TEXT,
    //     permissions TEXT DEFAULT 'private',
    //     whitelist TEXT,
    //     created_at INTEGER NOT NULL,
    //     updated_at INTEGER NOT NULL
    //   )
    // ''');
    // await db.execute('''
    //   CREATE TABLE IF NOT EXISTS ar_config (
    //     id TEXT PRIMARY KEY,
    //     content_id TEXT NOT NULL,
    //     config_json TEXT DEFAULT '{}',
    //     creator_id TEXT NOT NULL,
    //     version INTEGER DEFAULT 1,
    //     FOREIGN KEY (content_id) REFERENCES content(id)
    //   )
    // ''');
    // await db.execute('''
    //   CREATE INDEX IF NOT EXISTS idx_content_creator ON content(creator_id)
    // ''');
    // await db.execute('''
    //   CREATE INDEX IF NOT EXISTS idx_ar_config_content ON ar_config(content_id)
    // ''');
  }

  /// 插入内容
  Future<void> insertContent(ContentModel content) async {
    _requireInit();
    // MVP 阶段：模拟插入
    await Future.delayed(const Duration(milliseconds: 10));
  }

  /// 查询内容
  Future<ContentModel?> getContent(String id) async {
    _requireInit();
    // MVP 阶段：返回 null
    await Future.delayed(const Duration(milliseconds: 10));
    return null;
  }

  /// 查询所有内容
  Future<List<ContentModel>> listContents({
    int page = 0,
    int pageSize = 20,
  }) async {
    _requireInit();
    // MVP 阶段：返回空列表
    await Future.delayed(const Duration(milliseconds: 10));
    return [];
  }

  /// 删除内容
  Future<void> deleteContent(String id) async {
    _requireInit();
    // MVP 阶段：模拟删除
    await Future.delayed(const Duration(milliseconds: 10));
  }

  /// 更新内容
  Future<void> updateContent(ContentModel content) async {
    _requireInit();
    // MVP 阶段：模拟更新
    await Future.delayed(const Duration(milliseconds: 10));
  }

  /// 插入 AR 配置
  Future<void> insertARConfig(ARConfigModel config) async {
    _requireInit();
    // MVP 阶段：模拟插入
    await Future.delayed(const Duration(milliseconds: 10));
  }

  /// 查询 AR 配置
  Future<ARConfigModel?> getARConfig(String contentId) async {
    _requireInit();
    // MVP 阶段：返回 null
    await Future.delayed(const Duration(milliseconds: 10));
    return null;
  }

  /// 获取数据库路径
  Future<String> getDbPath() async {
    // 后续使用 path_provider 获取应用沙盒路径
    // final dir = await getApplicationDocumentsDirectory();
    // return '${dir.path}/$_dbName';
    return '/app/sandbox/db/ar_index.db';
  }

  void _requireInit() {
    if (!_initialized) {
      throw StorageException(
        code: 3002,
        message: 'Database not initialized',
      );
    }
  }

  /// 关闭数据库
  Future<void> close() async {
    _initialized = false;
  }
}