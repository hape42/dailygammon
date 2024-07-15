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
#import "PlayerVC.h"
#import "Tools.h"
#import <SafariServices/SafariServices.h>
#import "DGButton.h"
#import "PlayerLists.h"
#import "Ratings+CoreDataProperties.h"

@interface About ()<NSURLSessionDataDelegate>

@property (assign, atomic) BOOL loginOk;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet DGButton *creditButton;
@property (weak, nonatomic) IBOutlet UILabel *buildDate;

@property (weak, nonatomic) IBOutlet DGButton *buttonEmail;
@property (weak, nonatomic) IBOutlet DGButton *buttonPrivacy;
@property (weak, nonatomic) IBOutlet UILabel  *appVersion;

@property (weak, nonatomic) IBOutlet UILabel *dgText;
@property (weak, nonatomic) IBOutlet DGButton *dgButton;
@property (weak, nonatomic) IBOutlet UILabel *helpText;
@property (weak, nonatomic) IBOutlet DGButton *helpButton;

@end

@implementation About

@synthesize design, preferences, rating, tools;
@synthesize containerView, webView, closeButton, buttonReminder, buttonGitHub;

@synthesize showRemindMeLaterButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    design = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating = [[Rating alloc] init];
    tools = [[Tools alloc] init];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;

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

    self.appVersion.text = [NSString stringWithFormat:@"Version %@", version];
    self.buildDate.text = [NSString stringWithFormat:@"from %@", [self getBuildDate]];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.moreButton.menu = [app mainMenu:self.navigationController button:self.moreButton];
    self.moreButton.showsMenuAsPrimaryAction = YES;

    [self makeCSV];
}
#define DATE [NSString stringWithUTF8String:__DATE__]
#define TIME [NSString stringWithUTF8String:__TIME__]
 
- (NSString *)getBuildDate 
{
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
    
    self.appVersion.textColor = [design getTintColorSchema];
    self.buildDate.textColor  = [design getTintColorSchema];

    self.moreButton           = [design designMoreButton:self.moreButton];

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
//    XLog(@"cookie %ld",[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies].count);
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
    myData = [NSData dataWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:@"ratings.csv"]];
    [emailController addAttachmentData:myData mimeType:@"image/plist" fileName:@"rating.csv"];

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

#pragma mark appVersion & buildDate autoLayout
    [self.appVersion setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.appVersion.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.appVersion.heightAnchor constraintEqualToConstant:30].active = YES;
    [self.appVersion.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.appVersion.rightAnchor constraintEqualToAnchor:self.moreButton.leftAnchor constant:-edge].active = YES;

    [self.buildDate setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.buildDate.topAnchor constraintEqualToAnchor:self.appVersion.bottomAnchor constant:0].active = YES;
    [self.buildDate.heightAnchor constraintEqualToConstant:30].active = YES;
    [self.buildDate.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.buildDate.rightAnchor constraintEqualToAnchor:self.moreButton.leftAnchor constant:-edge].active = YES;

#pragma mark explain dg autoLayout

    [self.dgText setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.dgButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.dgText.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.dgText.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.dgText.heightAnchor constraintEqualToConstant:30].active = YES;
    [self.dgText.centerYAnchor constraintEqualToAnchor:safe.centerYAnchor constant:-80.0].active = YES;

    [self.dgButton.widthAnchor constraintEqualToConstant:150].active = YES;
    [self.dgButton.heightAnchor constraintEqualToConstant:30].active = YES;
    [self.dgButton.topAnchor constraintEqualToAnchor:self.dgText.bottomAnchor constant:edge].active = YES;
    [self.dgButton.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor].active = YES;

#pragma mark helpText helpButton autoLayout

    [self.helpText setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.helpButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.helpText.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.helpText.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.helpText.heightAnchor constraintEqualToConstant:30].active = YES;
    [self.helpText.centerYAnchor constraintEqualToAnchor:safe.centerYAnchor constant:10.0].active = YES;

    [self.helpButton.widthAnchor constraintEqualToConstant:150].active = YES;
    [self.helpButton.heightAnchor constraintEqualToConstant:30].active = YES;
    [self.helpButton.topAnchor constraintEqualToAnchor:self.helpText.bottomAnchor constant:edge].active = YES;
    [self.helpButton.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor].active = YES;

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



}

-(void)makeCSV
{
        
   // NSMutableString *csvString = [@"Match, Event,Length,Opponent,Url,PR Player,PR opponent\n" mutableCopy];

    NSMutableString *csvString = [@"" mutableCopy];

    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ratings" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateRating" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    // Fetch the records and handle an error
    NSError *error;
    
    NSMutableArray * csvArray = [[context executeFetchRequest:request error:&error] mutableCopy];

    for(Ratings *rating in csvArray)
    {
        [csvString appendFormat:@"%@,%5.2f,%@\n",
         rating.dateRating,
         rating.rating,
        rating.user];
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSURL *url = [[NSURL fileURLWithPath:documentsDirectory] URLByAppendingPathComponent:@"ratings.csv"];
    BOOL success = [csvString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!success) {
        NSLog(@"oh no! - %@",error.localizedDescription);
    }
}
#pragma mark - webView explain dailyGammon
- (IBAction)dgAction:(id)sender
{

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 5.0;
    float gap = 5.0;

    containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DG" ofType:@"html"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    [webView loadRequest:request];

    closeButton = [[DGButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 70, 10, 60, 30)];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeWebView) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:containerView];
    [containerView addSubview:webView];
    [containerView addSubview:closeButton];
    
    containerView.backgroundColor = [UIColor colorNamed:@"ColorPlayerChat"];
    webView.backgroundColor = [UIColor colorNamed:@"ColorPlayerChat"];
    
