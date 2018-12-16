//
//  Match.m
//  DailyGammon
//
//  Created by Peter on 16.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "Match.h"
#import "TFHpple.h"

@implementation Match

-(NSMutableDictionary *) readMatch:(NSString *)matchLink
{
    NSMutableDictionary *boardDict = [[NSMutableDictionary alloc]init];
    
#pragma mark - matchName
    NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",matchLink]];
    
    NSData *matchHtmlData = [NSData dataWithContentsOfURL:urlMatch];
    NSError *error = nil;
    NSStringEncoding encoding;
    NSString *matchString = [[NSString alloc] initWithContentsOfURL:urlMatch
                                                       usedEncoding:&encoding
                                                              error:&error];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:matchHtmlData];
    
    NSArray *matchHeader  = [xpathParser searchWithXPathQuery:@"//h3"];
    NSMutableString *matchName = [[NSMutableString alloc]init];
    for(TFHppleElement *element in matchHeader)
    {
        for (TFHppleElement *child in element.children)
        {
            [matchName appendString:[child content]];
        }
    }
    [boardDict setObject:matchName forKey:@"matchName"];

#pragma mark - unexpected Move
    NSString *unexpectedMove = @"";
    if ([matchString rangeOfString:@"unexpected"].location == NSNotFound)
        unexpectedMove = @"Your opponent made an unexpected move, and the game has been rolled back to that point.";
    [boardDict setObject:unexpectedMove forKey:@"unexpectedMove"];

#pragma mark - obere Nummern Reihe
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[1]/td"];
    NSMutableArray *elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        [elementArray addObject:[element text]];
    }
    [boardDict setObject:elementArray forKey:@"nummernOben"];
    
#pragma mark - obere Grafik Reihe
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[2]/td"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        NSString *image = @"";
        NSString *href = @"";
        NSMutableArray *imgArray = [[NSMutableArray alloc]init];
        for (TFHppleElement *child in element.children)
        {
            NSDictionary *hrefChild = [child attributes];
            href = [hrefChild objectForKey:@"href"];
            TFHppleElement *childFirst = [child firstChild];
            NSDictionary *imgChild = [childFirst attributes];
            image = [imgChild objectForKey:@"src"];
            if ([child.tagName isEqualToString:@"img"])
            {
                image = [child objectForKey:@"src"];
                [imgArray addObject:image];
            }
            if(imgArray.count == 0)
                if(image != nil)
                    [imgArray addObject:image];
            
        }
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:imgArray forKey:@"img"];
        [dict setValue:href forKey:@"href"];
        
        [elementArray addObject:dict];
    }
    [boardDict setObject:elementArray forKey:@"grafikOben"];
    
#pragma mark - opponent
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[2]/td[17]"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        for (TFHppleElement *child in element.children)
        {
            [elementArray addObject:[child content]];
        }
    }
    [boardDict setObject:elementArray forKey:@"opponent"];
    
#pragma mark - obere Reihe moveIndicator
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[3]/td"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        NSString *image = @"";
        for (TFHppleElement *child in element.children)
        {
            if ([child.tagName isEqualToString:@"img"])
            {
                image = [child objectForKey:@"src"];
            }
        }
        [elementArray addObject:image];
    }
    [boardDict setObject:elementArray forKey:@"moveIndicatorOben"];
    
#pragma mark - Würfel Reihe
#warning colspan macht evtl. noch Probleme
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[4]/td"];
    elementArray = [[NSMutableArray alloc]init];
    NSString *matchLaengeText = @"?";
    for(TFHppleElement *element in elements)
    {
        matchLaengeText = [element  content]; // im letzten TD steht "3 Point Match"
        [boardDict setObject:matchLaengeText forKey:@"matchLaengeText"];

        NSString *image = @"";
        for (TFHppleElement *child in element.children)
        {
            if ([child.tagName isEqualToString:@"img"])
            {
                image = [child objectForKey:@"src"];
            }
        }
        [elementArray addObject:image];
    }
    [boardDict setObject:elementArray forKey:@"dice"];
    
#pragma mark - untere Reihe moveIndicator
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[5]/td"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        NSString *image = @"";
        for (TFHppleElement *child in element.children)
        {
            if ([child.tagName isEqualToString:@"img"])
            {
                image = [child objectForKey:@"src"];
            }
        }
        [elementArray addObject:image];
    }
    [boardDict setObject:elementArray forKey:@"moveIndicatorUnten"];
    
#pragma mark - untere Grafik Reihe
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[6]/td"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        NSString *image = @"";
        NSString *href = @"";
        NSMutableArray *imgArray = [[NSMutableArray alloc]init];
        for (TFHppleElement *child in element.children)
        {
            NSDictionary *hrefChild = [child attributes];
            href = [hrefChild objectForKey:@"href"];
            TFHppleElement *childFirst = [child firstChild];
            NSDictionary *imgChild = [childFirst attributes];
            image = [imgChild objectForKey:@"src"];
            if ([child.tagName isEqualToString:@"img"])
            {
                image = [child objectForKey:@"src"];
                [imgArray addObject:image];
            }
            if(imgArray.count == 0)
                if(image != nil)
                    [imgArray addObject:image];
        }
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:imgArray forKey:@"img"];
        [dict setValue:href forKey:@"href"];
        
        [elementArray addObject:dict];
    }
    [boardDict setObject:elementArray forKey:@"grafikUnten"];
    
#pragma mark - player
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[6]/td[17]"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        for (TFHppleElement *child in element.children)
        {
            [elementArray addObject:[child content]];
        }
    }
    [boardDict setObject:elementArray forKey:@"player"];
    
#pragma mark - untere Nummern Reihe
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[7]/td"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        if([element text] != nil)
            [elementArray addObject:[element text]];
    }
    [boardDict setObject:elementArray forKey:@"nummernUnten"];
    
    return boardDict;
}

@end
