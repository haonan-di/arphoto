# AR 照片打印 App — 设计文档

> 日期：2026-07-17
> 更新：2026-08-11 — 重构为"壳工程 + H5 UI + 原生组件"三层架构
> 状态：构思完成，待实施

## 1. 产品概述

一款手机 App，用户拍摄 Live Photo / 短视频后嵌入**暗水印**并打印成实体照片。其他人用 App 扫描打印出的照片，即可通过 AR 技术复现原始的动态效果（Live 动图循环播放），并叠加 Emoji 悬浮装饰。存储采用本地优先架构，后续可对接用户自有存储（WebDAV / 网盘 / NAS）或官方云会员服务。

## 2. 架构总览（三层）

```
┌──────────────────────────────────────────────────────┐
│                   小程序 / 快应用                       │
│         (复用 H5 UI 层，桥接各平台原生能力)              │
└───────────────────────┬──────────────────────────────┘
                        │ 同一套 H5 代码
┌───────────────────────▼──────────────────────────────┐
│                     H5 UI 层                           │
│  React / Vue 单页应用，打包进壳工程 WebView             │
│                                                        │
│  • 首页 / 内容管理 / 画廊                               │
│  • 设置页 / 权限配置 / 引导页                           │
│  • 扫描结果展示 / AR 效果控制界面                       │
│  • 水印内容创建向导（拍摄→预览→导出）                   │
│                                                        │
│  更新方式：热更新（无需应用商店审核）                     │
│  复用策略：同一套代码直接移植到微信小程序                 │
└──────────────┬────────────────────┬───────────────────┘
               │ JS Bridge           │
               │ (flutter_inappwebview / 各平台 WebView 桥接)
┌──────────────▼────────────────────▼───────────────────┐
│                 壳工程（Shell App）                      │
│  Flutter 作为宿主框架，负责：                            │
│  • WebView 容器管理                                     │
│  • 原生组件注册与生命周期管理                             │
│  • 路由协调（H5 URL → 原生组件唤起）                     │
│  • 离线包管理（H5 资源预加载 / 降级）                    │
├────────────────────────────────────────────────────────┤
│  原生能力组件层（Native Capability Modules）              │
│  各 Module 独立维护、独立版本号、独立单元测试              │
│                                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  CameraModule │  │   DCTModule  │  │   ARModule   │  │
│  │  相机帧引擎   │  │ 水印编解码   │  │ AR 叠加渲染   │  │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤  │
│  │  • 帧流捕获   │  │  • DCT 变换  │  │  • 视频叠加   │  │
│  │  • 矩形检测   │  │  • 编码bit   │  │  • Emoji 悬浮 │  │
│  │  • 透视校正   │  │  • 解码bit   │  │  • 效果同步   │  │
│  │  • 取帧回调   │  │  • 鲁棒性    │  │  • 动图循环   │  │
│  │               │  │    增强      │  │               │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                        │
│  ┌──────────────┐  ┌──────────────┐                    │
│  │ StorageModule │  │  UtilsModule │                    │
│  │  存储抽象层   │  │  工具库      │                    │
│  ├──────────────┤  ├──────────────┤                    │
│  │  • SQLite     │  │  • 图像处理  │                    │
│  │  • 文件管理   │  │  • 编码转换  │                    │
│  │  • 缓存策略   │  │  • 设备能力  │                    │
│  │  • 云存储     │  │    检测      │                    │
│  │    接口预留   │  │              │                    │
│  └──────────────┘  └──────────────┘                    │
└────────────────────────────────────────────────────────┘
```

### 2.1 组件化原则

- **每个 Module 独立维护**，有独立的版本号、README、单元测试
- **Module 之间不直接依赖**，通过壳工程注入依赖或事件总线通信
- **Module 可独立替换实现**（如 Flutter 版 → 原生 Kotlin/Swift 版），接口不变
- **H5 UI 不直接调 Module**，统一通过 JS Bridge 走壳工程路由

