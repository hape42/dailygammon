//
//  About.m
//  DailyGammon
//
//  Created by Peter on 10.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "About.h"
#import "Design.h"
#import "TFHpple.h"
#import "PlayMatch.h"
#import "Preferences.h"
#import "Rating.h"
#import "LoginVC.h"
#import "AppDelegate.h"
#import "DbConnect.h"
#import "RatingVC.h"
#import "Player.h"
#import "Tools.h"
#import <SafariServices/SafariServices.h>
#import "DGButton.h"
#import "PlayerLists.h"

@interface About ()<NSURLSessionDataDelegate>

@property (assign, atomic) BOOL loginOk;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet DGButton *creditButton;
@property (weak, nonatomic) IBOutlet UILabel  *infoText;
@property (weak, nonatomic) IBOutlet DGButton *clipBoard;
@property (weak, nonatomic) IBOutlet DGButton *buttonGitHub;
@property (weak, nonatomic) IBOutlet DGButton *buttonReminder;

@property (weak, nonatomic) IBOutlet DGButton *buttonEmail;
@property (weak, nonatomic) IBOutlet DGButton *buttonPrivacy;
@property (weak, nonatomic) IBOutlet UILabel  *appVersion;

@end

@implementation About

@synthesize design, preferences, rating, tools;

@synthesize showRemindMeLaterButton;

@synthesize menueView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    design = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating = [[Rating alloc] init];
    tools = [[Tools alloc] init];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    self.infoText.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;

    NSString *version = @"?";
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    for(NSDictionary *prefSpecification in preferences) 
    {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if([key isEqualToString:@"version_string"])
        {
            version = [prefSpecification objectForKey:@"DefaultValue"];
        }
    }

    self.appVersion.text = [NSString stringWithFormat:@"Version %@ from %@", version, [self getBuildDate]];

    self.infoText.numberOfLines = 0;
    self.infoText.adjustsFontSizeToFitWidth = YES;
    self.infoText.minimumScaleFactor = 0.1;
    self.infoText.lineBreakMode = NSLineBreakByClipping; // <-- MAGIC LINE
    self.infoText.font = [UIFont systemFontOfSize:25.f];
    
    return;

}
#define DATE [NSString stringWithUTF8String:__DATE__]
#define TIME [NSString stringWithUTF8String:__TIME__]
 
- (NSString *)getBuildDate {
    NSString *buildDate;
 
    // Get build date and time, format to 'yyMMddHHmm'
    NSString *dateStr = [NSString stringWithFormat:@"%@ %@", DATE , TIME ];
 
    // Convert to date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"LLL d yyyy HH:mm:ss"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:usLocale];
    NSDate *date = [dateFormat dateFromString:dateStr];
 
    // Set output format and convert to string
    [dateFormat setDateFormat:@"dd. MMMM yyyy HH:mm:ss"];
    buildDate = [dateFormat stringFromDate:date];
 
    return buildDate;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self layoutObjects];
    
    self.appVersion.textColor       = [design getTintColorSchema];
    self.moreButton                = [design designMoreButton:self.moreButton];

//    You are missing a feature?
//    You have found a bug?
//    You have an idea how to implement something better than we have done so far?
//    You have an idea that no one has come up with yet?
//    Then join our team on GitHub and work together with us on the continuous development of the app. Or just send us an email
//
//    You don't have to be good at IOS programming to help. We also need help describing problems. And we also need support in testing new versions.
//
//    Did we make you curious?
}

