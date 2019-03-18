//
//  iPhoneAbout.m
//  DailyGammon
//
//  Created by Peter on 11.03.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import "iPhoneAbout.h"
#import "Design.h"
#import "iPhoneMenue.h"
#import "AppDelegate.h"


@interface iPhoneAbout ()

@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *creditButton;

@end

@implementation iPhoneAbout

@synthesize buttonEmail;
@synthesize buttonWeb;
@synthesize buttonPrivacy;


@synthesize design;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [[UIImage imageNamed:@"menue.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.moreButton setImage:image forState:UIControlStateNormal];

    self.MRAbout.text = @"System Information for";
    self.MrAboutAppname.text = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
    self.MRAboutAppVersion.text = [NSString stringWithFormat:@"Version %@ Build %@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleVersion"]];
    self.MRAboutBuildInfo.text = [NSString stringWithFormat:@"Build from %@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"DGBuildDate"] ];
    
    self.MRAboutDevice.text = [NSString stringWithFormat:@"Device %@", [self iPhone]];
    self.MRAboutOS.text = [NSString stringWithFormat:@"IOS %@", [[UIDevice currentDevice] systemVersion]];
    
    design = [[Design alloc] init];
    buttonWeb     = [design makeNiceButton:buttonWeb];
    buttonEmail   = [design makeNiceButton:buttonEmail];
    buttonPrivacy = [design makeNiceButton:buttonPrivacy];
    self.creditButton = [design makeNiceButton:self.creditButton];

    if([design isX])
    {
        CGRect frame = self.view.frame;
        frame.size.width -= 30;
        self.view.frame = frame;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (IBAction)actionCredits:(id)sender
{
    NSString *message = @"Jutta Schneider\nHeather123 at DailyGammon\nGraphics & Design\n\nPeter Schneider\nhape42 at DailyGammon\nIdea & Coding";
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
- (IBAction)MRAboutButtonInfo:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.hape42.de"] options:@{} completionHandler:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.presentingPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma mark - Support Email
- (IBAction)MRAboutButtonEmail:(id)sender
{
    if (![MFMailComposeViewController canSendMail])
    {
        XLog(@"Fehler: Mail kann nicht versendet werden");
        return;
    }
    NSString *betreff = [NSString stringWithFormat:@"Support request"];
    
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
    
    text = [NSString stringWithFormat:@"Device <b>%@</b> IOS <b>%@</b><br> ", [self iPhone], [[UIDevice currentDevice] systemVersion]];
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
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"userdefaults.plist"];
    
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.presentingPopoverController dismissPopoverAnimated:YES];
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)moreAction:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    iPhoneMenue *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneMenue"];
    [self.navigationController pushViewController:vc animated:NO];
}
- (NSString *)iPhone
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height)
            {
            case 1136:
                return @"iPhone 5 or 5S or 5C";
                break;
                
            case 1334:
                return @"iPhone 6/6S/7/8";
                break;
                
            case 1920:
            case 2208:
                return @"iPhone 6+/6S+/7+/8+";
                break;
                
            case 2436:
                return @"iPhone X, XS";
                break;
                
            case 2688:
                return @"iPhone XS Max";
                break;
                
            case 1792:
                return @"iPhone XR";
                break;
                
            default:
                return @"Unknown";
                break;
            }
    }
    return @"Unknown";

}
@end
