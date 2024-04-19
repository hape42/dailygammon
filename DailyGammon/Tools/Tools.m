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
#include <unicode/utf8.h>
#import "DGRequest.h"
#import "Constants.h"

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


-(void)matchCount
{
    
    DGRequest *request = [[DGRequest alloc] initWithString:@"http://dailygammon.com/bg/top" completionHandler:^(BOOL success, NSError *error, NSString *result)
    {
        if (success)
        {
            int matchCountValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"matchCount"]intValue];
            if ([result rangeOfString:@"There are no matches where you can move."].location != NSNotFound)
            {
                if(matchCountValue != 0)
                {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"matchCount"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:matchCountChangedNotification object:self];
                }
            }
            else
            {
                NSData *htmlData = [result dataUsingEncoding:NSUnicodeStringEncoding];
                
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
                
                int tableNo = 1;
                self->preferences = [[Preferences alloc] init];
                
                if([self->preferences isMiniBoard])
                    tableNo = 1;
                else
                    tableNo = 2;
                NSString *queryString = [NSString stringWithFormat:@"//table[%d]/tr[1]/th",tableNo];
                
                queryString = [NSString stringWithFormat:@"//table[%d]/tr",tableNo];
                NSArray *zeilen  = [xpathParser searchWithXPathQuery:queryString];
                int count = MAX(0,(int)zeilen.count - 1 );
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].applicationIconBadgeNumber = count;
                });
                
                if(matchCountValue != count)
                {
                    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:@"matchCount"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:matchCountChangedNotification object:self];
                }
            }
        }
        else
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    request = nil;
    }

- (void)readNote:(NSString *)event inDict:(NSMutableDictionary *)note
{
        
    DGRequest *request = [[DGRequest alloc] initWithString:[NSString stringWithFormat:@"http://dailygammon.com%@", event] completionHandler:^(BOOL success, NSError *error, NSString *result)
    {
        if (success)
        {
            [self analyzeNoteHTML:result inDict:note];
        }
        else
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    request = nil;
    
}
- (void)analyzeNoteHTML:(NSString *)result inDict:(NSMutableDictionary *)noteDict
{
    NSString *note = @"Note";

    NSData *eventHtmlData = [result dataUsingEncoding:NSUnicodeStringEncoding];
    NSString *htmlString = [NSString stringWithUTF8String:[eventHtmlData bytes]];

    htmlString = [[NSString alloc]
                  initWithData:eventHtmlData encoding: NSISOLatin1StringEncoding];
    htmlString = result;
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

            hrArray[i++] = [NSNumber numberWithInt:(int)foundRange.location];
        }
        else
        {
            // no more substring to find
            break;
        }
    }
    // <hr><B>NOTE:</B> jump over
        int position = [hrArray[0]intValue] + 4 + 4 + 5 + 5;
        note = [htmlString substringWithRange:NSMakeRange(position, [hrArray[1]intValue] - position)];
        note = [note stringByReplacingOccurrencesOfString:@"<br>"
                                               withString:@"\n"];
    [noteDict setObject:note forKey:@"note"];
    
}

- (void)readPlayers:(NSString *)event inDict:(NSMutableDictionary *)eventDict
{
        
    DGRequest *request = [[DGRequest alloc] initWithString:[NSString stringWithFormat:@"http://dailygammon.com%@", event] completionHandler:^(BOOL success, NSError *error, NSString *result)
    {
        if (success)
        {
            [self analyzePlayerHTML:result inDict:eventDict];
        }
        else
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    request = nil;
    
}
- (void)analyzePlayerHTML:(NSString *)result inDict:(NSMutableDictionary *)eventDict
{

    NSString *players = @"64/10";
    NSString *htmlString = result;

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
//            if([numberString isEqual:@"?"])
//                XLog(@"? %@", playersArray);
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
    
    [eventDict setObject:players forKey:@"player"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateGameLoungeCollectionView" object:self];

    return ;
}


- (void)removeAllSubviewsRecursively:(UIView *)view 
{
    for (UIView *subview in view.subviews) 
    {
        [self removeAllSubviewsRecursively:subview];
        [subview removeFromSuperview];
    }
}

@end