- (IBAction)copyInfoToClipBoard:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.appVersion.text];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.loginOk = NO;
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    // we need the login so that the TopPageButton for the iPad can show the number of open games
    NSString *userName     = [[NSUserDefaults standardUserDefaults] stringForKey:@"user"];
    NSString *userPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

    NSString *post               = [NSString stringWithFormat:@"login=%@&password=%@",userName,userPassword];
    NSData *postData             = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength         = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://dailygammon.com/bg/login"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];

}
#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if(self.loginOk)
    {
    }
    else
    {
        self.loginOk = YES;
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    if (error)
    {
        XLog(@"Connection didFailWithError %@", error.localizedDescription);
        return;
    }

    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        if([[cookie name] isEqualToString:@"USERID"])
            [[NSUserDefaults standardUserDefaults] setValue:[cookie value] forKey:@"USERID"];

        [[NSUserDefaults standardUserDefaults] synchronize];
        if([[cookie value] isEqualToString:@"N/A"])
        {
            LoginVC *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
            [self.navigationController pushViewController:vc animated:NO];
        }
    }
    XLog(@"cookie %ld",[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies].count);
    if([[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies].count < 1)
    {
        LoginVC *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)actionCredits:(id)sender
{
    NSString *message = @"\n\nMany thanks to Jordan Lampe and team, imagineers, creators and maintainers of the DailyGammon.com site.\n\n";
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Credits"
                                 message:message
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

- (IBAction)actionPrivacy:(id)sender
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Privacy Policy"
                                 message:@"This application does not process, store, or transmit personal data. "
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
- (IBAction)MRAboutButtonInfo:(id)sender
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/hape42/dailygammon"]];
    if ([SFSafariViewController class] != nil) {
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:URL];
        [self presentViewController:sfvc animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
    }

}
- (IBAction)reminder:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"AboutCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *message = @"\n\nThis view of the app is automatically displayed again after 5 launches of the app.\n\n";
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Information"
                                 message:message
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

#pragma mark - Support Email
- (IBAction)MRAboutButtonEmail:(id)sender
{
    if (![MFMailComposeViewController canSendMail])
    {
        UIAlertController * alert = [UIAlertController
                                      alertControllerWithTitle:@"Problem found"
                                      message:@"Normally the email is sent with Apple Mail. There seems to be a problem with Apple Mail. Please select your email program and send the email to DG@hape42.de"
                                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* cancelButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction * action)
                                    {
                                        return;
                                    }];

        [alert addAction:cancelButton];
        [self presentViewController:alert animated:YES completion:nil];
        XLog(@"Fehler: Mail kann nicht versendet werden");
        return;
    }
    NSString *betreff = [NSString stringWithFormat:@"Support request"];
    
    NSString *text = @"";
    NSString *emailText = @"";
    text = [NSString stringWithFormat:@"Hallo Support-Team of the %@ App for %@, <br><br> ", [[UIDevice currentDevice] model],[[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
    emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
    
    text = [NSString stringWithFormat:@"my Data: <br> "];
    emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
    
    text = [NSString stringWithFormat:@"App <b>%@</b> <br> ", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
    emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
    
    NSString *version = @"?";
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    for(NSDictionary *prefSpecification in preferences)
    {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if([key isEqualToString:@"version_string"])
        {
            version = [prefSpecification objectForKey:@"DefaultValue"];
        }
    }

    text = [NSString stringWithFormat:@"Version %@ ", version];
    emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
    
    text = [NSString stringWithFormat:@"Build from <b>%@</b> <br> ", [self getBuildDate] ];
    
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
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"rating.sqlite"];
    
    NSData *myData = [NSData dataWithContentsOfFile:dbPath];
    
    [emailController addAttachmentData:myData mimeType:@"image/sqlite" fileName:@"rating.sqlite"];
//    myData = [NSData dataWithContentsOfFile:plistPath];
//    [emailController addAttachmentData:myData mimeType:@"image/plist" fileName:@"userdefaults.plist"];

    [self presentViewController:emailController animated:YES completion:NULL];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error)
    {
        XLog(@"Fehler MFMailComposeViewController: %@", error);
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - autoLayout
-(void)layoutObjects
{
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 10.0;
    float buttonHeight = 35;
    
#pragma mark moreButton autoLayout
    [self.moreButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.moreButton.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.moreButton.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.moreButton.widthAnchor constraintEqualToConstant:40].active = YES;
    [self.moreButton.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

#pragma mark appVersion autoLayout
    [self.appVersion setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.appVersion.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.appVersion.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.appVersion.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.appVersion.rightAnchor constraintEqualToAnchor:self.moreButton.leftAnchor constant:-edge].active = YES;

#pragma mark clipBoard Button  autoLayout
    [self.clipBoard setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.clipBoard.topAnchor constraintEqualToAnchor:self.appVersion.bottomAnchor constant:edge].active = YES;
    [self.clipBoard.heightAnchor constraintEqualToConstant:40].active = YES;
//    [self.clipBoard.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
//    [self.clipBoard.rightAnchor constraintEqualToAnchor:self.moreButton.leftAnchor constant:-edge].active = YES;
    [self.clipBoard.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor constant:0].active = YES;

#pragma mark email Button  autoLayout
    [self.buttonEmail setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.buttonEmail.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-edge*2].active = YES;
    [self.buttonEmail.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.buttonEmail.heightAnchor constraintEqualToConstant:buttonHeight].active = YES;
    
#pragma mark privacy Button  autoLayout
    [self.buttonPrivacy setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.buttonPrivacy.bottomAnchor constraintEqualToAnchor:self.buttonEmail.bottomAnchor constant:0].active = YES;
    [self.buttonPrivacy.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.buttonPrivacy.heightAnchor constraintEqualToConstant:buttonHeight].active = YES;

#pragma mark credit Button  autoLayout
    [self.creditButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.creditButton.bottomAnchor constraintEqualToAnchor:self.buttonEmail.bottomAnchor constant:0].active = YES;
    [self.creditButton.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor constant:0].active = YES;
    [self.creditButton.heightAnchor constraintEqualToConstant:buttonHeight].active = YES;

#pragma mark gitHub Button  autoLayout
    [self.buttonGitHub setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.buttonGitHub.bottomAnchor constraintEqualToAnchor:self.buttonEmail.topAnchor constant:-edge].active = YES;
    [self.buttonGitHub.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.buttonGitHub.heightAnchor constraintEqualToConstant:buttonHeight].active = YES;

#pragma mark reminder Button  autoLayout
    [self.buttonReminder setTranslatesAutoresizingMaskIntoConstraints:NO];

    showRemindMeLaterButton = YES;
    if(showRemindMeLaterButton)
    {
        [self.buttonReminder setTranslatesAutoresizingMaskIntoConstraints:NO];

        [self.buttonReminder.bottomAnchor constraintEqualToAnchor:self.buttonEmail.topAnchor constant:-edge].active = YES;
        [self.buttonReminder.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
        [self.buttonReminder.heightAnchor constraintEqualToConstant:buttonHeight].active = YES;
    }
    else
    {
        [self.buttonReminder.leftAnchor constraintEqualToAnchor:safe.rightAnchor constant:99].active = YES;
    }

#pragma mark infoText  autoLayout
    [self.infoText setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.infoText.topAnchor constraintEqualToAnchor:self.clipBoard.bottomAnchor constant:edge].active = YES;
    [self.infoText.bottomAnchor constraintEqualToAnchor:self.buttonGitHub.topAnchor constant:-edge].active = YES;
    [self.infoText.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.infoText.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

}
#pragma mark -  menue
- (IBAction)moreAction:(id)sender
{
    if(!menueView)
    {
        menueView = [[MenueView alloc]init];
        menueView.navigationController = self.navigationController;
    }
    [menueView showMenueInView:self.view];
}

@end
