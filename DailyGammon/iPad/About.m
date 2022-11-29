//
//  About.m
//  DailyGammon
//
//  Created by Peter on 10.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "About.h"
#import "Design.h"
#import <SafariServices/SafariServices.h>

@interface About ()

@end

@implementation About

@synthesize buttonEmail;
@synthesize buttonWeb;
@synthesize buttonPrivacy;


@synthesize design;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.MRAbout.text = @"System Information for";
    self.MrAboutAppname.text = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
    self.MRAboutAppVersion.text = [NSString stringWithFormat:@"Version %@ Build %@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleVersion"]];
    self.MRAboutBuildInfo.text = [NSString stringWithFormat:@"Build from %@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"DGBuildDate"] ];
    
    self.MRAboutDevice.text = [NSString stringWithFormat:@"Device %@", [[UIDevice currentDevice] model]];
    self.MRAboutOS.text = [NSString stringWithFormat:@"IOS %@", [[UIDevice currentDevice] systemVersion]];
    
    design = [[Design alloc] init];
    buttonWeb     = [design makeNiceButton:buttonWeb];
    buttonEmail   = [design makeNiceButton:buttonEmail];
    buttonPrivacy = [design makeNiceButton:buttonPrivacy];

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
- (IBAction)MRAboutButtonInfo:(id)sender
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.hape42.de"]];
    if ([SFSafariViewController class] != nil) {
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:URL];
        [self presentViewController:sfvc animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
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
    text = [NSString stringWithFormat:@"Hallo Support-Team of the %@ App for %@, <br><br> ", [[UIDevice currentDevice] model],[[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
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
    /* kha: haven't found any difference in the behavior of the about box
     * that this deprecated code makes. So I'm boldly commenting it out.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.presentingPopoverController dismissPopoverAnimated:YES];
    }
    */
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end
