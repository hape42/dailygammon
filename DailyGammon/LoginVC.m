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
#import "NSDictionary+PercentEncodeURLQueryValue.h"

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

    self.view.backgroundColor = VIEWBACKGROUNDCOLOR;
    design = [[Design alloc] init];
    
    self.loginButton = [design makeNiceButton:self.loginButton];
    self.createAccountButton = [design makeNiceButton:self.createAccountButton];
    self.faqButton = [design makeNiceButton:self.faqButton];
    
    self.logo.layer.cornerRadius = 14.0f;
    self.logo.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
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
            [alert addAction:yesButton];
            
            [self presentViewController:alert animated:YES completion:nil];

        }
        else
        {
            XLog(@"login ok");
            [[NSUserDefaults standardUserDefaults] setValue:self.usewrnameOutlet.text forKey:@"user"];
            [[NSUserDefaults standardUserDefaults] setValue:self.passwordOutlet.text forKey:@"password"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            TopPageVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TopPageVC"];
            [self.navigationController pushViewController:vc animated:NO];
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
        
        UIAlertAction* mailButton = [UIAlertAction
                                     actionWithTitle:@"Mail to Support"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         if (![MFMailComposeViewController canSendMail])
                                         {
                                             XLog(@"Fehler: Mail kann nicht versendet werden");
                                             return;
                                         }
                                         NSString *betreff = [NSString stringWithFormat:@"An error has occured processing your login"];
                                         
                                         NSString *text = @"";
                                         NSString *emailText = @"";
                                         text = [NSString stringWithFormat:@"Hallo Support-Team of %@, <br><br> ", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
                                         emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
                                         
                                         text = [NSString stringWithFormat:@"my Data: <br> "];
                                         emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
                                         
                                         text = [NSString stringWithFormat:@"App <b>%@</b> <br> ", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
                                         emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
                                         
                                         text = [NSString stringWithFormat:@"Version %@ Build %@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleVersion"]];
                                         emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
                                         
                                         text = [NSString stringWithFormat:@"Build from <b>%@</b> <br> ", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"DGBuildDate"] ];
                                         
                                         emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
                                         
                                         text = [NSString stringWithFormat:@"Device <b>%@</b> IOS <b>%@</b><br> ", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]];
                                         emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
                                         
                                         text = [NSString stringWithFormat:@"<br> <br>my Name on DailyGammon <b>%@</b><br><br>",[[NSUserDefaults standardUserDefaults] valueForKey:@"user"]];
                                         emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
                                         
                                         
                                         MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
                                         emailController.mailComposeDelegate = self;
                                         NSArray *toSupport = [NSArray arrayWithObjects:@"dg@hape42.de",nil];
                                         
                                         [emailController setToRecipients:toSupport];
                                         [emailController setSubject:betreff];
                                         [emailController setMessageBody:emailText isHTML:YES];
                                         
                                         [self presentViewController:emailController animated:YES completion:NULL];
                                         
                                     }];

        [alert addAction:yesButton];
        [alert addAction:mailButton];

        [self presentViewController:alert animated:YES completion:nil];

    }
    XLog(@"%@", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]);
}
- (IBAction)createAccountAction:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://dailygammon.com/bg/create"] options:@{} completionHandler:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.presentingPopoverController dismissPopoverAnimated:YES];
    }
}
- (IBAction)faqAction:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://dailygammon.com/help"] options:@{} completionHandler:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.presentingPopoverController dismissPopoverAnimated:YES];
    }
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
