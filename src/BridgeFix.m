#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

/**
 * BridgeFix - Fix iOS 15.0 Bridge WKWebView RemoteUI Crash
 *
 * Root Cause:
 * In iOS 15.0, BridgePreferences.framework invokes legacy UIWebView method:
 * -[WKWebView stringByEvaluatingJavaScriptFromString:]
 * on modern WKWebView instances loaded by RemoteUI during Apple Watch pairing,
 * causing an unrecognized selector exception (SIGABRT).
 *
 * Solution:
 * Implement a runtime Category on WKWebView that catches the selector and
 * safely forwards the script to -[WKWebView evaluateJavaScript:completionHandler:].
 */

@interface WKWebView (BridgeFix)
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
@end

@implementation WKWebView (BridgeFix)

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script {
    NSLog(@"[BridgeFix] Intercepted -[WKWebView stringByEvaluatingJavaScriptFromString:]: %@", script);
    
    if (!script || [script length] == 0) {
        return @"";
    }
    
    // Safely dispatch to modern WebKit asynchronous evaluateJavaScript API
    if ([NSThread isMainThread]) {
        [self evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
            if (error) {
                NSLog(@"[BridgeFix] evaluateJavaScript warning: %@", error);
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self evaluateJavaScript:script completionHandler:nil];
        });
    }
    
    // Return empty string to satisfy synchronous return expectation
    return @"";
}

@end

__attribute__((constructor))
static void BridgeFixInit(void) {
    NSLog(@"[BridgeFix] Successfully injected into process: %d", getpid());
}
