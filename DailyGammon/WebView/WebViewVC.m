//
//  Help.m
//  DailyGammon
//
//  Created by Peter Schneider on 02.07.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import "WebViewVC.h"
#import "AppDelegate.h"
#import "Design.h"

@interface WebViewVC ()

@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@end

@implementation WebViewVC

@synthesize design;
@synthesize webView;
@synthesize url;

- (void)viewDidLoad
{
    [super viewDidLoad];

    design = [[Design alloc] init];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.moreButton.menu = [app mainMenu:self.navigationController button:self.moreButton];
    self.moreButton.showsMenuAsPrimaryAction = YES;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.moreButton = [design designMoreButton:self.moreButton];
    
    [self layoutObjects];
 
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSHTTPCookie *userIDCookie = [NSHTTPCookie cookieWithProperties:@{
        NSHTTPCookieDomain: @"dailygammon.com",
        NSHTTPCookiePath: @"/",
        NSHTTPCookieName: @"USERID",
        NSHTTPCookieValue: @"your_user_id"
    }];

    NSHTTPCookie *passwordCookie = [NSHTTPCookie cookieWithProperties:@{
        NSHTTPCookieDomain: @"dailygammon.com",
        NSHTTPCookiePath: @"/",
        NSHTTPCookieName: @"PASSWORD",
        NSHTTPCookieValue: @"your_password"
    }];

    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        if([[cookie name] isEqualToString:@"USERID"])
        {
            userIDCookie = cookie;
        }
        if([[cookie name] isEqualToString:@"PASSWORD"])
        {
            passwordCookie = cookie;
        }

    }

    __weak WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
    [cookieStore setCookie:userIDCookie completionHandler:^{
        [cookieStore setCookie:passwordCookie completionHandler:^{
            // Lade die Anfrage im Webview, nachdem beide Cookies gesetzt wurden
            [self->webView loadRequest:request];
        }];
    }];

}

#pragma mark - autoLayout
-(void)layoutObjects
{
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 5.0;
    float gap = 5;

#pragma mark moreButton autoLayout
    [self.moreButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.moreButton.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.moreButton.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.moreButton.widthAnchor constraintEqualToConstant:40].active = YES;
    [self.moreButton.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;


#pragma mark helpView autoLayout
    webView = [[WKWebView alloc] initWithFrame:CGRectMake(10, 50, self.view.bounds.size.width - 20,  self.view.bounds.size.height - 110)];
    [self.view addSubview:webView];

    [webView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [webView.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [webView.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [webView.topAnchor constraintEqualToAnchor:self.moreButton.bottomAnchor constant:gap].active = YES;
    [webView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-edge].active = YES;


}

@end
