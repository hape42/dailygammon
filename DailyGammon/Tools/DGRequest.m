//
//  DGRequest.m
//  DailyGammon
//
//  Created by Peter Schneider on 18.02.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "DGRequest.h"

@interface DGRequest () <NSURLSessionDataDelegate>

@property (strong) DGRequestCompletionHandler completionHandler;
@property (strong) NSMutableData *responseData;

@end

@implementation DGRequest

- (instancetype)init
{
    // Minimal initializer, working with a default request to Google (for testing only)

    return [self initWithURL:[NSURL URLWithString:@"https://www.google.com"] completionHandler:nil];
}

- (instancetype)initWithString:(NSString *)urlString completionHandler:(DGRequestCompletionHandler)completionHandler
{
    // Convenience initializer, working with a URL string

    return [self initWithURL:[NSURL URLWithString:urlString] completionHandler:completionHandler];
}

- (instancetype)initWithURL:(NSURL *)url completionHandler:(DGRequestCompletionHandler)completionHandler
{
    // Designated initializer; remember the completionHandler, to be called once the reponse has been finished

    if (self = [super init])
    {
        self.completionHandler = completionHandler;

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
        [task resume];
    }
    
    return self;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // First reponse, initialize the data object to hold chunks

//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//    NSLog(@"... Received header from \"%@\" (status: %lu, fields: %@)", httpResponse.URL, httpResponse.statusCode, httpResponse.allHeaderFields);
    self.responseData = [NSMutableData data];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // Repetitive response, add chunk to data property

    [self.responseData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    // Response has been finished, use the completionHandler property to loop back to the caller with results

    if (error)
    {
        NSLog(@"... Ended with error: %@", error);
        self.responseData = nil;
        if (self.completionHandler) self.completionHandler(FALSE, error, nil);
    }
    else
    {
        // Enforce a lossless encoding and prefer UTF-8, 8-bit ISO Latin 1, but try others; toggle flags for testing

//        NSDictionary *encodingOptions = @{
//            NSStringEncodingDetectionAllowLossyKey : @(NO),
//            NSStringEncodingDetectionSuggestedEncodingsKey : @[ @(NSISOLatin1StringEncoding), @(NSUTF8StringEncoding)],
//            NSStringEncodingDetectionUseOnlySuggestedEncodingsKey : @(NO)
//        };
        NSDictionary *encodingOptions = @{
            NSStringEncodingDetectionAllowLossyKey : @(NO),
            NSStringEncodingDetectionSuggestedEncodingsKey : @[ @(NSISOLatin1StringEncoding)],
            NSStringEncodingDetectionUseOnlySuggestedEncodingsKey : @(NO)
        };

        NSString *responseString;
        BOOL usedLossyConverted;

        // Let Foundation determin the stringEncoding, indicating if it was a lossy conversion, refer to "NSString.h" & <https://developer.apple.com/documentation/foundation/nsstringencoding>

        NSStringEncoding stringEncoding = [NSString stringEncodingForData:self.responseData encodingOptions:encodingOptions convertedString:&responseString usedLossyConversion:&usedLossyConverted];
 //       NSLog(@"... Ended sucessfully, result converted to string (length: %lu, encoding: %lu, wasLossyConverted: %i)", self.responseData.length, stringEncoding, usedLossyConverted);
        if (self.completionHandler)
            self.completionHandler(TRUE, nil, responseString);
        
        XLog(@"%lu",(unsigned long)stringEncoding);
    }
}

@end
