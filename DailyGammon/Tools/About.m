//
//  About.m
//  DailyGammon
//
//  Created by Peter on 10.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "About.h"
#import "Design.h"
@interface About ()

@end

@implementation About

@synthesize buttonEmail;
@synthesize buttonWeb;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.MRAbout.text = @"System Information for";
    self.MrAboutAppname.text = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
    self.MRAboutAppVersion.text = [NSString stringWithFormat:@"Version %@ Build %@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleVersion"]];
    self.MRAboutBuildInfo.text = [NSString stringWithFormat:@"Build from %@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"DGBuildDate"] ];
    
    self.MRAboutDevice.text = [NSString stringWithFormat:@"Device %@", [[UIDevice currentDevice] model]];
    self.MRAboutOS.text = [NSString stringWithFormat:@"IOS %@", [[UIDevice currentDevice] systemVersion]];
    
    [buttonWeb setTitleColor:HEADERBACKGROUNDCOLOR forState:UIControlStateNormal];
    
    [buttonEmail setTitleColor:HEADERBACKGROUNDCOLOR forState:UIControlStateNormal];
    [buttonEmail setTitle:@"Email to Support" forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (IBAction)MRAboutButtonEmail:(id)sender {
    
    
    if (![MFMailComposeViewController canSendMail])
    {
        XLog(@"Fehler: Mail kann nicht versendet werden");
        return;
    }
    NSString *betreff = [NSString stringWithFormat:@"Supportanfrage"];
    
    NSString *text = @"";
    NSString *emailText = @"";
    text = [NSString stringWithFormat:@"Hallo Support-Team von %@, <br><br> ", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
    emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
    
    text = [NSString stringWithFormat:@"meine Daten: <br> "];
    emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
    
    text = [NSString stringWithFormat:@"App <b>%@</b> <br> ", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
    emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
    
    text = [NSString stringWithFormat:@"Version <b>%@</b> <br> ", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleVersion"]];
    emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
    
    text = [NSString stringWithFormat:@"Build vom <b>%@</b> <br> ", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"SMbuildDate"] ];
    
    emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
    
    text = self.SMAboutChartCount.text;
    emailText = [NSString stringWithFormat:@"<br> %@%@<br> ", emailText, text];
    
    emailText = [NSString stringWithFormat:@"<br> %@%@<br> ", emailText, self.SMAboutChartSize.text];
    
    text = [NSString stringWithFormat:@"Device <b>%@</b> IOS <b>%@</b><br> ", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]];
    emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
    
    text = [NSString stringWithFormat:@"<br>Ich habe folgenden Fehler entdeckt bzw. habe folgende Frage:<br> "];
    emailText = [NSString stringWithFormat:@"%@%@", emailText, text];
    
    MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
    NSArray *toStrickmuster = [NSArray arrayWithObjects:@"mail@j-s-designs.de",nil];
    
    
    [emailController setToRecipients:toStrickmuster];
    [emailController setSubject:betreff];
    [emailController setMessageBody:emailText isHTML:YES];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"SM.sqlite"];
    
    NSData *myData = [NSData dataWithContentsOfFile:dbPath];
    
    [emailController addAttachmentData:myData mimeType:@"image/sqlite" fileName:@"SM.sqlite"];
    
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

@end
