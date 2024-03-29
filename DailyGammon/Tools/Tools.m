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
    return players;
    }

- (NSString *)cleanChatString:(NSString *)chatString
{
    // Gänsefüßchen entfernen, könnte zu Problemen als parameter für die URL führen
    __block NSString *str = @"";
    [chatString enumerateSubstringsInRange:NSMakeRange(0, chatString.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop)
     {
         
       //  NSLog(@"substring: %@ substringRange: %@, enclosingRange %@", substring, NSStringFromRange(substringRange), NSStringFromRange(enclosingRange));
         if([substring isEqualToString:@"‘"])
             str = [NSString stringWithFormat:@"%@%@",str, @"'"];
         else if([substring isEqualToString:@"„"])
             str = [NSString stringWithFormat:@"%@%@",str, @"?"];
         else if([substring isEqualToString:@"“"])
             str = [NSString stringWithFormat:@"%@%@",str, @"?"];
         else
             str = [NSString stringWithFormat:@"%@%@",str, substring];
         
     }];
    
    return chatString;
    // Remove Emoji in NSString https://gist.github.com/siqin/4201667 löscht aber nur genau 1 Emoji
    //Anticro commented on 1 Jul 2020 •
    //'Measuring length of a string' at the Apple docs https://developer.apple.com/documentation/swift/string brought me to another solution, without the need for knowledge about the unicode pages. I just want letters to to remain in the string and skip all that is an icon:
    // löscht alle
    NSMutableString* const result = [NSMutableString stringWithCapacity:0];
    NSUInteger const len = str.length;
    NSString* subStr;
    for (NSUInteger index = 0; index < len; index++) {
        subStr = [str substringWithRange:NSMakeRange(index, 1)];
        const char* utf8Rep = subStr.UTF8String;  // will return NULL for icons that consist of 2 chars
        if (utf8Rep != NULL) {
            unsigned long const length = strlen(utf8Rep);
            if (length <= 2) {
                [result appendString:subStr];
            }
        }
    }

 //   str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];

    // dadurch wird ein Emoji im Format &#128514; in 😂 gewandelt. die Webseite liefert &#128514; wenn 😂 eingegeben wird
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};

    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:data
                                                                             options:options
                                                                  documentAttributes:nil
                                                                               error:nil];
    str = [attributedString string];

    return str;
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