#pragma mark closeButton & webView autoLayout
    
    [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [containerView.topAnchor constraintEqualToAnchor:self.buildDate.bottomAnchor constant:gap].active = YES;
    [containerView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-edge].active = YES;
    [containerView.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [containerView.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

    [closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [closeButton.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:edge].active = YES;
    [closeButton.heightAnchor constraintEqualToConstant:25].active = YES;
    [closeButton.widthAnchor constraintEqualToConstant:60].active = YES;
    [closeButton.rightAnchor constraintEqualToAnchor:self.containerView.rightAnchor constant:-edge].active = YES;
    
    [webView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [webView.topAnchor constraintEqualToAnchor:closeButton.bottomAnchor constant:gap].active = YES;
    [webView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-edge].active = YES;
    [webView.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [webView.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

}
- (void)closeWebView
{
    [containerView removeFromSuperview];
    containerView = nil;

    [webView removeFromSuperview];
    webView = nil;
    [closeButton removeFromSuperview];
    closeButton = nil;
}

#pragma mark - webView explain dailyGammon
- (IBAction)gitHubAction:(id)sender
{

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 5.0;
    float gap = 5.0;
    float buttonHeight = 35;

    containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"GitHub" ofType:@"html"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    [webView loadRequest:request];

    closeButton = [[DGButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 70, 10, 60, 30)];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeWebView) forControlEvents:UIControlEventTouchUpInside];
    
    buttonReminder = [[DGButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 70, 10, 150, 30)];
    [buttonReminder setTitle:@"Remind me later" forState:UIControlStateNormal];
    [buttonReminder addTarget:self action:@selector(reminder:) forControlEvents:UIControlEventTouchUpInside];

    buttonGitHub = [[DGButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 70, 30, 300, 30)];
    [buttonGitHub setTitle:@"  Project on GitHub" forState:UIControlStateNormal];
    [buttonGitHub setImage:[UIImage imageNamed:@"GitHub-Mark-32px"] forState:UIControlStateNormal];
    [buttonGitHub addTarget:self action:@selector(gitHubAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:containerView];
    [containerView addSubview:webView];
    [containerView addSubview:closeButton];
    [containerView addSubview:buttonReminder];
    [containerView addSubview:buttonGitHub];

    containerView.backgroundColor = [UIColor colorNamed:@"ColorPlayerChat"];
    webView.backgroundColor = [UIColor colorNamed:@"ColorPlayerChat"];
    
#pragma mark autoLayout
    
    [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [containerView.topAnchor constraintEqualToAnchor:self.buildDate.bottomAnchor constant:gap].active = YES;
    [containerView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-edge].active = YES;
    [containerView.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [containerView.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

    [closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [closeButton.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:edge].active = YES;
    [closeButton.heightAnchor constraintEqualToConstant:25].active = YES;
    [closeButton.widthAnchor constraintEqualToConstant:60].active = YES;
    [closeButton.rightAnchor constraintEqualToAnchor:self.containerView.rightAnchor constant:-edge].active = YES;
    
#pragma mark gitHub Button  autoLayout
    [self.buttonGitHub setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.buttonGitHub.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-edge].active = YES;
    [self.buttonGitHub.leftAnchor constraintEqualToAnchor:containerView.leftAnchor constant:edge].active = YES;
    [self.buttonGitHub.heightAnchor constraintEqualToConstant:buttonHeight].active = YES;

#pragma mark reminder Button  autoLayout
    [self.buttonReminder setTranslatesAutoresizingMaskIntoConstraints:NO];

    showRemindMeLaterButton = YES;
    if(showRemindMeLaterButton)
    {
        [self.buttonReminder setTranslatesAutoresizingMaskIntoConstraints:NO];

        [self.buttonReminder.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-edge].active = YES;
        [self.buttonReminder.rightAnchor constraintEqualToAnchor:containerView.rightAnchor constant:-edge].active = YES;
        [self.buttonReminder.heightAnchor constraintEqualToConstant:buttonHeight].active = YES;
    }
    else
    {
        [self.buttonReminder.leftAnchor constraintEqualToAnchor:safe.rightAnchor constant:99].active = YES;
    }

    [webView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [webView.topAnchor constraintEqualToAnchor:closeButton.bottomAnchor constant:gap].active = YES;
    [webView.bottomAnchor constraintEqualToAnchor:buttonGitHub.topAnchor constant:-edge].active = YES;
    [webView.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [webView.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;


}

@end
