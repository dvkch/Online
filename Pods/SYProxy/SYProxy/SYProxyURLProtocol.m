//
//  SYProxyURLProtocol.m
//  Proxy
//
//  Created by Stanislas Chevallier on 02/06/15.
//  Copyright (c) 2015 Syan. All rights reserved.
//

#import "SYProxyURLProtocol.h"
#import "SYProxyModel.h"
#import "SYProxySessionChallengeSender.h"

static id<SYProxyURLProtocolDataSource> SYProxyURLProtocolDataSource;

@interface SYProxyURLProtocol () <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSessionDataTask *myTask;
@end

@implementation SYProxyURLProtocol

+ (void)setDataSource:(id<SYProxyURLProtocolDataSource>)dataSource
{
    SYProxyURLProtocolDataSource = dataSource;
}

+ (void)load
{
    [NSURLProtocol registerClass:[self class]];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    SYProxyModel *proxy = [SYProxyURLProtocolDataSource firstProxyMatchingURL:request.URL];
    return proxy ? YES : NO;
}

- (void)startLoading
{
    SYProxyModel *proxy = [SYProxyURLProtocolDataSource firstProxyMatchingURL:self.request.URL];
    NSAssert1(proxy != nil, @"Cannot find proxy for URL %@. Be sure to set the +dataSource for SYProxyURLProtocol", self.request.URL.absoluteString);
    
    NSDictionary *proxyDict = nil;
    if(proxy.host)
    {
        proxyDict = @{@"HTTPEnable":                              @YES,
                      (NSString *)kCFStreamPropertyHTTPProxyHost: proxy.host,
                      (NSString *)kCFStreamPropertyHTTPProxyPort: @(proxy.port)};
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.connectionProxyDictionary = proxyDict;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    self.myTask = [session dataTaskWithRequest:self.request];
    [self.myTask resume];
}

- (void)stopLoading
{
    [self.myTask cancel];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

///////////////

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if(error)
        [self.client URLProtocol:self didFailWithError:error];
    else
        [self.client URLProtocolDidFinishLoading:self];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    SYProxySessionChallengeSender *sender = [[SYProxySessionChallengeSender alloc] initWithSessionCompletionHandler:completionHandler];
    NSURLAuthenticationChallenge* challengeWrapper = [[NSURLAuthenticationChallenge alloc] initWithAuthenticationChallenge:challenge sender:sender];
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challengeWrapper];
}

@end

