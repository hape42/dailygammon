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
#import "iphoneTopPageVC.h"
#import "NSDictionary+PercentEncodeURLQueryValue.h"
#import "AppDelegate.h"
#import <SafariServices/SafariServices.h>

@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *usewrnameOutlet;
@property (weak, nonatomic) IBOutlet UITextField *passwordOutlet;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *faqButton;
@property (weak, nonatomic) IBOutlet UIImageView *logo;

@property (readwrite, retain, nonatomic) NSURLConnection *downloadConnection;
@property (weak, nonatomic) UIPopoverController *presentingPopoverController;

@end

@implementation LoginVC

@synthesize design;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    design = [[Design alloc] init];
    
    self.loginButton = [design makeNiceButton:self.loginButton];
    self.createAccountButton = [design makeNiceButton:self.createAccountButton];
    self.faqButton = [design makeNiceButton:self.faqButton];
    
    self.logo.layer.cornerRadius = 14.0f;
    self.logo.layer.masksToBounds = YES;
    [self.usewrnameOutlet setDelegate:self];
    [self.passwordOutlet  setDelegate:self];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
 }

- (BOOL)textFieldShouldReturn:(UITextView *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)loginAction:(id)sender
{
    NSString *userName = self.usewrnameOutlet.text;
    NSString *userPassword = self.passwordOutlet.text;
    
    //https://stackoverflow.com/questions/54741600/how-to-submit-a-password-with-special-characters-from-app-to-a-web-server-by-nsu?noredirect=1#comment96266886_54741600
    NSDictionary *dictionary = @{@"login": userName, @"password": userPassword};
    NSData *body = [dictionary percentEncodedData];
    userPassword = [self percentEscapeString:userPassword];

    NSString *post = [NSString stringWithFormat:@"login=%@&password=%@",userName,userPassword];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
//    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[body length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://dailygammon.com/bg/login"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:body];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
//#warning https://stackoverflow.com/questions/32647138/nsurlconnection-initwithrequest-is-deprecated
    if(conn)
    {
        NSLog(@"Connection Successful");
    }
    else
    {
        NSLog(@"Connection could not be made");
    }
}

- (NSString *)percentEscapeString:(NSString *)string
{
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
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
        if([[cookie value] isEqualToString:@"N/A"])
        {
            XLog(@"login nicht ok");
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Message"
                                         message:@"We cannot validate the user name and password entered"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                        }];
            UIAlertAction* helpButton = [UIAlertAction
                                         actionWithTitle:@"Need help"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                              NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.dailygammon.com/help/index.html#pw"]];
                                              if ([SFSafariViewController class] != nil) {
                                                  SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:URL];
                                                  [self presentViewController:sfvc animated:YES completion:nil];
                                              } else {
                                                  [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
                                              }

                                         }];

            [alert addAction:yesButton];
            [alert addAction:helpButton];

            [self presentViewController:alert animated:YES completion:nil];

        }
        else
        {
            XLog(@"login ok");
            [[NSUserDefaults standardUserDefaults] setValue:self.usewrnameOutlet.text forKey:@"user"];
            [[NSUserDefaults standardUserDefaults] setValue:self.passwordOutlet.text forKey:@"password"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            {
                TopPageVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"TopPageVC"];
                [self.navigationController pushViewController:vc animated:NO];
            }
            else
            {
                iPhoneTopPageVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneTopPageVC"];
                [self.navigationController pushViewController:vc animated:NO];
            }
        }
    }
    NSArray *cookie = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if(cookie.count < 1)
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Message"
                                     message:@"An error has occured processing your login"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Try again"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                    }];
        
        UIAlertAction* helpButton = [UIAlertAction
                                     actionWithTitle:@"Need help"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                          NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.dailygammon.com/help/index.html#pw"]];
                                          if ([SFSafariViewController class] != nil) {
                                              SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:URL];
                                              [self presentViewController:sfvc animated:YES completion:nil];
                                          } else {
                                              [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
                                          }

                                     }];

        [alert addAction:yesButton];
        [alert addAction:helpButton];

        [self presentViewController:alert animated:YES completion:nil];

    }
    XLog(@"%@", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]);
}
- (IBAction)createAccountAction:(id)sender
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/create"]];
    if ([SFSafariViewController class] != nil) {
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:URL];
        [self presentViewController:sfvc animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
    }
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://dailygammon.com/bg/create"] options:@{} completionHandler:nil];
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        [self.presentingPopoverController dismissPopoverAnimated:YES];
//    }
}
- (IBAction)faqAction:(id)sender
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com/help"]];
    if ([SFSafariViewController class] != nil) {
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:URL];
        [self presentViewController:sfvc animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
    }

//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://dailygammon.com/help"] options:@{} completionHandler:nil];
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        [self.presentingPopoverController dismissPopoverAnimated:YES];
//    }
}

#pragma mark - Email
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error)
    {
        XLog(@"Fehler MFMailComposeViewController: %@", error);
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.presentingPopoverController dismissPopoverAnimated:YES];
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end