### 2.2 更新策略

| 层 | 实现方式 | 更新途径 | 迭代频率 |
|---|---|---|---|
| H5 UI 层 | WebView 加载 H5 包 | 热更新（CDN 下发） | 高频（按需） |
| 壳工程 | Flutter | App Store 审核 | 低频（框架升级） |
| 原生组件 | Flutter Plugin / 原生 SDK | App Store 审核 | 极低频（算法稳定后几乎不改） |

### 2.3 小程序复用策略

- H5 UI 层代码（React/Vue）**直接移植**到微信小程序
- 小程序端各平台原生能力通过**小程序原生 API** 桥接，不依赖壳工程
- 同一套 UI 代码 + 不同平台桥接层 = 多端覆盖

## 3. 核心数据流

### 3.1 创建流程（H5 驱动，原生执行）

```
┌───── H5 UI ─────┐     ┌── 原生组件 ──┐
│ 点击"拍摄"       │ ──→ │ CameraModule  │
│ 显示取景器       │ ←── │ 启动预览      │
│ 点击"拍摄"       │ ──→ │ CameraModule  │
│                  │     │ 捕获帧        │
│ 显示"正在嵌入    │ ──→ │ DCTModule     │
│ 水印..."         │     │ 编码水印      │
│ 显示预览+导出   │ ←── │ 返回带水印图片│
│ 点击"导出打印"  │ ──→ │ StorageModule  │
│                  │     │ 保存内容      │
│ 完成提示        │ ←── │ 返回 contentId│
└─────────────────┘     └───────────────┘

用户自行打印（方式不拘：家庭打印机 / 打印店 / 在线冲印）
    ↓
打印出的实体照片（肉眼看起来是普通照片）
```

### 3.2 消费流程（H5 驱动，原生执行）

```
┌───── H5 UI ─────┐     ┌── 原生组件 ──┐
│ 点击"扫一扫"     │ ──→ │ CameraModule  │
│ 显示取景器       │ ←── │ 启动预览+帧流 │
│                  │     │ 矩形检测(逐帧)│
│                  │     │ 透视校正      │
│ 显示"解码中..." │ ──→ │ DCTModule     │
│                  │     │ 解码 contentId│
│                  │ ──→ │ StorageModule │
│                  │     │ 查本地数据库  │
│                  │ ←── │ 返回内容路径  │
│ 显示 AR 结果    │ ──→ │ ARModule      │
│                  │     │ 启动 AR 叠加  │
│ 用户交互控制    │ ←── │ 状态回调      │
└─────────────────┘     └───────────────┘
```

## 4. 模块接口定义

### 4.1 CameraModule

```dart
// 提供给壳工程 + JS Bridge 的接口
abstract class CameraModule {
  /// 启动相机预览（返回帧流给 DCT 或 H5 预览）
  Future<void> startPreview(CameraConfig config);

  /// 停止相机
  Future<void> stopPreview();

  /// 单帧拍照（返回图片路径）
  Future<String> capturePhoto();

  /// 注册帧回调（用于 DCT 实时解码）
  void onFrame(FrameCallback callback);

  /// 矩形检测（在当前帧中定位照片区域）
  Rect? detectPhotoRegion(Frame frame);
}
```

### 4.2 DCTModule

```dart
abstract class DCTModule {
  /// 编码：传入静帧图片路径 + 元数据，返回带水印图片路径
  Future<String> encode({
    required String imagePath,
    required int contentId,
    required int creatorId,
    required bool isPublic,
  });

  /// 解码：传入帧像素数据，返回水印载荷（null 表示未检测到）
  Future<WatermarkPayload?> decode(Frame frame);

  /// 解码（图片文件模式）
  Future<WatermarkPayload?> decodeFromImage(String imagePath);
}
```

### 4.3 ARModule

