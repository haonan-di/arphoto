# AR Photo — 开发环境搭建 & 运行指南

> 适用环境：Windows PC + VS Code + Android/iOS 手机
> 最后更新：2026-08-11

---

## 目录

1. [环境准备](#1-环境准备)
2. [H5 UI 层（浏览器即可跑）](#2-h5-ui-层浏览器即可跑)
3. [Flutter 壳工程（Android 手机）](#3-flutter-壳工程android-手机)
4. [iOS 支持方案](#4-ios-支持方案)
5. [开发工作流](#5-开发工作流)
6. [常见问题](#6-常见问题)

---

## 1. 环境准备

### 1.1 安装 Flutter SDK

```bash
# 1. 下载 Flutter SDK
#    去 https://docs.flutter.dev/get-started/install/windows
#    下载 flutter_windows_x.x.x-stable.zip

# 2. 解压到 D:\flutter（或你喜欢的路径）

# 3. 配置环境变量
#    系统变量 Path 里添加：D:\flutter\bin

# 4. 验证安装
flutter doctor
```

### 1.2 VS Code 插件

| 插件 | 用途 |
|---|---|
| **Flutter** (Dart Code) | Dart/Flutter 语言支持、调试、热重载 |
| **Error Lens** | 行内显示编译错误 |
| **GitLens** | Git 历史可视化 |

### 1.3 Android 手机准备

```bash
# 1. 手机开启 开发者模式
#    设置 → 关于手机 → 连续点"版本号"7 次

# 2. 开启 USB 调试
#    设置 → 开发者选项 → USB 调试

# 3. 连上 USB 验证
flutter devices
# 输出应显示你的 Android 设备

# 4. 如果没识别到设备
#    - 安装手机厂商 USB 驱动（https://developer.android.com/studio/run/oem-usb）
#    - 或使用无线调试：
#      adb pair <ip>:<port>   # 手机开发者选项里扫码配对
#      adb connect <ip>:<port>
```

### 1.4 安装 Node.js

H5 UI 层需要 Node.js 运行开发服务器：

```bash
# 去 https://nodejs.org 下载 LTS 版
# 安装后验证
node --version
npm --version
```

---

## 2. H5 UI 层（浏览器即可跑）

先跑 H5 层，不需要手机，PC 浏览器就能看到效果：

```bash
# 1. 进入 H5 目录
cd d:\arphoto\h5_ui

# 2. 安装依赖
npm install

# 3. 启动开发服务器
npm run dev

# 4. 浏览器打开 http://localhost:5173
#    能看到 App 的 UI 页面（首页/拍摄/扫描/画廊/设置）
```

> 浏览器中运行时，所有 Bridge 调用（相机、水印、AR）走**模拟模式**，
> 控制台会打印 `[Bridge] Mock call: ...` 日志。

### 2.1 H5 页面清单

| 路由 | 页面 | 说明 |
|---|---|---|
| `/` | 首页 | 英雄区 + 快捷入口 |
| `/camera` | 拍摄 | 模拟相机预览 + 水印嵌入流程 |
| `/scan` | 扫描 | 框选取景 + 解码流程 |
| `/preview` | AR 预览 | 播放控制 + Emoji 装饰 |
| `/gallery` | 画廊 | 内容管理 |
| `/settings` | 设置 | 权限 / 存储 / 版本信息 |

---

## 3. Flutter 壳工程（Android 手机）

```bash
# 1. 进入项目根目录
cd d:\arphoto

# 2. 获取 Flutter 依赖
flutter pub get

# 3. 连接 Android 手机（USB 或无线）
#    确认设备已识别
flutter devices

# 4. 运行到手机
flutter run
```

### 3.1 首次运行可能遇到的问题

```
flutter pub get 慢
  → 设置镜像源：
    PUB_HOSTED_URL=https://pub.flutter-io.cn
    FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

gradle 版本不兼容
  → 打开 android/gradle-wrapper.properties 调整版本号

WebView 加载 HTTP 地址白屏
  → 开发时在 android/app/src/main/AndroidManifest.xml 中允许明文：
    android:usesCleartextTraffic="true"
```

---

## 4. iOS 支持方案

**Windows 不能直接编译 iOS 应用。** 以下几种方案：

### 方案 A：云构建（推荐）

```yaml
# 使用 Codemagic 或 GitHub Actions，每次 push 自动编译 IPA
# 无需本地 Mac，免费版每月 500 分钟构建时间
```

### 方案 B：公司 Mac

- 找台 Mac Mini / MacBook
- 或在公司 IT 允许范围内使用云 Mac 服务（MacStadium / MacinCloud）

### 方案 C：H5 调试 + 跳过 iOS 原生

- H5 UI 层通过 Safari Web Inspector 调试
- iOS 原生部分（CameraModule 等在 iOS 上）暂时跳过，后续用云构建验证

> 开发阶段建议：**Android 真机调试为主，iOS 用云构建。**

---

## 5. 开发工作流

### 5.1 推荐 VS Code 布局

```
┌─────────────────────────────────────┐
│  VS Code 分两个终端                   │
├─────────────────────────────────────┤
│  终端 1: H5 前端                      │
│  cd d:\arphoto\h5_ui && npm run dev   │
│  → 改 H5 代码即时热更新                │
├─────────────────────────────────────┤
│  终端 2: Flutter 壳                   │
│  cd d:\arphoto && flutter run         │
│  → 改 Dart 代码热重载 (r)             │
└─────────────────────────────────────┘
```

### 5.2 三端调试策略

| 场景 | 工具 | 方式 |
|---|---|---|
| H5 UI 样式/交互 | Chrome DevTools | 浏览器 http://localhost:5173 |
| Bridge 通信 | 浏览器 Console | 看 `[Bridge] Mock call:` 日志 |
| 原生模块 | Flutter DevTools | `flutter run` 后连接 DevTools |
| 数据库 | SQLite 浏览器 | 导出 `ar_index.db` 查看 |
| 真机相机/AR | Android 真机 | `flutter run` 直接跑 |

### 5.3 Bridge 通信调试

```typescript
// H5 端：在浏览器控制台手动测试
bridge.call('camera.startPreview', {})
  .then(r => console.log('Result:', r))
  .catch(e => console.error('Error:', e))

// 原生端：在 Dart 代码中加 debugPrint
debugPrint('[Bridge] Request: ${request.action}');
```

### 5.4 代码提交流程

```bash
# 1. 确认当前分支
git branch

# 2. 添加并提交
git add .
git commit -m "feat: 描述做了什么"

# 3. 推送到远端
git push
```

---

## 6. 常见问题

### Q: `flutter doctor` 报错 `Android licenses not accepted`

```bash
flutter doctor --android-licenses
# 一直按 y 接受
```

### Q: `flutter run` 报错 `Gradle build failed`

```bash
# 检查 Gradle 版本
cat android/gradle/wrapper/gradle-wrapper.properties

# 如果版本太旧，手动更新
# 并检查 android/build.gradle 中的 AGP 版本
```

### Q: 手机连上但 `flutter devices` 看不到

```bash
# 1. 检查 USB 线是否支持数据传输（不是充电线）
# 2. 重新插拔
# 3. 重启 adb
adb kill-server
adb start-server
adb devices
```

### Q: H5 页面在壳工程 WebView 中白屏

```properties
# 开发时在 AndroidManifest.xml 中：
android:usesCleartextTraffic="true"

# 或使用 HTTPS 的本地开发服务器
```

### Q: 手机调试时无法访问本地 H5 开发服务器

```bash
# 1. 查 PC 的局域网 IP
ipconfig
# 比如 192.168.1.100

# 2. 修改 vite.config.ts，允许外部访问
#    server.host: '0.0.0.0' 已配置

# 3. 手机浏览器访问 http://192.168.1.100:5173
#    确认手机和 PC 在同一 Wi-Fi 下
```

---

## 项目结构速查

```
arphoto/
├── lib/                          # 壳工程 + 原生 Module
│   ├── main.dart                 # 入口
│   ├── shell/                    # 壳工程核心
│   │   ├── app.dart              # Module 注册、启动
│   │   ├── bridge/               # JS Bridge 通信
│   │   ├── webview/              # WebView 容器
│   │   └── router/               # 路由协调
│   ├── modules/                  # 原生能力组件
│   │   ├── camera/               # CameraModule
│   │   ├── dct/                  # DCTModule
│   │   ├── ar/                   # ARModule
│   │   └── storage/              # StorageModule
│   └── shared/                   # 共享类型 + 错误码
├── h5_ui/                        # H5 UI 层（独立项目）
│   ├── src/
│   │   ├── pages/                # 6 个页面
│   │   ├── bridge/               # Bridge 封装
│   │   └── components/           # 通用组件
│   └── package.json
└── docs/                         # 设计文档
```

## 架构示意图

```
┌──────────────────────────────────────┐
│    小程序 (复用 H5 UI 层)              │
└──────────┬───────────────────────────┘
           │ 同一套 H5 代码
┌──────────▼───────────────────────────┐
│  H5 UI 层 (React + Vite)             │ ← 热更新
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

---

> 有疑问？在项目根目录提 Issue，或找 `lihaonan01` 沟通。