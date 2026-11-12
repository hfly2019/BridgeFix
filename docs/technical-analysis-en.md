# iOS 15.0 Apple Watch (watchOS 9+) Pairing Crash Analysis and Fix

> **Environment**:
> - **iOS Device**: iPhone (A12+ arm64e), iOS 15.0
> - **Environment State**: Pure TrollStore environment (No active jailbreak/ElleKit daemon)
> - **Apple Watch**: Apple Watch Series 8 (watchOS 9.1)
> - **Tools**: Legizmo Kincaid, TrollFools, Xcode Command Line Tools

---

## 1. Problem Description

When attempting to pair an Apple Watch running **watchOS 9+** with an iPhone on **iOS 15.0** via the stock **Watch (`Bridge.app`)** application, the app crashes deterministically near the end of the initial setup flow (during the terms of service, diagnostics, or watch setup screen). This interruption causes an immediate rollback of the pairing process.

---

## 2. Root Cause Analysis

### Crash Logs
From `.ips` crash logs:
- **Process**: `com.apple.Bridge`
- **Signal**: `EXC_CRASH (SIGABRT)`
- **Exception**: `NSInvalidArgumentException`

Syslog captured the exact fatal exception:
```log
Bridge(CoreFoundation): -[WKWebView stringByEvaluatingJavaScriptFromString:]: unrecognized selector sent to instance 0x10389aa00
Bridge(CoreFoundation): *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[WKWebView stringByEvaluatingJavaScriptFromString:]: unrecognized selector sent to instance 0x10389aa00'
```

### Explanation
1. In iOS 15, `RemoteUI.framework` adopted modern `WKWebView`.
2. However, in iOS 15.0, `BridgePreferences.framework` still contained legacy code expecting `UIWebView`, invoking `stringByEvaluatingJavaScriptFromString:`.
3. Because `WKWebView` lacks this selector, an unhandled exception is thrown, crashing the application.

---

## 3. The Solution (`BridgeFix`)

`BridgeFix` implements a dynamic Objective-C Category on `WKWebView`:
- Intercepts calls to `-[WKWebView stringByEvaluatingJavaScriptFromString:]`.
- Safely delegates execution to `evaluateJavaScript:completionHandler:`.
- Returns a safe empty `NSString *`, preventing the unhandled selector crash.

Injected seamlessly via **TrollFools** without requiring a full jailbreak.