```dart
abstract class ARModule {
  /// 启动 AR 叠加：传入视频路径 + emoji 配置
  Future<void> startAR(ARConfig config);

  /// 更新 Emoji 位置/动画
  void updateEmoji(List<EmojiConfig> emojis);

  /// 停止 AR
  Future<void> stopAR();

  /// 暂停/恢复
  void pause();
  void resume();
}
```

### 4.4 StorageModule

```dart
abstract class StorageModule {
  /// 保存内容
  Future<String> saveContent(ContentSaveRequest request);

  /// 查询内容
  Future<Content?> getContent(String contentId);

  /// 获取所有内容列表
  Future<List<Content>> listContents({int page, int pageSize});

  /// 删除内容
  Future<void> deleteContent(String contentId);

  /// 存储抽象层（预留多 Provider）
  Future<void> registerProvider(StorageProvider provider);
}

abstract class StorageProvider {
  Future<File> pullContent(String contentId);
  Future<void> pushContent(String contentId, File file);
  Future<bool> exists(String contentId);
  Future<void> delete(String contentId);
}
```

### 4.5 JS Bridge 协议

H5 ↔ 壳工程通过 URL Scheme + 回调来通信：

```typescript
// H5 调用原生能力
interface BridgeRequest {
  action: string;      // 'camera.startPreview' | 'dct.decode' | 'ar.start' | ...
  requestId: string;   // 唯一标识，用于匹配回调
  params: Record<string, unknown>;
}

// 原生回调 H5
interface BridgeResponse {
  requestId: string;
  code: number;        // 0 = 成功，非0 = 错误码
  data?: unknown;
  error?: string;
}

// H5 监听原生主动事件
type BridgeEvent =
  | { type: 'frame'; data: FrameInfo }
  | { type: 'decodeResult'; data: WatermarkPayload }
  | { type: 'arStateChange'; data: ARState };
```

## 5. 暗水印方案

### 5.1 技术选型：频域 DCT 水印（变换域）

将信息嵌入 JPEG 压缩过程中的 DCT 中频系数，对打印—拍照链路具有良好鲁棒性。

### 5.2 水印载荷（64bit = 8 字节）

| 字段 | 位数 | 说明 |
|------|------|------|
| 权限标记 | 1 bit | 0 = 私密，1 = 公开 |
| 内容 ID | 31 bit | 唯一标识一条内容（上限 21 亿） |
| 创建者 ID | 32 bit | 标记谁创建的（上限 42 亿） |

### 5.3 编码流程

```
选帧 → 提取静帧 → DCT 变换 → 修改中频系数嵌入 bit 序列
    → IDCT 逆变换 → 输出带水印图片
```

### 5.4 解码流程

```
摄像头取帧 → 定位照片区域（矩形检测）→ 透视校正
    → DCT 变换 → 提取中频系数 → 解析 bit 序列
```

### 5.5 MVP 鲁棒性目标

- 打印后手机拍摄解码成功率 > 95%
- 支持 ±15° 旋转
- 支持 0.5×–2× 缩放
- 正常室内/日光灯/自然光下可用

### 5.6 依赖

- `image` 库（纯 Dart，MVP 阶段够用）
- 手写 Dart DCT 实现（`typed_data` 操作）

## 6. 壳工程（Shell App）职责

| 职责 | 说明 |
|------|------|
| WebView 容器 | 承载 H5 UI 层，管理加载/缓存/降级 |
| JS Bridge 注册 | 注入 Bridge 对象，转发 H5 请求到对应 Module |
| 模块生命周期 | 按需加载/卸载原生 Module，管理内存 |
| 离线包管理 | 预加载 H5 资源包到本地，弱网时降级使用 |
| 路由协调 | H5 路由与原生页面路由的映射（如扫码页直接唤起相机） |
| 权限管理 | 统一处理相机/存储/相册权限申请 |

### 6.1 离线包策略

- H5 资源打包为 `.zip`，随 App 版本内置
- 启动时检查 CDN 是否有新版本，有则后台下载替换
- 无网络时使用本地内置包，功能不受影响
- 包体大小目标：< 2MB（首屏可交互 < 1s）

