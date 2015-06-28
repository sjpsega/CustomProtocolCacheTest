//
//  MyUIViewController.m
//  WebViewTest
//
//  Created by sjpsega on 15/6/4.
//  Copyright (c) 2015年 alibaba. All rights reserved.
//

#import "MyUIViewController.h"
#import "MyURLProtocol.h"

@implementation MyUIViewController{
    UIWebView *myUIWebView;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        
    }
    return self;
}

- (void)viewDidLoad{
    CGRect rect = self.view.frame;
    rect.origin.y += 100;
    myUIWebView = [[UIWebView alloc] initWithFrame:rect];
    [self.view addSubview:myUIWebView];
    
    //加载本地html
    NSString *indexHTMLPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSData *indexHTMLData = [[NSData alloc] initWithContentsOfFile:indexHTMLPath];
    NSString *htmlString = [[NSString alloc] initWithData:indexHTMLData encoding:NSUTF8StringEncoding];
    
    //方法一：修改模板上的 url 字符串，添加随机字符，测试有效，无缓存
//    NSRange range = [htmlString rangeOfString:@"abc://xxx.com/index.js"];
//    NSString *changeString = [NSString stringWithFormat:@"%@?t=%i",@"abc://xxx.com/index.js",arc4random()];
//    htmlString = [htmlString stringByReplacingCharactersInRange:range withString:changeString];
    
    [myUIWebView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:indexHTMLPath]];
}

- (IBAction)closeWindowHandler:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    //清除本地缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
