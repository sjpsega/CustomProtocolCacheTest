//
//  MyURLProtocol.m
//  WebViewTest
//
//  Created by sjpsega on 15/6/4.
//  Copyright (c) 2015年 alibaba. All rights reserved.
//

#import "MyURLProtocol.h"
//这个头必须加，防止请求重复，导致死循环
static NSString *WingTextURLHeader = @"Wing-Cache";

@implementation MyURLProtocol{
    NSURLConnection *_connection;
}

+(BOOL)canInitWithRequest:(NSURLRequest *)request{
//    NSLog(@"canInitWithRequest... : %@",request.URL.absoluteString);
    if([request valueForHTTPHeaderField:WingTextURLHeader]){
        return NO;
    }
    //拦截js请求
    if([[request.URL.absoluteString pathExtension] rangeOfString:@"js"].location != NSNotFound){
        return YES;
    }
    return NO;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    return request;
}

-(void)startLoading {
    NSLog(@"startLoading : %@",[self request].URL.absoluteString);
    
    if([[self request].URL.absoluteString hasPrefix:@"abc://xxx.com/index.js"]){
        NSLog(@"请求js...");
        
        //加载本地js数据
        NSString *indexJSPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"js"];
        NSData *indexJSData = [[NSData alloc] initWithContentsOfFile:indexJSPath];
        
        NSString *absoluteURLString = [self request].URL.absoluteString;
        //方式二：协议改成 http 或 https，测试有效，不缓存
//        absoluteURLString = @"http://g.alicdn.com/sd/data_sufei/1.4.3/aplus/index.js";
        
        //测试一：后加随机字符串，测试无效，缓存依然存在
//        absoluteURLString = [NSString stringWithFormat:@"%@?%@", absoluteURLString, [NSString stringWithFormat:@"t=%i",arc4random()]];
        
        NSURL *url = [NSURL URLWithString:absoluteURLString];
        
        NSURLResponse* response =
        [[NSURLResponse alloc] initWithURL:url
                                  MIMEType:@"application/x-javascript"
                     expectedContentLength:indexJSData.length
                          textEncodingName:@"UTF-8"];
        [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [[self client] URLProtocol:self didLoadData:indexJSData];
        [[self client] URLProtocolDidFinishLoading:self];
        return;
    }
    NSMutableURLRequest *connectionRequest = [[self request] mutableCopy];
    // we need to mark this request with our header so we know not to handle it in +[NSURLProtocol canInitWithRequest:].
    [connectionRequest setValue:@"" forHTTPHeaderField:WingTextURLHeader];
    
    _connection = nil;
    _connection = [[NSURLConnection alloc] initWithRequest:connectionRequest delegate:self startImmediately:NO];
    [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_connection start];
}

-(void)stopLoading {
    [_connection cancel];
    _connection = nil;
}

#pragma mark implement NSURLConnectionDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
//    NSLog(@"%@   ----    %@",response.URL.absoluteString,request.URL.absoluteString);
    
    if (response) {
        NSMutableURLRequest *redirectableRequest = [request mutableCopy];
        // We need to remove our header so we know to handle this request and cache it.
        // There are 3 requests in flight: the outside request, which we handled, the internal request,
        // which we marked with our header, and the redirectableRequest, which we're modifying here.
        // The redirectable request will cause a new outside request from the NSURLProtocolClient, which
        // must not be marked with our header.
        [redirectableRequest setValue:nil forHTTPHeaderField:WingTextURLHeader];
        
        [[self client] URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
        return redirectableRequest;
        
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[self client] URLProtocol:self didFailWithError:error];
    _connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    NSLog(@"%@",response);
//    NSURLResponse *responseB = [[NSURLResponse alloc] initWithURL:[self request].URL MIMEType:response.MIMEType  expectedContentLength:0 textEncodingName:@"utf-8"];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //    NSLog(@"connection");
    [[self client] URLProtocolDidFinishLoading:self];
    
    _connection = nil;
}

//可在该方法中，修改cache的策略，返回nil表示不缓存
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
//    NSLog(@"%@   %i    %i",cachedResponse.response.URL.absoluteString,[connection currentRequest].cachePolicy, cachedResponse.storagePolicy);
    return nil;
}
@end
