//
//  CASAPIClient.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASAPIClient.h"

#import <UIKit/UIKit.h>

#import "Castle.h"
#import "CASUtils.h"
#import "CASEvent.h"

@interface CASAPIClient ()

@property (nonatomic, copy, readonly) NSURL *baseURL;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) CastleConfiguration *configuration;

- (NSURLSessionDataTask *)dataTaskWithPath:(NSString *)path
                                  postData:(NSData *)data
                                completion:(void (^)(id responseObject,  NSURLResponse * __nullable response, NSError * __nullable error))completion;

@end

@implementation CASAPIClient

+ (instancetype)clientWithConfiguration:(CastleConfiguration *)configuration
{
    CASAPIClient *client = [[CASAPIClient alloc] init];
    client.configuration = configuration;
    return client;
}

#pragma mark - CASAPIClient

- (NSURLSessionDataTask *)dataTaskWithPath:(NSString *)path
                                  postData:(NSData *)data
                                completion:(void (^)(id responseObject,  NSURLResponse * __nullable response, NSError * __nullable error))completion
{
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
    
    // Setup request
    NSMutableURLRequest *request = [self requestWithURL:url method:@"POST"];
    
    // Set body
    [request setHTTPBody:data];
    
    // Create data task and fetch data from API
    NSURLSessionDataTask *task =  [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        id responseObject = nil;
        
        // Make sure that the response is a HTTP response before trying to make sense of the data
        if(![response isKindOfClass:NSHTTPURLResponse.class]) {
            if(completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, response, error);
                });
            }
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        
        // Parse response data
        if(data) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSString *contentType = httpResponse.allHeaderFields[@"Content-Type"];
            
            // Check for application/json content-type and parse response
            if(contentType && [contentType containsString:@"application/json"]) {
                NSError *jsonError = nil;
                responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            }
        }
        
        // If the HTTP status code was anything other than 200 OK return a error.
        if(httpResponse.statusCode >= 400) {
            if(completion) {
                if(!error) {
                    error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(responseObject, response, error);
                });
            }
            return;
        }
        
        // Call completion block
        if(completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(responseObject, response, error);
            });
        }
    }];
    
    return task;
}

#pragma mark - Getters

- (NSURLSession *)session
{
    if(!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return _session;
}

- (NSURL *)baseURL
{
    return self.configuration.baseURL;
}

#pragma mark - NSURLRequest

- (NSMutableURLRequest *)requestWithURL:(NSURL *)url method:(NSString *)method {
    // Create request and setup the neccessary headers
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // Set HTTP method
    request.HTTPMethod = method;
    
    // Set custom User Agent
    [request setValue:[Castle userAgent] forHTTPHeaderField:@"User-Agent"];
    
    // Set timeout
    [request setTimeoutInterval:10.0f];
    
    // Authentication
    [request setValue:self.configuration.publishableKey forHTTPHeaderField:@"X-Castle-Publishable-Api-Key"];
    
    return request;
}

@end
