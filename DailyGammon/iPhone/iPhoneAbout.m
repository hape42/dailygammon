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
#import <SafariServices/SafariServices.h>
#import <sys/sysctl.h>

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
    
    self.MRAboutDevice.text = [NSString stringWithFormat:@"Device %@ ", [self iPhone]];
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
- (IBAction)MRAboutButtonInfo:(id)sender
{

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.hape42.de"]];
    if ([SFSafariViewController class] != nil) {
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:URL];
        [self presentViewController:sfvc animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
    }

//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.hape42.de"] options:@{} completionHandler:nil];
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        [self.presentingPopoverController dismissPopoverAnimated:YES];
//    }
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
                return @"iPhone";
                break;
            }
    }
    return @"Unknown";

}

- (NSString *) userDeviceName {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    free(machine);

    //iPhone
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7 (GSM)";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus (GSM)";
    if ([platform isEqualToString:@"iPhone10,1"])   return @"iPhone 8 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone10,4"])   return @"iPhone 8 (GSM)";
    if ([platform isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus (GSM)";
    if ([platform isEqualToString:@"iPhone10,3"])   return @"iPhone X (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone10,6"])   return @"iPhone X (GSM)";
    if ([platform isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([platform isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([platform isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([platform isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    if ([platform isEqualToString:@"iPhone12,8"])   return @"iPhone SE (2nd generation)";
    if ([platform isEqualToString:@"iPhone13,1"])   return @"iPhone 12 mini";
    if ([platform isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
    if ([platform isEqualToString:@"iPhone13,3"])   return @"iPhone 12 Pro";
    if ([platform isEqualToString:@"iPhone13,4"])   return @"iPhone 12 Pro Max";
    if ([platform isEqualToString:@"iPhone14,4"])   return @"iPhone 13 mini";
    if ([platform isEqualToString:@"iPhone14,5"])   return @"iPhone 13";
    if ([platform isEqualToString:@"iPhone14,2"])   return @"iPhone 13 Pro";
    if ([platform isEqualToString:@"iPhone14,3"])   return @"iPhone 13 Pro Max";

    //iPod Touch
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch (6th generation)";
    if ([platform isEqualToString:@"iPod9,1"])      return @"iPod Touch (7th generation) (2019)";

    //iPad
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad (4th generation) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad (4th generation) (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad (4th generation) (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad6,11"])     return @"iPad (5th generation) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad6,12"])     return @"iPad (5th generation) (Cellular)";
    if ([platform isEqualToString:@"iPad7,5"])      return @"iPad (6th generation) (2018) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad7,6"])      return @"iPad (6th generation) (2018) (Cellular)";
    if ([platform isEqualToString:@"iPad7,11"])     return @"iPad (7th generation) (2019) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad7,12"])     return @"iPad (7th generation) (2019) (Cellular)";
    if ([platform isEqualToString:@"iPad11,6"])     return @"iPad (8th generation) (2020) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad11,7"])     return @"iPad (8th generation) (2020) (Cellular)";
    if ([platform isEqualToString:@"iPad12,1"])     return @"iPad (9th generation) (2021) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad12,2"])     return @"iPad (9th generation) (2021) (Cellular)";

    //iPad Air
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (Wi-Fi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air (China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (Wi-Fi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"iPad11,3"])     return @"iPad Air (3rd generation) (2019) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad11,4"])     return @"iPad Air (3rd generation) (2019) (Cellular)";
    if ([platform isEqualToString:@"iPad13,1"])     return @"iPad Air (4th generation) (2020) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad13,2"])     return @"iPad Air (4th generation) (2020) (Cellular)";

    //iPad Pro
    if ([platform isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7\" (Wi-Fi)";
    if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7\" (Cellular)";
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9\" (Wi-Fi)";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9\" (Cellular)";
    if ([platform isEqualToString:@"iPad7,1"])      return @"iPad Pro 12.9\" (2nd generation) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad7,2"])      return @"iPad Pro 12.9\" (2nd generation) (Cellular)";
    if ([platform isEqualToString:@"iPad7,3"])      return @"iPad Pro 10.5\" (Wi-Fi)";
    if ([platform isEqualToString:@"iPad7,4"])      return @"iPad Pro 10.5\" (Cellular)";
    if ([platform isEqualToString:@"iPad8,1"])      return @"iPad Pro 11\" (2018) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad8,2"])      return @"iPad Pro 11\" (2018) (Wi-Fi, 1TB)";
    if ([platform isEqualToString:@"iPad8,3"])      return @"iPad Pro 11\" (2018) (Cellular)";
    if ([platform isEqualToString:@"iPad8,4"])      return @"iPad Pro 11\" (2018) (Cellular, 1Tb)";
    if ([platform isEqualToString:@"iPad8,5"])      return @"iPad Pro 12.9\" (3rd generation) (2018) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad8,6"])      return @"iPad Pro 12.9\" (3rd generation) (2018) (Wi-Fi, 1TB)";
    if ([platform isEqualToString:@"iPad8,7"])      return @"iPad Pro 12.9\" (3rd generation) (2018) (Cellular)";
    if ([platform isEqualToString:@"iPad8,8"])      return @"iPad Pro 12.9\" (3rd generation) (2018) (Cellular, 1TB)";
    if ([platform isEqualToString:@"iPad8,9"])      return @"iPad Pro 11\" (2nd generation) (2020) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad8,10"])     return @"iPad Pro 11\" (2nd generation) (2020) (Cellular)";
    if ([platform isEqualToString:@"iPad8,11"])     return @"iPad Pro 12.9\" (4th generation) (2020) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad8,12"])     return @"iPad Pro 12.9\" (4th generation) (2020) (Cellular)";
    if ([platform isEqualToString:@"iPad13,4"])     return @"iPad Pro 11\" (3nd generation) (2021) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad13,5"])     return @"iPad Pro 11\" (3nd generation) (2021) (Cellular US)";
    if ([platform isEqualToString:@"iPad13,6"])     return @"iPad Pro 11\" (3nd generation) (2021) (Cellular Global)";
    if ([platform isEqualToString:@"iPad13,7"])     return @"iPad Pro 11\" (3nd generation) (2021) (Cellular China)";
    if ([platform isEqualToString:@"iPad13,8"])     return @"iPad Pro 12.9\" (5th generation) (2021) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad13,9"])     return @"iPad Pro 12.9\" (5th generation) (2021) (Cellular US)";
    if ([platform isEqualToString:@"iPad13,10"])    return @"iPad Pro 12.9\" (5th generation) (2021) (Cellular Global)";
    if ([platform isEqualToString:@"iPad13,11"])    return @"iPad Pro 12.9\" (5th generation) (2021) (Cellular China)";

    //iPad mini
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad mini 2 (Wi-Fi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad mini 2 (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad mini 2 (China)";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad mini 3 (Wi-Fi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,1"])      return @"iPad mini 4 (Wi-Fi)";
    if ([platform isEqualToString:@"iPad5,2"])      return @"iPad mini 4 (Cellular)";
    if ([platform isEqualToString:@"iPad11,1"])     return @"iPad mini (5th generation) (2019) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad11,2"])     return @"iPad mini (5th generation) (2019) (Cellular)";
    if ([platform isEqualToString:@"iPad14,1"])     return @"iPad mini (6th generation) (2021) (Wi-Fi)";
    if ([platform isEqualToString:@"iPad14,2"])     return @"iPad mini (6th generation) (2021) (Cellular)";
    
    //Apple TV
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"AppleTV5,3"])   return @"Apple TV 4";
    if ([platform isEqualToString:@"AppleTV6,2"])   return @"Apple TV 4K";
    if ([platform isEqualToString:@"AppleTV11,1"])  return @"Apple TV 4K (2nd generation)";

    //Apple Watch
    if ([platform isEqualToString:@"Watch1,1"])     return @"Apple Watch (1st generation) (38mm)";
    if ([platform isEqualToString:@"Watch1,2"])     return @"Apple Watch (1st generation) (42mm)";
    if ([platform isEqualToString:@"Watch2,6"])     return @"Apple Watch Series 1 (38mm)";
    if ([platform isEqualToString:@"Watch2,7"])     return @"Apple Watch Series 1 (42mm)";
    if ([platform isEqualToString:@"Watch2,3"])     return @"Apple Watch Series 2 (38mm)";
    if ([platform isEqualToString:@"Watch2,4"])     return @"Apple Watch Series 2 (42mm)";
    if ([platform isEqualToString:@"Watch3,1"])     return @"Apple Watch Series 3 (38mm Cellular)";
    if ([platform isEqualToString:@"Watch3,2"])     return @"Apple Watch Series 3 (42mm Cellular)";
    if ([platform isEqualToString:@"Watch3,3"])     return @"Apple Watch Series 3 (38mm)";
    if ([platform isEqualToString:@"Watch3,4"])     return @"Apple Watch Series 3 (42mm)";
    if ([platform isEqualToString:@"Watch4,1"])     return @"Apple Watch Series 4 (40mm)";
    if ([platform isEqualToString:@"Watch4,2"])     return @"Apple Watch Series 4 (44mm)";
    if ([platform isEqualToString:@"Watch4,3"])     return @"Apple Watch Series 4 (40mm Cellular)";
    if ([platform isEqualToString:@"Watch4,4"])     return @"Apple Watch Series 4 (44mm Cellular)";
    if ([platform isEqualToString:@"Watch5,1"])     return @"Apple Watch Series 5 (40mm)";
    if ([platform isEqualToString:@"Watch5,2"])     return @"Apple Watch Series 5 (44mm)";
    if ([platform isEqualToString:@"Watch5,3"])     return @"Apple Watch Series 5 (40mm Cellular)";
    if ([platform isEqualToString:@"Watch5,4"])     return @"Apple Watch Series 5 (44mm Cellular)";
    if ([platform isEqualToString:@"Watch6,1"])     return @"Apple Watch Series 6 (40mm)";
    if ([platform isEqualToString:@"Watch6,2"])     return @"Apple Watch Series 6 (44mm)";
    if ([platform isEqualToString:@"Watch6,3"])     return @"Apple Watch Series 6 (40mm Cellular)";
    if ([platform isEqualToString:@"Watch6,4"])     return @"Apple Watch Series 6 (44mm Cellular)";
    if ([platform isEqualToString:@"Watch5,9"])     return @"Apple Watch SE (40mm)";
    if ([platform isEqualToString:@"Watch5,10"])    return @"Apple Watch SE (44mm)";
    if ([platform isEqualToString:@"Watch5,11"])    return @"Apple Watch SE (40mm Cellular)";
    if ([platform isEqualToString:@"Watch5,12"])    return @"Apple Watch SE (44mm Cellular)";
    if ([platform isEqualToString:@"Watch6,6"])     return @"Apple Watch Series 7 (41mm)";
    if ([platform isEqualToString:@"Watch6,7"])     return @"Apple Watch Series 7 (45mm)";
    if ([platform isEqualToString:@"Watch6,8"])     return @"Apple Watch Series 7 (41mm Cellular)";
    if ([platform isEqualToString:@"Watch6,9"])     return @"Apple Watch Series 7 (45mm Cellular)";

    //iMac
    if ([platform isEqualToString:@"iMac21,1"])        return @"iMac 24\" (M1, 2021)";
    if ([platform isEqualToString:@"iMac21,2"])        return @"iMac 24\" (M1, 2021)";
    //Mac mini
    if ([platform isEqualToString:@"Macmini9,1"])      return @"Mac mini (M1, 2020)";
    //MacBookAir
    if ([platform isEqualToString:@"MacBookAir10,1"])  return @"MacBook Air (M1, Late 2020)";
    //MacBook Pro
    if ([platform isEqualToString:@"MacBookPro17,1"])  return @"MacBook Pro 13\"  (M1, 2020)";
    if ([platform isEqualToString:@"MacBookPro18,3"])  return @"MacBook Pro 14\" (M1 Pro, 2021)";
    if ([platform isEqualToString:@"MacBookPro18,4"])  return @"MacBook Pro 14\" (M1 Max, 2021)";
    if ([platform isEqualToString:@"MacBookPro18,1"])  return @"MacBook Pro 16\" (M1 Pro, 2021)";
    if ([platform isEqualToString:@"MacBookPro18,2"])  return @"MacBook Pro 16\" (M1 Max, 2021)";

    //Simulator
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";

    return platform;
}
@end
