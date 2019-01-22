//
//  Rating.m
//  DailyGammon
//
//  Created by Peter on 12.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "Rating.h"
#import "TFHpple.h"

@implementation Rating

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
    wonMatches -= 3; // won, header, leerzeile
    lostMatches -= 1; //  header
    wonMatches = MAX(0, wonMatches);
    lostMatches = MAX(0, lostMatches);
    NSString *wlaOpponent = [NSString stringWithFormat:@" w=%d l=%d a=%ld ", wonMatches,lostMatches, active.count-1]; // Überschrift abziehen
    NSString *wlaPlayer = [NSString stringWithFormat:@" w=%d l=%d a=%ld ", lostMatches, wonMatches, active.count-1]; // Überschrift abziehen

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
    [ratingDict setObject:ratingPlayer forKey:@"ratingPlayer"];
    [ratingDict setObject:wlaPlayer forKey:@"wlaPlayer"];

    return ratingDict;
}

- (float)readRatingForUser:(NSString *)userID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/user/%@", userID]];
    NSData *htmlData = [NSData dataWithContentsOfURL:url];
    NSString *ratingPlayer = @"?";
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[2]/tr[1]/td[3]/table[1]/tr[1]/td[2]"];
    for(TFHppleElement *element in elements)
    {
        TFHppleElement *child = [element firstChild];
        ratingPlayer = [child content];
    }
    
    return [ratingPlayer floatValue];
}

@end
