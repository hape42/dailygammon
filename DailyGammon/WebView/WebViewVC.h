//
//  Help.h
//  DailyGammon
//
//  Created by Peter Schneider on 02.07.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class Design;

NS_ASSUME_NONNULL_BEGIN

@interface WebViewVC : UIViewController

@property (strong, readwrite, retain, atomic) Design *design;

@property (strong, readwrite, retain, atomic) NSURL *url;

@property (strong, readwrite, retain, atomic) WKWebView *webView;

@end

NS_ASSUME_NONNULL_END
