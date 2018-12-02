//
//  Login.m
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "LoginVC.h"
#import "Design.h"
#import "TopPageVC.h"

@interface LoginVC ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (readwrite, retain, nonatomic) NSURLConnection *downloadConnection;

@end

@implementation LoginVC

@synthesize design;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = VIEWBACKGROUNDCOLOR;
    design = [[Design alloc] init];

    [self.view addSubview:[self makeHeader]];
    
    self.loginButton = [design makeNiceButton:self.loginButton];



}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    
}
- (IBAction)loginAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *userName = @"hape42";
    NSString *userPassword = @"00450045";
    
    //    https://stackoverflow.com/questions/15749486/sending-an-http-post-request-on-ios
    NSString *post = [NSString stringWithFormat:@"login=%@&password=%@",userName,userPassword];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://dailygammon.com/bg/login"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
#warning https://stackoverflow.com/questions/32647138/nsurlconnection-initwithrequest-is-deprecated
    if(conn)
    {
        NSLog(@"Connection Successful");
    } else
    {
        NSLog(@"Connection could not be made");
    }
    
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    NSDictionary *fields = [HTTPResponse allHeaderFields];
    NSString *cookie = [fields valueForKey:@"Set-Cookie"];
    XLog(@"Connection begonnen %@", cookie);

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    XLog(@"Connection didReceiveData");
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    XLog(@"Connection didFailWithError");
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    XLog(@"Connection Finished");
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        NSLog(@"name: '%@'\n",   [cookie name]);
        NSLog(@"value: '%@'\n",  [cookie value]);
        NSLog(@"domain: '%@'\n", [cookie domain]);
        NSLog(@"path: '%@'\n",   [cookie path]);
    }

}

#include "HeaderInclude.h"

@end
