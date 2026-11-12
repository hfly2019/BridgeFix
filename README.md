# BridgeFix ⌚️ 

[![Build and Release](https://github.com/hfly2019/BridgeFix/actions/workflows/build-and-release.yml/badge.svg)](https://github.com/hfly2019/BridgeFix/actions/workflows/build-and-release.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0%2B-lightgrey.svg)](https://github.com/hfly2019/BridgeFix)
[![Architecture](https://img.shields.io/badge/Arch-arm64%20%7C%20arm64e-brightgreen.svg)](https://github.com/hfly2019/BridgeFix)

[English](#english) | [中文说明](#中文说明)

---

<a name="english"></a>
## English

A lightweight dynamic library (`.dylib`) fix for the pairing crash when connecting **watchOS 9+ (Apple Watch Series 8 / Ultra / SE 2)** to **iOS 15.0** via the stock **Watch (Bridge)** app under **TrollStore** or jailbroken environments.

### 📌 The Problem
On iOS 15.0, pairing an Apple Watch running watchOS 9+ triggers a fatal crash in `Bridge.app`:
```log
-[WKWebView stringByEvaluatingJavaScriptFromString:]: unrecognized selector sent to instance ...
*** Terminating app due to uncaught exception 'NSInvalidArgumentException'
```
This is caused by legacy code in `BridgePreferences.framework` calling the deprecated `UIWebView` method on modern `WKWebView` instances loaded by `RemoteUI.framework`.

### 💡 The Solution
`BridgeFix` implements a dynamic Objective-C Category on `WKWebView` to safely capture `-stringByEvaluatingJavaScriptFromString:`, forward it to `evaluateJavaScript:`, and return safely without throwing an exception.

### 🚀 Installation (TrollStore + TrollFools)
No jailbreak required!

1. Download `BridgeFix.dylib` from [Releases](https://github.com/hfly2019/BridgeFix/releases).
2. Transfer `BridgeFix.dylib` to your iPhone (e.g. AirDrop, iCloud Drive, or local storage).
3. Open **TrollFools** on your device.
4. Select the stock **Watch (手表)** application.
5. Tap **Inject (+)** and select `BridgeFix.dylib`.
6. Force-quit the Watch app and re-open it. Pairing will now complete without crashing!

### 🛠 Building from Source
Requires macOS with Xcode Command Line Tools:
```bash
git clone https://github.com/hfly2019/BridgeFix.git
cd BridgeFix
./scripts/build.sh
# Compiled binary located at build/BridgeFix.dylib
```

---

<a name="中文说明"></a>
## 中文说明

用于解决 **iOS 15.0** 系统通过官方 **Watch (Bridge)** 应用配对 **watchOS 9+（如 Apple Watch S8 / Ultra / SE 2）** 时必定闪退的轻量级原生补丁动态库（`.dylib`）。支持纯 **TrollStore（巨魔）** 与越狱环境。

### 📌 故障原因
在 iOS 15.0 系统中，配对高版本 Apple Watch 时，激活服务器下发的 RemoteUI 页面会由现代 `WKWebView` 渲染。但苹果私有库 `BridgePreferences.framework` 内部残留了旧版代码，直接向 `WKWebView` 发送了废弃的 `stringByEvaluatingJavaScriptFromString:` 同步消息，引发 `NSInvalidArgumentException` 未捕获异常导致主线程崩溃中断配对。

### 💡 修复原理
`BridgeFix` 在运行时为 `WKWebView` 扩展 Category，安全拦截并转发该同步方法至现代异步 `evaluateJavaScript:` 接口，彻底消除异常，保证配对流程顺畅进行。

### 🚀 安装指南（TrollStore + TrollFools 免越狱极简注入）

1. 从 [Releases 页面](https://github.com/hfly2019/BridgeFix/releases) 下载预编译好的 `BridgeFix.dylib`。
2. 将文件保存至手机“文件”App。
3. 打开手机上的 **TrollFools**。
4. 在应用列表中找到自带的 **Watch（手表）**。
5. 点击右上角 **`+`（注入）**，选取刚才下载的 `BridgeFix.dylib`。
6. 上划彻底关闭 Watch 应用后重新打开，即可正常配对！

### 🛠 本地源码编译
在 macOS 环境下执行：
```bash
git clone https://github.com/hfly2019/BridgeFix.git
cd BridgeFix
./scripts/build.sh
# 编译产物位于 build/BridgeFix.dylib（支持 arm64 与 arm64e 双架构）
```

---

## 🤝 共同维护与贡献 (Contributing)

本项目旨在为保留在 iOS 15 黄金巨魔/越狱系统的用户提供稳定、持续的 Apple Watch 跨版本兼容支持。

- **反馈 Issue**：如果您在其他机型或 watchOS 10+ 上测试遇到问题，欢迎附带日志提交 Issue。
- **提交 PR**：对于后续跨版本功能（如心电图 ECG 协议同步、血氧、健身圆环守护进程通信），欢迎任何逆向研究者共同提交 Pull Request。

## 📄 License
This project is open-sourced under the [MIT License](LICENSE).