## 7. 存储架构（本地优先）

### 7.1 本地文件结构

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

### 7.2 核心表结构

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

### 7.3 存储抽象层（预留）

```dart
abstract class StorageProvider {
  Future<File> pullContent(String contentId);
  Future<void> pushContent(String contentId, File file);
  Future<bool> exists(String contentId);
  Future<void> delete(String contentId);
}
```

MVP 仅实现 `LocalStorageProvider`。后续可扩展 `WebDAVStorageProvider`、`S3StorageProvider`、`iCloudStorageProvider` 等。

### 7.4 消费路径

```
解码 → contentId → 查 db
  ├── ✓ 命中本地 → 读文件 → 播放
  └── ✗ 未命中 → 遍历 StorageProvider
       ├── 找到 → 下载到 cache/ → 更新 db → 播放
       └── 未找到 → 提示"未找到对应 AR 内容"
```

## 8. 权限模型

### 8.1 三种模式

| 模式 | 说明 | MVP 实现 |
|------|------|----------|
| **私密**（默认） | 仅创建者本地可扫出 AR | ✅ 纯客户端 |
| **白名单** | 指定用户可扫 | ❌ 后续迭代 |
| **公开** | 任何人可扫 | ✅ |

### 8.2 MVP 权限逻辑

- 水印权限标记位：0 = 私密，1 = 公开
- 私密：解码后检查当前用户是否匹配创建者，不匹配则提示
- 公开：解码后直接加载内容
- 全部为客户端逻辑，无需服务器

## 9. AR 效果方案

### 9.1 MVP 范围

| 效果 | MVP | 实现方式 |
|------|-----|----------|
| Live Photo 动图还原 | ✅ 核心 | 视频叠加至相机预览层 |
| Emoji 悬浮（固定位置） | ✅ 基础 | CustomPainter 绘制 |
| Emoji 弹幕 / 自定义位置 | ❌ | 后续 |
| 艺术滤镜 | ❌ | 后续 |
| 多人共享 AR 配置 | ❌ | 后续 |

### 9.2 技术实现

```
┌─────────────────────────┐
│   Camera Preview (底层)   │ ← 实时显示摄像头画面
│     显示打印照片           │
├─────────────────────────┤
│   AR Overlay (中层)       │ ← ARModule 渲染
│     • Live Photo 循环      │
│     • Emoji 悬浮           │
│     • 水印解码指示器       │
├─────────────────────────┤
│   H5 Overlay (最上层)      │ ← H5 UI 层（半透明操作栏）
│     • 效果控制按钮          │
│     • 分享/保存操作        │
└─────────────────────────┘
```

### 9.3 AR 技术选型

| 能力 | 插件 |
|------|------|
| 相机 | `camera`（官方） |
| 水印解码 | `image` + 自写 DCT（isolate 线程） |
| AR 叠加 | `CustomPainter` + 帧动画 |
| 视频播放 | `video_player` |

### 9.4 解码性能目标

- 取帧→解码 contentId：< 500ms
- 解码→AR 展示：< 200ms
- 总耗时 < 1 秒

## 10. 技术栈总结

| 层级 | 选型 |
|------|------|
| 壳工程 | Flutter（Dart） |
| UI 层 | React / Vue（H5，WebView 承载） |
| 跨平台 | iOS / Android / 微信小程序 |
| 本地数据库 | drift（sqflite） |
| 水印算法 | 自研 DCT 频域水印（DCTModule） |
| 相机 | CameraModule（Flutter camera 插件封装） |
| AR 叠加 | ARModule（CustomPainter + video_player） |
| 图像处理 | `image` 库 |
| JS Bridge | flutter_inappwebview（或各平台原生 WebView 桥接） |
| 存储抽象 | 接口化设计，预留多 Provider |
| 离线包 | H5 资源打包 + CDN 增量更新 |

## 11. MVP 里程碑

