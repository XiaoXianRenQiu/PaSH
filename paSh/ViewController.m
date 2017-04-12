//
//  ViewController.m
//  paSh
//
//  Created by 劉鵬飛 on 2015/9/29.
//  Copyright © 2015年 劉鵬飛. All rights reserved.
//

#import "ViewController.h"



@implementation ViewController{

    NSMutableString *dataString;//邮箱字符串
    NSMutableDictionary *urlDictionary;
    double mainWidth,mainHeight;
}

- (void)viewDidAppear{

    [super viewDidAppear];
    
    dataString = [NSMutableString string];
    
    //改变windows大小发送通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationViewChanged) name:NSWindowDidResizeNotification object:nil];

    //最小化时发送的通知
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWindowMin) name:NSWindowDidMiniaturizeNotification object:nil];
    //点击左上角x号时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWindoCloss) name:NSWindowWillCloseNotification object:nil];
    
    //本视图宽高
    mainWidth   = self.view.bounds.size.width;
    mainHeight  = self.view.bounds.size.height;
    
    //web视图
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(15, 10, (mainWidth - 20)/2, (mainHeight - 40))];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    
    //邮箱显示视图
    _textView = [[NSTextView alloc] initWithFrame:CGRectMake((mainWidth - 20)/2+20, 10, (mainWidth - 20)/2-5, (mainHeight - 40))];
    [_textView setTextColor:[NSColor redColor]];
    [_textView setString:@"email"];
    [self.view addSubview:_textView];
    
    //输入框
    _textField = [[NSTextField alloc] initWithFrame:CGRectMake(20,(mainHeight - 20), (mainWidth - 60), 20)];
    _textField.textColor = [NSColor grayColor];
    [_textField setStringValue:@"email"];
    [_textField setAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_textField];
    
    //go按钮
    _goButton = [[NSButton alloc] initWithFrame:CGRectMake((mainWidth - 30), (mainHeight - 20), 30, 20)];
    [_goButton setTitle:@"GO"];
    [_goButton setAction:@selector(goAction)];
    [self.view addSubview:_goButton];
    
    urlDictionary = [NSMutableDictionary dictionary];
}


//go按钮点击事件
- (void)goAction{

    NSURL *url = [NSURL URLWithString:_textField.stringValue];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:60];
    [urlDictionary removeAllObjects];
    dataString = [NSMutableString string];
    [_webView loadRequest:request];
}


//提取email并显示出来
- (void)emailData:(NSData *)data{
    
    NSMutableString *emailText = [NSMutableString string];
    NSMutableArray *emailArray = [NSMutableArray array];
    NSMutableString *stringData = nil;
    @try {
        stringData = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    if (!stringData) {
        return;
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[A-Z0-9a-z%+]+@[A-Za-z0-9]+\\.[A-Za-z]{2,4}" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *rangeArray = [regex matchesInString:stringData options:0 range:NSMakeRange(0, [stringData length])];
    for (NSTextCheckingResult *textResult in rangeArray) {
        
        NSString *sub = [stringData substringWithRange:textResult.range];
        [emailArray addObject:sub];
        
    }
    //去重
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *email in emailArray) {
        [dict setObject:email forKey:email];
    }
    emailArray = (NSMutableArray *)[dict allKeys];
    
    for (int i = 0; i < emailArray.count; i++) {
        
        [emailText appendString:[NSString stringWithFormat:@"%@\n",[emailArray objectAtIndex:i]]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        dataString = emailText;
        [dataString appendString:emailText];
        [_textView setString:(NSString *)dataString];
    });
}


//viewframe改变时执行
- (void)notificationViewChanged
{
    //本视图宽高
    mainWidth   = self.view.frame.size.width;
    mainHeight  = self.view.frame.size.height;
    
    
    //web视图
    _webView.frame = CGRectMake(15, 10, (mainWidth - 20)/2, (mainHeight - 40));
    
    //输入框
    _textField.frame = CGRectMake(20,(mainHeight - 20), (mainWidth - 60), 20);
    
    //go按钮
    _goButton.frame = CGRectMake((mainWidth - 30), (mainHeight - 20), 30, 20);
    
    //邮箱显示视图
    if (_textView) {
        [_textView removeFromSuperview];
        _textView = nil;
        _textView = [[NSTextView alloc] initWithFrame:CGRectMake((mainWidth - 20)/2+20, 10, (mainWidth - 20)/2-5, (mainHeight - 40))];
        [_textView setTextColor:[NSColor redColor]];
        _textView.string = (dataString.length > 0)?dataString:@"email";
        [self.view addSubview:_textView];
        
        
    }
    

}

- (void)notificationWindowMin{
    //最小化
    [super viewDidDisappear];
    [_textField removeFromSuperview];
    _textField = nil;
    [_goButton removeFromSuperview];
    _goButton = nil;
    [_webView removeFromSuperview];
    _webView = nil;
    [_textView removeFromSuperview];
    _textView = nil;
    NSLog(@"最小化");


}


//windows关闭时退出应用
- (void)notificationWindoCloss{

    exit(0);

}

#pragma mark -WKNavigationDelegate

//页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
    NSLog(@"页面开始加载");
    
    
}

//页面开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
    
    NSLog(@"页面开始返回");
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@",webView.URL];
    

    if (![self searchAllKeys:[urlDictionary allKeys] isIncludeKey:urlString]) {
        
        [_textField setStringValue:[NSString stringWithFormat:@"%@",webView.URL]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webView.URL];
        [request setHTTPMethod:@"GET"];
        [request setTimeoutInterval:60];
        
        [_webView loadRequest:request];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error == nil) {
                
                if (data) {
                    
                    [self emailData:data];
                    
                }
                
            }else{
            
                NSLog(@"抓去数据失败!!!!!!!!! %@",error);
            
            }
            
        }];
        
        [task resume];
    }
    
    [urlDictionary setObject:urlString
                      forKey:urlString];
    

    
}

//判断字典中是否存在某个key
- (BOOL)searchAllKeys:(NSArray *)array isIncludeKey:(NSString *)key{


    for (NSString *string in array) {
        
        if ([string isEqualToString:key]) {
            return YES;
        }
    }
    
    return NO;

}


//页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    
    NSLog(@"页面加载完成 --- %@",navigation);
    
}

//页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
    NSLog(@"页面加载失败!!!!!!!! %@",error);
    
}


//链接到服务器跳转请求后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
    NSLog(@"----%@",navigation);
    
}


//收到响应后决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSLog(@"%@----- %ld",navigationAction.request.URL.absoluteString,(long)navigationAction.navigationType);

    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);

    switch (navigationAction.navigationType) {
        case WKNavigationTypeLinkActivated:{
        
            if (![self searchAllKeys:[urlDictionary allKeys] isIncludeKey:navigationAction.request.URL.absoluteString]) {
                
                [_webView loadRequest:navigationAction.request];
                dataString = [NSMutableString string];
            }
            
        
            break;
        }
        case WKNavigationTypeOther:{
        
            
            break;
        }
            
        default:{
        
        
            break;
        }
    }
    
    //不允许跳转
    //    decisionHandler(WKNavigationActionPolicyCancel);
    
    
}



- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
