//
//  Tools.m
//  DailyGammon
//
//  Created by Peter on 25.04.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import "Tools.h"
#import "Design.h"
#import "TFHpple.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Preferences.h"

@interface Tools ()
@end

@implementation Tools

@synthesize preferences;

typedef void(^connection)(BOOL);


//https://stackoverflow.com/questions/1083701/how-to-check-for-an-active-internet-connection-on-ios-or-macos
/*
 Connectivity testing code pulled from Apple's Reachability Example: https://developer.apple.com/library/content/samplecode/Reachability
 */
-(BOOL)hasConnectivity
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if (reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // If target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // If target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs.
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)noInternet: (UIViewController *)vc
{
    UIAlertController * alert = [UIAlertController
                                  alertControllerWithTitle:@"Problem"
                                  message:@"This app is a client for the backgammon server from www.dailygammon.com\n\nThe app can only be used with a working internet connection.\n\nPlease make sure you have an internet connection and restart the app.\n\nThe app will exit now "
                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    exit(0);
                                }];

    [alert addAction:okButton];
    [vc presentViewController:alert animated:YES completion:nil];

}
/*
#pragma mark - info
- (void)miniBoardSchemaWarning
{
    int rand = 10;
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    int maxHoehe  = [UIScreen mainScreen].bounds.size.height;
    
    if([design isX])
    {
        UIEdgeInsets safeArea = [[UIApplication sharedApplication] keyWindow].safeAreaInsets;
        maxBreite -= (safeArea.left + safeArea.right);
        rand += safeArea.left;
    }
    
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(rand ,
                                                                50 ,
                                                                maxBreite - 20,
                                                                MIN(maxHoehe - 80, 250))];
    rand = 10;
    infoView.backgroundColor = VIEWBACKGROUNDCOLOR;
    infoView.layer.borderWidth = 1;
    infoView.tag = 42;
    [self.view addSubview:infoView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(rand, rand, infoView.layer.frame.size.width - (2 * rand), 40)];
    title.text = @"Warning:";
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"Warning:"];
    [attr addAttribute:NSFontAttributeName
                 value:[UIFont systemFontOfSize:20.0]
                 range:NSMakeRange(0, [attr length])];
    [title setAttributedText:attr];
    
    title.textAlignment = NSTextAlignmentCenter;
    [infoView addSubview:title];
    
    
    UITextView *message  = [[UITextView alloc] initWithFrame:CGRectMake(rand, 50 , infoView.layer.frame.size.width - (2 * rand), infoView.layer.frame.size.height - 50 - rand)];
    message.textAlignment = NSTextAlignmentCenter;
    message.text = @"This App doesn’t currently support Board Scheme “Mini” as set in your account preferences. Only “Classic” or “Blue/White” will work. \n\nPlease select:";
    attr = [[NSMutableAttributedString alloc] initWithString:@"This App doesn’t currently support Board Scheme “Mini” as set in your account preferences. Only “Classic” or “Blue/White” will work. \n\nPlease select:"];
    [attr addAttribute:NSFontAttributeName
                 value:[UIFont systemFontOfSize:20.0]
                 range:NSMakeRange(0, [attr length])];
    [message setAttributedText:attr];
    message.textAlignment = NSTextAlignmentCenter;
    
    [infoView addSubview:message];
    
    float r = (infoView.layer.frame.size.width - ( 3 * 100)) / 4;
    
    UIButton *buttonNext = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonNext = [design makeNiceButton:buttonNext];
    [buttonNext setTitle:@"Fix it for me" forState: UIControlStateNormal];
    buttonNext.frame = CGRectMake(r, infoView.layer.frame.size.height - 50, 100, 35);
    [buttonNext addTarget:self action:@selector(fixIt) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:buttonNext];
    
    UIButton *buttonToTop = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonToTop = [design makeNiceButton:buttonToTop];
    [buttonToTop setTitle:@"I fix it" forState: UIControlStateNormal];
    buttonToTop.frame = CGRectMake(r + 100 + r, infoView.layer.frame.size.height - 50, 100, 35);
    [buttonToTop addTarget:self action:@selector(gotoWebsite) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:buttonToTop];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    cancel = [design makeNiceButton:cancel];
    [cancel setTitle:@"Cancel" forState: UIControlStateNormal];
    cancel.frame = CGRectMake(r + 100 + r + 100 + r, infoView.layer.frame.size.height - 50, 100, 35);
    [cancel addTarget:self action:@selector(cancelInfo) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:cancel];
    
    return;
}

-(void)cancelInfo
{
    UIView *removeView;
    while((removeView = [self.view viewWithTag:42]) != nil)
    {
        [removeView removeFromSuperview];
    }
}
*/

