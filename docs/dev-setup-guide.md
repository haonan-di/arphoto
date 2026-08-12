# AR Photo — 项目交接文档

> 下次继续工作时，先读这个文件
> 最后更新：2026-08-11

---

## 目录

1. [项目概况](#1-项目概况)
2. [当前进度](#2-当前进度)
3. [环境搭建](#3-环境搭建)
4. [项目结构](#4-项目结构)
5. [页面路由设计](#5-页面路由设计)
6. [开发工作流](#6-开发工作流)
7. [待办清单](#7-待办清单)
8. [常见问题](#8-常见问题)

---

## 1. 项目概况

AR Photo — 手机 App，拍 Live Photo 嵌入暗水印打印，扫描复现 AR 动态效果。

```
拍 Live Photo → 嵌入暗水印 → 打印照片 → 手机一扫 → AR 复活 ✨
```

### 架构（三层）

```
┌──────────────────────────────────────┐
│  H5 UI 层 (React + Vite + TypeScript)│ ← 热更新，可移植到小程序
├──────────────────────────────────────┤
│  壳工程 (Flutter)                     │ ← App Store 审核
│  • WebView 容器                       │
│  • JS Bridge 路由                     │
│  • 离线包管理                         │
├──────────────────────────────────────┤
│  原生能力组件 (Module)                 │ ← 极低频审核
│  CameraModule │ DCTModule            │
│  ARModule     │ StorageModule        │
└──────────────────────────────────────┘
```

### 技术栈

| 层 | 选型 |
|---|---|
| 壳工程 | Flutter (Dart) |
| UI 层 | React + Vite + TypeScript |
| 原生模块 | CameraModule / DCTModule / ARModule / StorageModule |
| 通信 | JS Bridge（flutter_inappwebview 预留） |
| 数据库 | SQLite（sqflite/drift，MVP 阶段模拟） |
| 水印算法 | 自研 DCT 频域水印 |

---

## 2. 当前进度

### ✅ 已完成

#### Phase 1: 壳工程核心
- `lib/shell/app.dart` — 壳工程入口，注册所有 Module
- `lib/shell/bridge/bridge_handler.dart` — JS Bridge 核心（请求/响应/事件/超时）
- `lib/shell/webview/webview_container.dart` — WebView 容器 + 离线包管理器
- `lib/shell/router/route_mapper.dart` — H5 路由 ↔ 原生页面映射
- `lib/shared/types.dart` + `lib/shared/errors.dart` — 共享类型 + 错误码体系

#### Phase 2: CameraModule
- `lib/modules/camera/` — 相机接口 + 配置 + 帧处理器 + 矩形检测器
- MVP 阶段为模拟实现，后续接入 camera 插件

#### Phase 3: DCTModule
- `lib/modules/dct/` — DCT 算法核心 + 编码器 + 解码器 + 64bit 水印载荷
- 8×8 块 DCT 变换、中频系数差分嵌入、多数投票解码

#### Phase 4: StorageModule
- `lib/modules/storage/` — SQLite 数据库 + 文件管理器 + 多 Provider 抽象
- MVP 阶段为模拟实现，后续接入 sqflite

#### Phase 5: ARModule
- `lib/modules/ar/` — AR 渲染器 + 视频叠加 + Emoji 悬浮绘制（CustomPainter + 动画）

#### Phase 6: H5 UI 层 — 第一版
- 6 个页面 + Bridge 封装 + 底部导航

#### Phase 7: H5 UI 层 — 导航重构（2026-08-11）
- 底部导航从 5 Tab 改为 **3 Tab**：首页 / 我的内容 / 个人中心
- 拍摄/扫描 → 全屏功能页，从首页大按钮进入，不在底部导航
- 设置 → 归入个人中心子页
- 画廊 → 合并到"我的内容"Tab，加了搜索框
- 首页重新设计：两个大按钮（拍摄/扫描）+ 最近内容横向滚动 + 可折叠教程
- 新增个人中心 Tab：头像/统计卡片/菜单入口
- 新建 `src/components/TabLayout.tsx` 作为 Tab 页容器
- 路由改用 `useParams` 传参（`/preview/:contentId`）

### 🔧 环境状态

| 项目 | 状态 |
|---|---|
| Flutter SDK 3.44.9 | ✅ 已安装 |
| H5 前端（npm run dev） | ✅ 可运行，http://localhost:5173 |
| Android Studio / SDK | ❌ 未安装，需下载 |
| Android 真机调试 | ❌ 待 Android Studio 装好后进行 |
| iOS 编译 | ❌ Windows 不支持，需云构建或 Mac |

---

## 3. 环境搭建

### 3.1 启动 H5 前端（现在就可用）

```bash
cd d:\arphoto\h5_ui
npm install
npm run dev
# 浏览器打开 http://localhost:5173
```

### 3.2 运行 Flutter 到 Android 手机

```bash
# 1. 先装 Android Studio（https://developer.android.com/studio）
# 2. 配置 Android SDK
flutter config --android-sdk "C:\Users\<用户名>\AppData\Local\Android\Sdk"
flutter doctor --android-licenses

# 3. 手机开 USB 调试，连上电脑
flutter devices    # 确认设备

# 4. 启动
cd d:\arphoto
flutter pub get
flutter run
```

### 3.3 iOS 支持

Windows 不能编译 iOS，建议用 **Codemagic** 或 **GitHub Actions** 云构建。

---

## 4. 项目结构

```
arphoto/
├── lib/                              # 壳工程 + 原生 Module
│   ├── main.dart                     # 入口
│   ├── shell/                        # 壳工程核心
│   │   ├── app.dart                  # Module 注册、启动
│   │   ├── bridge/                   # JS Bridge 通信
│   │   │   ├── bridge_handler.dart   # Bridge 核心
│   │   │   └── bridge_events.dart    # 事件类型常量
│   │   ├── webview/                  # WebView 容器
│   │   │   └── webview_container.dart
│   │   └── router/                   # 路由协调
│   │       └── route_mapper.dart
│   ├── modules/                      # 原生能力组件
│   │   ├── camera/                   # CameraModule（4 文件）
│   │   ├── dct/                      # DCTModule（5 文件）
│   │   ├── ar/                       # ARModule（4 文件）
│   │   └── storage/                  # StorageModule（5 文件）
│   └── shared/                       # 共享类型 + 错误码
│       ├── types.dart
│       └── errors.dart
├── h5_ui/                            # H5 UI 层（独立项目）
│   ├── src/
│   │   ├── App.tsx                   # 路由定义
│   │   ├── pages/
│   │   │   ├── home/                 # 首页（Tab）
│   │   │   ├── my-content/           # 我的内容（Tab）
│   │   │   ├── profile/              # 个人中心（Tab）
│   │   │   ├── camera/               # 拍摄（全屏）
│   │   │   ├── scan/                 # 扫描（全屏）
│   │   │   ├── preview/              # AR 预览（全屏）
│   │   │   └── settings/             # 设置（子页）
│   │   ├── bridge/
│   │   │   ├── bridge.ts             # JS Bridge 封装
│   │   │   └── types.ts              # 协议类型
│   │   └── components/
│   │       ├── BottomNav.tsx          # 底部导航（3 Tab）
│   │       └── TabLayout.tsx          # Tab 页容器
│   └── package.json
├── docs/
│   ├── dev-setup-guide.md            # ← 就是这个文件，交接文档
│   └── superpowers/specs/
│       └── 2026-07-17-ar-photo-app-design.md  # 详细设计文档
└── README.md
```

---

## 5. 页面路由设计

### 导航结构

```
底部导航:  首页  |  我的内容  |  个人中心
           /      /my-content   /profile
```

### 页面分类

| 类型 | 路由 | 说明 | 底部导航 |
|---|---|---|---|
| **Tab 页** | `/` | 首页：拍摄/扫描大按钮 + 最近内容 + 教程 | ✅ |
| | `/my-content` | 我的内容：列表 + 搜索 + 管理 | ✅ |
| | `/profile` | 个人中心：头像/统计/菜单 | ✅ |
| **全屏页** | `/camera` | 拍摄（无底部导航） | ❌ |
| | `/scan` | 扫描（无底部导航） | ❌ |
| | `/preview/:contentId` | AR 预览（无底部导航） | ❌ |
| **子页** | `/profile/settings` | 设置 | ❌ |
| | `/profile/about` | 关于 | ❌ |

### 首页布局

```
┌────────────────────────────┐
│  AR Photo                  │  ← Logo
├────────────────────────────┤
│  ┌──────────────────────┐  │
│  │  📷 拍摄新内容        │  │  ← 大按钮，主操作
│  └──────────────────────┘  │
│  ┌──────────────────────┐  │
│  │  🔍 扫描一张照片      │  │  ← 大按钮，主操作
│  └──────────────────────┘  │
├────────────────────────────┤
│  最近内容                   │  ← 横向滚动列表
│  [缩略图] [缩略图] [缩略图]  │
├────────────────────────────┤
│  快速教程（可折叠）          │
│  1📷 2🖨️ 3🔍 4✨          │
└────────────────────────────┘
```

---

## 6. 开发工作流

### 启动开发环境

```bash
# 终端 1: H5 前端（热更新）
cd d:\arphoto\h5_ui
npm run dev

# 终端 2: Flutter 壳工程
cd d:\arphoto
flutter run
```

### 调试策略

| 场景 | 工具 | 方式 |
|---|---|---|
| H5 UI 样式/交互 | Chrome DevTools | http://localhost:5173 |
| Bridge 通信 | 浏览器 Console | 看 `[Bridge] Mock call:` 日志 |
| 原生模块 | Flutter DevTools | `flutter run` 后连接 |
| 真机相机/AR | Android 真机 | `flutter run` |

### 代码提交

```bash
git add .
git commit -m "feat: 做了什么"
git push
```

---

## 7. 待办清单

### 优先级 P0（核心链路打通）

- [ ] **安装 Android Studio** → 配好 Android SDK
- [ ] **Android 真机跑通 `flutter run`**
- [ ] **集成真实相机**：`camera_module.dart` 中的模拟实现替换为 `camera` 插件的 `CameraController`
- [ ] **集成真实 WebView**：`webview_container.dart` 中的占位替换为 `flutter_inappwebview`

### 优先级 P1（功能完善）

- [ ] **集成真实数据库**：`database_helper.dart` 中的模拟实现替换为 sqflite 或 drift
- [ ] **DCT 编解码真机验证**：用真实图片测试编解码链路
- [ ] **Bridge 联调**：H5 ↔ 原生通信真机打通
- [ ] **集成 video_player**：`video_overlay.dart` 的占位替换为真实播放器

### 优先级 P2（体验打磨）

- [ ] **iOS 云构建配置**：Codemagic 或 GitHub Actions
- [ ] **离线包更新机制**：CDN 增量更新
- [ ] **H5 页面加载状态**：骨架屏 + 加载动画
- [ ] **错误处理优化**：各页面加载失败的重试/降级

### 优先级 P3（未来迭代）

- [ ] 微信小程序发布（复用 H5 UI 层）
- [ ] 白名单共享权限
- [ ] 云存储对接（WebDAV / S3 / NAS）
- [ ] Emoji 弹幕编辑器（自定义位置、动画轨迹）
- [ ] 艺术滤镜 / AI 特效

---

## 8. 常见问题

### `flutter pub get` 慢

```bash
PUB_HOSTED_URL=https://pub.flutter-io.cn
FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

### `flutter doctor` 报 `Android licenses not accepted`

```bash
flutter doctor --android-licenses
# 一直按 y 接受
```

### 手机连上但 `flutter devices` 看不到

```bash
adb kill-server
adb start-server
adb devices
```

### H5 页面在壳工程 WebView 中白屏

```properties
# android/app/src/main/AndroidManifest.xml 中：
android:usesCleartextTraffic="true"
```

---

## 附录：Git 提交记录

```
62efa9e  feat: 重构为壳工程+H5 UI+原生组件三层架构
6807845  Move design doc to specs directory
d42ced4  Initial commit: AR Photo app scaffold
```

> 下次续接工作：`cd d:\arphoto\h5_ui && npm run dev` 启动前端，看 `docs/dev-setup-guide.md` 的待办清单继续。