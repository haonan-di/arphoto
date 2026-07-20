# AR 照片打印 App — 设计文档

> 日期：2026-07-17
> 状态：构思完成，待实施

## 1. 产品概述

一款手机 App，用户拍摄 Live Photo / 短视频后嵌入**暗水印**并打印成实体照片。其他人用 App 扫描打印出的照片，即可通过 AR 技术复现原始的动态效果（Live 动图循环播放），并叠加 Emoji 悬浮装饰。存储采用本地优先架构，后续可对接用户自有存储（WebDAV / 网盘 / NAS）或官方云会员服务。

## 2. 核心数据流

### 创建流程

```
Live Photo / 视频 → App 编码暗水印（嵌入静帧）→ 导出带水印图片
    ↓
用户自行打印（方式不拘：家庭打印机 / 打印店 / 在线冲印）
    ↓
打印出的实体照片（肉眼看起来是普通照片）
```

### 消费流程

```
手机扫照片 → 摄像头捕获 → 矩形检测 + 透视校正 → DCT 解码暗水印
    ↓
提取 contentId + 权限标记 + 创建者 ID
    ↓
本地数据库查 contentId ──命中──→ 加载本地缓存/原始文件
    ↓ 未命中
云存储 / 用户自有存储拉取 → 缓存到本地
    ↓
叠加 AR 效果（Live 动图循环 + Emoji 悬浮）
```

## 3. 暗水印方案

### 3.1 技术选型：频域 DCT 水印（变换域）

将信息嵌入 JPEG 压缩过程中的 DCT 中频系数，对打印—拍照链路具有良好鲁棒性。

### 3.2 水印载荷（64bit = 8 字节）

| 字段 | 位数 | 说明 |
|------|------|------|
| 权限标记 | 1 bit | 0 = 私密，1 = 公开 |
| 内容 ID | 31 bit | 唯一标识一条内容（上限 21 亿） |
| 创建者 ID | 32 bit | 标记谁创建的（上限 42 亿） |

### 3.3 编码流程

```
选帧 → 提取静帧 → DCT 变换 → 修改中频系数嵌入 bit 序列
    → IDCT 逆变换 → 输出带水印图片
```

### 3.4 解码流程

```
摄像头取帧 → 定位照片区域（矩形检测）→ 透视校正
    → DCT 变换 → 提取中频系数 → 解析 bit 序列
```

### 3.5 MVP 鲁棒性目标

- 打印后手机拍摄解码成功率 > 95%
- 支持 ±15° 旋转
- 支持 0.5×–2× 缩放
- 正常室内/日光灯/自然光下可用

### 3.6 依赖

- `image` 库（纯 Dart，MVP 阶段够用）
- 手写 Dart DCT 实现（`typed_data` 操作）

## 4. 存储架构（本地优先）

### 4.1 本地文件结构

```
App 沙盒 /
├── db/
│   └── ar_index.db          ← SQLite 数据库（drift/sqflite）
├── originals/
│   └── {contentId}.live     ← 原始 Live Photo / 视频
├── cache/
│   └── {contentId}.mp4      ← 云端拉取缓存
└── thumbnails/
    └── {contentId}.jpg      ← 缩略图
```

### 4.2 核心表结构

**Content（内容表）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | TEXT PK | 对应水印中的 contentId |
| creator_id | TEXT | 创建者身份标识 |
| title | TEXT | 用户自定义标题 |
| file_type | TEXT | `live_photo` / `video` / `gif` |
| file_path | TEXT | 本地文件路径 |
| thumbnail_path | TEXT | 缩略图路径 |
| permissions | TEXT | `private` / `whitelist` / `public` |
| whitelist | TEXT | JSON 数组，白名单用户 |
| created_at | INTEGER | 创建时间戳 |
| updated_at | INTEGER | 更新时间戳 |

**ARConfig（AR 效果配置表）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | TEXT PK | 配置唯一 ID |
| content_id | TEXT FK | 关联 Content |
| config_json | TEXT | AR 弹幕、装饰配置序列化 |
| creator_id | TEXT | 创建者 |
| version | INTEGER | 乐观锁版本号 |

### 4.3 存储抽象层（预留）

