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

- (NSMutableArray *)readPreferences
{
    NSURL *url = [NSURL URLWithString:@"http://dailygammon.com/bg/profile"];
    NSData *htmlData = [NSData dataWithContentsOfURL:url];
    
    NSMutableArray *preferencesArray = [[NSMutableArray alloc]init];
    // Create parser
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    //Get all the cells of the 2nd row of the 3rd table
    //        NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[3]/tr[2]/td"];
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
    
    return preferencesArray;
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
    }
}

- (bool)isMiniBoard
{
    NSURL *url = [NSURL URLWithString:@"http://dailygammon.com/bg/profile"];
    NSData *htmlData = [NSData dataWithContentsOfURL:url];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//form[3]/table[4]/tr"];
    
    for(TFHppleElement *element in elements)
    {
        TFHppleElement *child = [element firstChild];
        for (TFHppleElement *grandChild in child.children)
        {
            NSDictionary *dict = [grandChild attributes];
            //       XLog(@"%@",dict);
            if([[element content] isEqualToString:@"Mini"])
                if([[dict objectForKey:@"checked"] isEqualToString:@"checked"])
                    return TRUE;
        }
    }
    return FALSE;
}
@end