| 阶段 | 内容 | 估时 |
|------|------|------|
| 1 | 壳工程脚手架 + WebView 容器 + H5 UI 框架搭建 | 1 周 |
| 2 | CameraModule 封装 + 相机预览 + 矩形检测 | 1 周 |
| 3 | 暗水印编解码核心算法（DCTModule） | 2 周 |
| 4 | StorageModule（SQLite + 本地文件管理） | 1 周 |
| 5 | ARModule 叠加播放（Live Photo + Emoji） | 1 周 |
| 6 | JS Bridge 联调 + 扫描→解码→AR 闭环 | 1 周 |
| 7 | UI 打磨 + 测试 + 发布准备 | 1 周 |
| 合计 | | **8 周** |

## 12. 组件目录结构

```
arphoto/
├── lib/                          # 壳工程 Flutter 代码
│   ├── main.dart                 # 入口，注册 Module 到壳工程
│   ├── shell/                    # 壳工程核心
│   │   ├── app.dart              # App 启动、Module 注册
│   │   ├── bridge/               # JS Bridge 实现
│   │   │   ├── bridge_handler.dart
│   │   │   └── bridge_events.dart
│   │   ├── webview/              # WebView 容器管理
│   │   │   ├── webview_container.dart
│   │   │   └── offline_packager.dart
│   │   └── router/               # 路由协调
│   │       └── route_mapper.dart
│   ├── modules/                  # 原生能力组件（各 Module 独立子目录）
│   │   ├── camera/               # CameraModule
│   │   │   ├── camera_module.dart
│   │   │   ├── camera_config.dart
│   │   │   ├── frame_processor.dart
│   │   │   └── rect_detector.dart
│   │   ├── dct/                  # DCTModule
│   │   │   ├── dct_module.dart
│   │   │   ├── dct_encoder.dart
│   │   │   ├── dct_decoder.dart
│   │   │   └── utils/
│   │   │       ├── dct_algorithm.dart
│   │   │       └── watermark_payload.dart
│   │   ├── ar/                   # ARModule
│   │   │   ├── ar_module.dart
│   │   │   ├── ar_renderer.dart
│   │   │   ├── emoji_painter.dart
│   │   │   └── video_overlay.dart
│   │   └── storage/              # StorageModule
│   │       ├── storage_module.dart
│   │       ├── database/
│   │       │   ├── database_helper.dart
│   │       │   └── models/
│   │       │       ├── content.dart
│   │       │       └── ar_config.dart
│   │       ├── file_manager.dart
│   │       └── providers/
│   │           ├── storage_provider.dart
│   │           └── local_provider.dart
│   └── shared/                   # 跨模块共享
│       ├── types.dart
│       └── errors.dart
│
├── h5_ui/                        # H5 UI 层（独立项目）
│   ├── package.json
│   ├── src/
│   │   ├── pages/
│   │   │   ├── home/
│   │   │   ├── camera/           # 取景器 UI（调用原生 CameraModule）
│   │   │   ├── gallery/
│   │   │   ├── scan/
│   │   │   ├── preview/          # AR 结果展示控制
│   │   │   └── settings/
│   │   ├── bridge/
│   │   │   ├── bridge.ts         # JS Bridge 封装
│   │   │   └── types.ts          # Bridge 协议类型
│   │   └── components/
│   └── dist/                     # 构建产物，打包进壳工程
│
├── docs/
│   └── superpowers/
│       └── specs/
│           └── 2026-07-17-ar-photo-app-design.md
│
├── android/
├── ios/
└── test/

## 13. 后续迭代方向

- 白名单共享权限
- 用户自有存储对接（WebDAV / S3 / NAS）
- 官方云会员服务
- Emoji 弹幕编辑器（自定义位置、动画轨迹）
- 艺术滤镜 / AI 特效
- 实体产品（动态光栅卡、AR 相框、打印机联名）
- 微信小程序发布（复用 H5 UI 层）
