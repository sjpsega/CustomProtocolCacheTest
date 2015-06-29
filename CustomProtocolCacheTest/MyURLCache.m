//
//  MyURLCache.m
//  WebViewTest
//
//  Created by sjpsega on 15/6/26.
//  Copyright (c) 2015年 alibaba. All rights reserved.
//

#import "MyURLCache.h"

@implementation MyURLCache

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request{
    //测试二：设置不返回cache缓存，但是测试无效，缓存依然存在
    NSLog(@"cachedResponseForRequest:   %@",request.URL.absoluteString);
//    return [super cachedResponseForRequest:request];
    return nil;
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request{
    NSLog(@"storeCachedResponse...:   %@",request.URL.absoluteString);
}
@end