```dart
abstract class StorageProvider {
  Future<File> pullContent(String contentId);
  Future<void> pushContent(String contentId, File file);
  Future<bool> exists(String contentId);
  Future<void> delete(String contentId);
}
```

MVP 仅实现 `LocalStorageProvider`。后续可扩展 `WebDAVStorageProvider`、`S3StorageProvider`、`iCloudStorageProvider` 等。

### 4.4 消费路径

```
解码 → contentId → 查 db
  ├── ✓ 命中本地 → 读文件 → 播放
  └── ✗ 未命中 → 遍历 StorageProvider
       ├── 找到 → 下载到 cache/ → 更新 db → 播放
       └── 未找到 → 提示"未找到对应 AR 内容"
```

## 5. 权限模型

### 5.1 三种模式

| 模式 | 说明 | MVP 实现 |
|------|------|----------|
| **私密**（默认） | 仅创建者本地可扫出 AR | ✅ 纯客户端 |
| **白名单** | 指定用户可扫 | ❌ 后续迭代 |
| **公开** | 任何人可扫 | ✅ |

### 5.2 MVP 权限逻辑

- 水印权限标记位：0 = 私密，1 = 公开
- 私密：解码后检查当前用户是否匹配创建者，不匹配则提示
- 公开：解码后直接加载内容
- 全部为客户端逻辑，无需服务器

## 6. AR 效果方案

### 6.1 MVP 范围

| 效果 | MVP | 实现方式 |
|------|-----|----------|
| Live Photo 动图还原 | ✅ 核心 | 视频叠加至相机预览层 |
| Emoji 悬浮（固定位置） | ✅ 基础 | CustomPainter 绘制 |
| Emoji 弹幕 / 自定义位置 | ❌ | 后续 |
| 艺术滤镜 | ❌ | 后续 |
| 多人共享 AR 配置 | ❌ | 后续 |

### 6.2 技术实现

```
┌─────────────────────────┐
│   Camera Preview (底层)   │ ← 实时显示摄像头画面
│     显示打印照片           │
├─────────────────────────┤
│   AR Overlay (上层)       │ ← Flutter 层叠加
│     • Live Photo 循环      │
│     • Emoji 悬浮           │
│     • 水印解码指示器       │
└─────────────────────────┘
```

### 6.3 Flutter 技术选型

| 能力 | 插件 |
|------|------|
| 相机 | `camera`（官方） |
| 水印解码 | `image` + 自写 DCT（isolate 线程） |
| AR 叠加 | `CustomPainter` + 帧动画 |
| 视频播放 | `video_player` |

### 6.4 解码性能目标

- 取帧→解码 contentId：< 500ms
- 解码→AR 展示：< 200ms
- 总耗时 < 1 秒

## 7. 技术栈总结

| 层级 | 选型 |
|------|------|
| 框架 | Flutter（Dart） |
| 跨平台 | iOS / Android |
| 本地数据库 | drift（sqflite） |
| 水印算法 | 自研 DCT 频域水印 |
| 相机 | `camera` 插件 |
| AR 叠加 | Flutter CustomPainter |
| 视频播放 | `video_player` |
| 图像处理 | `image` 库 |
| 存储抽象 | 接口化设计，预留多 Provider |

## 8. MVP 里程碑

| 阶段 | 内容 | 估时 |
|------|------|------|
| 1 | 项目脚手架 + 相机预览 + 拍照功能 | 1 周 |
| 2 | 暗水印编解码核心算法（DCT） | 2 周 |
| 3 | 存储层（SQLite + 本地文件管理） | 1 周 |
| 4 | AR 叠加播放（Live Photo + Emoji） | 1 周 |
| 5 | 扫描→解码→AR 效果闭环集成 | 1 周 |
| 6 | UI 打磨 + 测试 + 发布准备 | 1 周 |
| 合计 | | **7 周** |

## 9. 后续迭代方向

- 白名单共享权限
- 用户自有存储对接（WebDAV / S3 / NAS）
- 官方云会员服务
- Emoji 弹幕编辑器（自定义位置、动画轨迹）
- 艺术滤镜 / AI 特效
- 实体产品（动态光栅卡、AR 相框、打印机联名）
