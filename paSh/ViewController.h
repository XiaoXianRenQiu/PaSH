//
//  ViewController.h
//  paSh
//
//  Created by 劉鵬飛 on 2015/9/29.
//  Copyright © 2015年 劉鵬飛. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
@interface ViewController : NSViewController<NSURLSessionTaskDelegate,NSURLSessionDelegate,NSURLSessionDataDelegate,WKUIDelegate,WKNavigationDelegate>

@property (nonatomic,retain)NSTextField* textField;
@property (nonatomic,retain)WKWebView *webView;
@property (nonatomic,retain)NSTextView *textView;
@property (nonatomic,retain)NSButton *goButton;

@end