-(int)matchCount
{
    NSURL *urlTopPage = [NSURL URLWithString:@"http://dailygammon.com/bg/top"];
    NSData *topPageHtmlData = [NSData dataWithContentsOfURL:urlTopPage];
    
    NSString *htmlString = [NSString stringWithUTF8String:[topPageHtmlData bytes]];
    htmlString = [[NSString alloc]
                  initWithData:topPageHtmlData encoding: NSISOLatin1StringEncoding];
    
    if ([htmlString rangeOfString:@"There are no matches where you can move."].location != NSNotFound)
    {
        return 0;
    }
    
    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    int tableNo = 1;
    preferences = [[Preferences alloc] init];

    if([preferences isMiniBoard])
        tableNo = 1;
    else
        tableNo = 2;
    NSString *queryString = [NSString stringWithFormat:@"//table[%d]/tr[1]/th",tableNo];
    
    queryString = [NSString stringWithFormat:@"//table[%d]/tr",tableNo];
    NSArray *zeilen  = [xpathParser searchWithXPathQuery:queryString];
    return (int)zeilen.count - 1;
    }

- (NSString *)readNote:(NSString *)event
{
    NSString *note = @"Note";
    
    NSURL *urlEvent = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@", event]];
    NSData *eventHtmlData = [NSData dataWithContentsOfURL:urlEvent];
    
    NSString *htmlString = [NSString stringWithUTF8String:[eventHtmlData bytes]];
    htmlString = [[NSString alloc]
                  initWithData:eventHtmlData encoding: NSISOLatin1StringEncoding];
    NSRange searchRange = NSMakeRange(0,htmlString.length);
    NSRange foundRange;
    int i = 0;
    NSMutableArray *hrArray = [[NSMutableArray alloc]init];
    while (searchRange.location < htmlString.length)
    {
        searchRange.length = htmlString.length-searchRange.location;
        foundRange = [htmlString rangeOfString:@"<hr>" options:0 range:searchRange];
        
        if (foundRange.location != NSNotFound)
        {
            searchRange.location = foundRange.location+foundRange.length;

          //  XLog(@"<hr>%d", (int)foundRange.location);
            hrArray[i++] = [NSNumber numberWithInt:(int)foundRange.location];
        }
        else
        {
            // no more substring to find
            break;
        }
    }
    // <hr><B>NOTE:</B> überspringen
    int position = [hrArray[0]intValue] + 4 + 4 + 5 + 5;
    note = [htmlString substringWithRange:NSMakeRange(position, [hrArray[1]intValue] - position)];
    note = [note stringByReplacingOccurrencesOfString:@"<br>"
                                         withString:@"\n"];
    return note;
}
- (NSString *)readPlayers:(NSString *)event
{
    NSString *players = @"64/10";
    NSURL *urlEvent = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@", event]];
    NSData *eventHtmlData = [NSData dataWithContentsOfURL:urlEvent];
    
    NSString *htmlString = [NSString stringWithUTF8String:[eventHtmlData bytes]];
    htmlString = [[NSString alloc]
                  initWithData:eventHtmlData encoding: NSISOLatin1StringEncoding];
    
    NSMutableArray *playersArray = [[NSMutableArray alloc]initWithCapacity:2];
    
    NSRange searchRange = NSMakeRange(0,htmlString.length);
    NSRange foundRange;
    while (searchRange.location < htmlString.length)
    {
        searchRange.length = htmlString.length-searchRange.location;
        foundRange = [htmlString rangeOfString:@" player" options:0 range:searchRange];
        
        if (foundRange.location != NSNotFound)
        {
            // found an occurrence of the substring! do stuff here
            searchRange.location = foundRange.location+foundRange.length;
            
            
     //       NSLog(@"position %lu %@", (unsigned long)foundRange.location, [htmlString substringWithRange:NSMakeRange(foundRange.location -4 , 3) ]);
            NSScanner *scanner = [NSScanner scannerWithString:[htmlString substringWithRange:NSMakeRange(foundRange.location -4 , 4) ]];
            NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
            NSString *numberString = @"?";

            // Throw away characters before the first number.
            [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
            // Collect numbers.
            [scanner scanCharactersFromSet:numbers intoString:&numberString];
            if([[htmlString substringWithRange:NSMakeRange(foundRange.location -4 , 3) ] isEqualToString:@"All"]) // Beginners hat "All players have ratings less than 1501 at signup time." zusätzlich
                continue;
            if([numberString isEqual:@"?"])
                XLog(@"? %@", playersArray);
            [playersArray addObject:numberString];
        }
        else
        {
            // no more substring to find
            break;
        }
    }
    
    if(playersArray.count == 2)
    {
        players = [NSString stringWithFormat:@"%d/%d",[playersArray[0]intValue], [playersArray[1]intValue] ];
    }
    else if(playersArray.count == 3) // invited players überspringen
    {
        players = [NSString stringWithFormat:@"%d/%d",[playersArray[0]intValue], [playersArray[2]intValue] ];
    }
    else if(playersArray.count == 4) //
    {
        players = [NSString stringWithFormat:@"%d/%d",[playersArray[0]intValue], [playersArray[3]intValue] ];
    }
   else
        players = @"?";
    return players;
    }


@end

