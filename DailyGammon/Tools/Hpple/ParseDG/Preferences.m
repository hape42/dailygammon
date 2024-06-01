//
//  Preferences.m
//  DailyGammon
//
//  Created by Peter on 10.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "Preferences.h"
#import "TFHpple.h"
#import "DGRequest.h"

@implementation Preferences

-(void)initPreferences
{
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"isMiniBoard"];

    DGRequest *request = [[DGRequest alloc] initWithString:@"http://dailygammon.com/bg/profile" completionHandler:^(BOOL success, NSError *error, NSString *result)
    {
        if (success)
        {
            NSData *htmlData = [result dataUsingEncoding:NSUnicodeStringEncoding];

            NSMutableArray *preferencesArray = [[NSMutableArray alloc]init];
            // Create parser
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
            
            NSArray *elements  = [xpathParser searchWithXPathQuery:@"//form[3]/table[1]/tr"];
            
            for(TFHppleElement *element in elements)
            {
                TFHppleElement *child = [element firstChild];
                for (TFHppleElement *grandChild in child.children)
                {
                    NSDictionary *dict = [grandChild attributes];
                    if([[dict objectForKey:@"type"] isEqualToString:@"checkbox"])
                    {
                        [preferencesArray addObject:dict];
                    }
                }
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:preferencesArray forKey:@"preferencesArray"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            BOOL isMiniBoard = FALSE;
            elements  = [xpathParser searchWithXPathQuery:@"//form[3]/table[4]/tr"];
            
            for(TFHppleElement *element in elements)
            {
                TFHppleElement *child = [element firstChild];
                for (TFHppleElement *grandChild in child.children)
                {
                    NSDictionary *dict = [grandChild attributes];
                    //       XLog(@"%@",dict);
                    if([[element content] isEqualToString:@"Mini"])
                        if([[dict objectForKey:@"checked"] isEqualToString:@"checked"])
                            isMiniBoard = TRUE;
                }
            }
            [[NSUserDefaults standardUserDefaults] setBool:isMiniBoard forKey:@"isMiniBoard"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dgPreferences" object:self userInfo:nil];

        }
        else
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    
    request = nil;
}
- (NSMutableArray *)readPreferences
{
    NSMutableArray *preferencesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"preferencesArray"];
//    if(!preferencesArray)
    {
        [self initPreferences];
        preferencesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"preferencesArray"];
    }
    
    return preferencesArray;
}

-(void)ensurePlayerNameLink
{
    // The switch in dailygammon Personal Preferences "Player Name links on game page" should always be switched on. We need the information in different places.
    
    // read from server

    DGRequest *request = [[DGRequest alloc] initWithString:@"http://dailygammon.com/bg/profile" completionHandler:^(BOOL success, NSError *error, NSString *result)
    {
        if (success)
        {
            NSData *htmlData = [result dataUsingEncoding:NSUnicodeStringEncoding];

            NSMutableArray *preferencesArray = [[NSMutableArray alloc]init];
            // Create parser
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
            
            NSArray *elements  = [xpathParser searchWithXPathQuery:@"//form[3]/table[1]/tr"];
            
            for(TFHppleElement *element in elements)
            {
                TFHppleElement *child = [element firstChild];
                for (TFHppleElement *grandChild in child.children)
                {
                    NSDictionary *dict = [grandChild attributes];
                    if([[dict objectForKey:@"type"] isEqualToString:@"checkbox"])
                    {
                        [preferencesArray addObject:dict];
                    }
                }
            }
            
            NSMutableDictionary *playerNameLink = preferencesArray[3];
            if([[playerNameLink objectForKey:@"checked"] isEqualToString:@"checked"])
                return;
            else
            {
                NSString *postString = @"";
                NSDictionary *dict = preferencesArray[0];
                if([[dict objectForKey:@"checked"] isEqualToString:@"checked"])
                    postString = @"0=on";
                else
                    postString = @"0=off";

                for(int index = 1; index < preferencesArray.count; index++)
                {
                    NSDictionary *dict = preferencesArray[index];
                    if(index == 3)
                    {
                        postString = [NSString stringWithFormat:@"%@&%d=on", postString,index];
                    }
                    else
                    {
                        if([[dict objectForKey:@"checked"] isEqualToString:@"checked"])
                            postString = [NSString stringWithFormat:@"%@&%d=on", postString,index];
                        else
                            postString = [NSString stringWithFormat:@"%@&%d=off", postString,index];
                    }
                }

                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://dailygammon.com/bg/profile/pref"]];
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
                NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody:data];
                [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
                
                NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
                
                NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
                [task resume];

            }
        }
        else
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    
    request = nil;

}

- (void)readNextMatchOrdering
{
    // check if orderTyp exists
    if( [[NSUserDefaults standardUserDefaults] objectForKey:@"orderTyp"] == nil)
    {
        DGRequest *request = [[DGRequest alloc] initWithString:@"http://dailygammon.com/bg/profile" completionHandler:^(BOOL success, NSError *error, NSString *result)
        {
            if (success)
            {
                NSData *htmlData = [result dataUsingEncoding:NSUnicodeStringEncoding];

                int order = 0;

                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];

                NSArray *elements  = [xpathParser searchWithXPathQuery:@"//form[3]/table[2]/tr"];

                for(TFHppleElement *element in elements)
                {
                    TFHppleElement *child = [element firstChild];
                    for (TFHppleElement *grandChild in child.children)
                    {
                        NSDictionary *dict = [grandChild attributes];
                 //       XLog(@"%@",dict);
                        if([[dict objectForKey:@"checked"] isEqualToString:@"checked"])
                        {
                            [[NSUserDefaults standardUserDefaults] setInteger:order forKey:@"orderTyp"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                    }
                    order++;
                }
            }
            else
            {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
        request = nil;

    }
}

- (bool)isMiniBoard
{
    return [[NSUserDefaults standardUserDefaults]  boolForKey:@"isMiniBoard"];
}
@end
