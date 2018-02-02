//
//  CASRequestInterceptor.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASRequestInterceptor.h"

#import "Castle.h"
#import "CASUtils.h"

static NSString *CASRecursiveRequestFlagProperty = @"com.castle.CASRequestInterceptor";

@interface CASRequestInterceptor () <NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURLSessionDataTask *task;
@end

@implementation CASRequestInterceptor

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([NSURLProtocol propertyForKey:CASRecursiveRequestFlagProperty inRequest:request]) {
        return NO;
    }
    
    BOOL shouldIntercept = [Castle isWhitelistURL:request.URL];
    if(shouldIntercept) {
        CASLog(@"Will intercept request with URL: %@", request.URL.absoluteString);
    }
    return shouldIntercept;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{    
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{    
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    // Always flush the queue when a request is intercepted
    [Castle flush];
    
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:CASRecursiveRequestFlagProperty inRequest:newRequest];
    
    // Set custom headers
    [[Castle headers] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL* stop) {
        [newRequest setValue:value forHTTPHeaderField:key];
    }];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.protocolClasses = [config.protocolClasses arrayByAddingObject:self.class];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:newRequest];
    [task resume];
}

- (void)stopLoading
{
    [self.task cancel];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    if (response) {
        NSMutableURLRequest *redirectRequest = [newRequest mutableCopy];
        
        // Set custom headers
        [[Castle headers] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL* stop) {
            [redirectRequest setValue:value forHTTPHeaderField:key];
        }];
        
        [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
        
        completionHandler(redirectRequest);
        
    } else {
        completionHandler(newRequest);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveData:(nonnull NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    if (task.response != nil) {
        [self.client URLProtocol:self didReceiveResponse:task.response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    }
    
    [self.client URLProtocolDidFinishLoading:self];
}

@end
