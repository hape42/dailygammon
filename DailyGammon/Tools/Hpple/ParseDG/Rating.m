//
//  Rating.m
//  DailyGammon
//
//  Created by Peter on 12.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "Rating.h"
#import "TFHpple.h"
#import "AppDelegate.h"
#import "DbConnect.h"
#import "DGRequest.h"
#import "RatingTools.h"
#import "RatingCD.h"

@implementation Rating

@synthesize ratingTools, ratingCD;

- (NSMutableDictionary *)readRatingForPlayer:(NSString *)userID andOpponent: (NSString *)opponentID
{
    NSMutableDictionary *ratingDict = [[NSMutableDictionary alloc]init];
    NSString * ratingOpponent = @"?";
    //http://dailygammon.com/bg/user/3289?sort_win_loss=1&finished=1&active=1&versus=13014
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/user/%@?sort_win_loss=1&finished=1&active=1&versus=%@",opponentID, userID]];
    NSData *htmlData = [NSData dataWithContentsOfURL:url];
     
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];

#pragma mark - rating opponent holen
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[2]/tr[1]/td[3]/table[1]/tr[1]/td[2]"];
    for(TFHppleElement *element in elements)
    {
        TFHppleElement *child = [element firstChild];
        ratingOpponent = [child content];
    }
    
#pragma mark - active games holen
    NSArray *active  = [xpathParser searchWithXPathQuery:@"//table[4]/tr"];
//    XLog(@"%d active matches", active.count-1); // Überschrift abziehen

    
#pragma mark - lost games holen
    NSArray *finishedMatches  = [xpathParser searchWithXPathQuery:@"//table[5]/tr"];
    int lostMatches = 0;
    int wonMatches  = 0;
    BOOL won  = FALSE;
    BOOL lost = FALSE;
    for(TFHppleElement *element in finishedMatches)
    {
        // all games below a line containing "won" are won until until we hit a "lost" or
        // we come to the end
        NSString *zeile = [element content];
        if([zeile isEqualToString:@"won"])
        {
            won = TRUE;
        }
        if([zeile isEqualToString:@"lost"])
        {
            lost = TRUE;
            won = FALSE;
        }
        if(won)
            wonMatches++;
        if(lost)
            lostMatches++;
    }
    
    
    if (won)
    {
        wonMatches -= 2;
    }
    else
    {
        wonMatches -= 3; // won, header, leerzeile
    }
    lostMatches -= 1; //  header
    wonMatches = MAX(0, wonMatches);
    lostMatches = MAX(0, lostMatches);
    NSString *wlaOpponent = [NSString stringWithFormat:@" w=%d l=%d a=%ld ", wonMatches,lostMatches, active.count-1]; // Überschrift abziehen
    NSString *activeOpponent = [NSString stringWithFormat:@"Active %ld ", active.count-1]; // Überschrift abziehen
    NSString *wonOpponent = [NSString stringWithFormat:@"Won %d", wonMatches];
    NSString *lostOpponent = [NSString stringWithFormat:@"Lost %d",lostMatches];
    
    NSString *wlaPlayer = [NSString stringWithFormat:@" w=%d l=%d a=%ld ", lostMatches, wonMatches, active.count-1]; // Überschrift abziehen
    NSString *activePlayer = [NSString stringWithFormat:@"Active %ld ", active.count-1]; // Überschrift abziehen
    NSString *wonPlayer = [NSString stringWithFormat:@"Won %d", lostMatches];
    NSString *lostPlayer = [NSString stringWithFormat:@"Lost %d", wonMatches];

    if([opponentID isEqualToString:@""])
    {
        // Personal Preferences -> no Player Name links on game page -> no OpponentID
        
        ratingOpponent = @"no link";
        wlaOpponent = [NSString stringWithFormat:@" w=? l=? a=?"];
        activeOpponent = [NSString stringWithFormat:@"Active ? "];
        wonOpponent = [NSString stringWithFormat:@"Won ?"];
        lostOpponent = [NSString stringWithFormat:@"Lost ?"];
        
        wlaPlayer = [NSString stringWithFormat:@" w=? l=? a=? "];
        activePlayer = [NSString stringWithFormat:@"Active ? "];
        wonPlayer = [NSString stringWithFormat:@"Won ?"];
        lostPlayer = [NSString stringWithFormat:@"Lost ?"];

    }
#pragma mark - rating player holen

    //http://dailygammon.com/bg/user/13014
    
    url = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/user/%@", userID]];
    htmlData = [NSData dataWithContentsOfURL:url];
    NSString *ratingPlayer = @"?";
    xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    elements  = [xpathParser searchWithXPathQuery:@"//table[2]/tr[1]/td[3]/table[1]/tr[1]/td[2]"];
    for(TFHppleElement *element in elements)
    {
        TFHppleElement *child = [element firstChild];
        ratingPlayer = [child content];
    }
    [ratingDict setObject:ratingOpponent forKey:@"ratingOpponent"];
    [ratingDict setObject:wlaOpponent forKey:@"wlaOpponent"];
    [ratingDict setObject:activeOpponent forKey:@"activeOpponent"];
    [ratingDict setObject:wonOpponent forKey:@"wonOpponent"];
    [ratingDict setObject:lostOpponent forKey:@"lostOpponent"];
    [ratingDict setObject:ratingPlayer forKey:@"ratingPlayer"];
    [ratingDict setObject:wlaPlayer forKey:@"wlaPlayer"];
    [ratingDict setObject:activePlayer forKey:@"activePlayer"];
    [ratingDict setObject:wonPlayer forKey:@"wonPlayer"];
    [ratingDict setObject:lostPlayer forKey:@"lostPlayer"];

    return ratingDict;
}

- (void)updateRating
{
    ratingTools = [[RatingTools alloc] init];
    ratingCD    = [[RatingCD alloc] init];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *dateDB = [format stringFromDate:[NSDate date]];
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

    DGRequest *request = [[DGRequest alloc] initWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/user/%@", userID] completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {
            NSData *htmlData = [result dataUsingEncoding:NSUnicodeStringEncoding];
            NSString *ratingPlayer = @"?";
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
            
            NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[2]/tr[1]/td[3]/table[1]/tr[1]/td[2]"];
            for(TFHppleElement *element in elements)
            {
                TFHppleElement *child = [element firstChild];
                ratingPlayer = [child content];
            }
            float ratingDB = [app.dbConnect readRatingForDatum:dateDB andUser:userID];
            if([ratingPlayer floatValue] > ratingDB)
                [app.dbConnect saveRating:dateDB withRating:[ratingPlayer floatValue] forUser:userID];
            if([[[NSUserDefaults standardUserDefaults] valueForKey:@"iCloud"]boolValue])
                [self->ratingTools saveRating:dateDB withRating:[ratingPlayer floatValue]] ;

            [self->ratingCD saveRating:[ratingPlayer floatValue] forDate:dateDB forUser:userID];

        }
        else
        {
            XLog(@"Error: %@", error.localizedDescription);
        }
        
    }];
    request = nil;

}

@end
