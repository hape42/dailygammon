//
//  Match.m
//  DailyGammon
//
//  Created by Peter on 16.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "Match.h"
#import "TFHpple.h"
#import "DGRequest.h"
#import "AppDelegate.h"
#import "Tools.h"
#import "TextTools.h"

@interface Match ()

@end

@implementation Match

@synthesize noBoard;
@synthesize tools, textTools;

-(void)readMatch:(NSString *)matchLink reviewMatch:(BOOL)isReview 
{
    NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",matchLink]];

    DGRequest *request = [[DGRequest alloc] initWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",matchLink] completionHandler:^(BOOL success, NSError *error, NSString *result)
    {
        if (success)
        {
            [ self analyzeHTML:result reviewMatch:isReview ];
        }
        else
        {
            XLog(@"Error: %@ %@", error.localizedDescription, urlMatch);
        }
    }];

    request = nil;
}
-(void)analyzeHTML:(NSString *)htmlString reviewMatch:(BOOL)isReview
{
    tools = [[Tools alloc] init];
    textTools = [[TextTools alloc] init];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    noBoard = FALSE;
    int tableToAnalyze = 1;
    if(isReview)
        tableToAnalyze = 2;
    
#pragma mark - matchName
    NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",app.matchLink]];
    
    NSData *matchHtmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];

    if ([htmlString rangeOfString:@"<TD ALIGN=CENTER>13</TD>"].location == NSNotFound)
    {
        noBoard = TRUE;
        [app.boardDict setObject:htmlString forKey:@"htmlString"];
        [app.boardDict setObject:@"NoBoard" forKey:@"NoBoard"];
    }
    if ([htmlString rangeOfString:@"Next Game>&gt"].location != NSNotFound)
    {
        XLog(@"1 Next Game>> %@", urlMatch);
    }
    if ([htmlString rangeOfString:@"Next Game>>"].location != NSNotFound)
    {
        XLog(@"2 Next Game>> %@", urlMatch);
    }
    if ([htmlString rangeOfString:@"Next Game&gt>"].location != NSNotFound)
    {
        XLog(@"3 Next Game>> %@", urlMatch);
    }
    if ([htmlString rangeOfString:@"Next Game&gt;&gt"].location != NSNotFound)
    {
        XLog(@"4 Next Game>> %@", urlMatch);
        htmlString = [self skipNext:htmlString];
    }
    if ([htmlString rangeOfString:@"Welcome to DailyGammon"].location != NSNotFound)
    {
        [app.boardDict setObject:@"TopPage" forKey:@"TopPage"];
    }
    if ([htmlString rangeOfString:@"invites you to play"].location != NSNotFound)
    {
        [app.boardDict setObject:@"Invite" forKey:@"Invite"];
        [app.boardDict setObject:[self analyzeInvite:htmlString] forKey:@"inviteDict"];
    }
    if ([htmlString rangeOfString:@"DailyGammon Backups"].location != NSNotFound)
    {
        noBoard = TRUE;
        [app.boardDict setObject:@"Backups" forKey:@"Backups"];
    }

    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:matchHtmlData ] ;
    
    xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData ] ;

    [app.boardDict setObject:htmlData forKey:@"htmlData"];
    [app.boardDict setObject:htmlString forKey:@"htmlString"];

    NSArray *caption  = [xpathParser searchWithXPathQuery:@"//table/caption"];
    if(!isReview) // Ends at review match "last move" with exit to Toppage. Cause is not yet clear, but this is how to prevent it
    {
        if(caption.count > 0)
        {
            for(TFHppleElement *element in caption)
            {
                if([[element content] isEqualToString:@"Score"])
                {
                    NSMutableDictionary *finishedMatchDict = [[NSMutableDictionary alloc]init];
                    
                    finishedMatchDict = [self analyzeFinishedMatch:xpathParser];
                    [app.boardDict setObject:finishedMatchDict forKey:@"finishedMatch"];

                 //   return boardDict;
                }
            }
        }
    }
    else
    {
        if(caption.count > 0)
        {
            for(TFHppleElement *element in caption)
            {
                if([[element content] isEqualToString:@"Score"])
                {
                    NSMutableDictionary *finishedMatchDict = [[NSMutableDictionary alloc]init];
                    
                    finishedMatchDict = [self analyzeFinishedMatchReview:xpathParser];
                    [app.boardDict setObject:finishedMatchDict forKey:@"finishedMatch"];
                    [app.boardDict setObject:[NSNumber numberWithBool: isReview] forKey:@"isReview"];

                 //   return boardDict;
                }
            }
        }

    }
    NSString *chat = @"";
    NSRange preStart = [htmlString rangeOfString:@"<PRE>"];
    if(preStart.length > 0)
    {
        NSRange preEnd = [htmlString rangeOfString:@"</PRE>"];
        if(preEnd.length > 1)
        {
            NSRange rangeChat = NSMakeRange(preStart.location + preStart.length, preEnd.location - preStart.location - preStart.length);
            chat = [htmlString substringWithRange:rangeChat];
            chat = [chat stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        }
        else
        {
            preEnd.length = 80;
            preEnd.location = preStart.location + preEnd.length;
            NSRange rangeChat = NSMakeRange(preStart.location + preStart.length, preEnd.location - preStart.location - preStart.length);
            chat = [htmlString substringWithRange:rangeChat];
            chat = [chat stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];

        }
        chat = [textTools cleanChatString:chat];
    }

#pragma mark - The http request you submitted was in error.
    NSString *errorText = @"";
    if ([htmlString rangeOfString:@"The http request you submitted was in error."].location != NSNotFound)
    {
        errorText = @"The http request you submitted was in error.";
        [app.boardDict setObject:errorText forKey:@"error"];
        noBoard = TRUE;

    }

#pragma mark - There has been an internal error.
    if ([htmlString rangeOfString:@"There has been an internal error."].location != NSNotFound)
    {
        [app.boardDict setObject:@"There has been an internal error. " forKey:@"internal error"];
        noBoard = TRUE;
    }

    NSArray *matchHeader  = [xpathParser searchWithXPathQuery:@"//h3"];
    NSMutableString *matchName = [[NSMutableString alloc]init];
    for(TFHppleElement *element in matchHeader)
    {
        for (TFHppleElement *child in element.children)
        {
            [matchName appendString:[child content]];
            [matchName appendString:@" "];
       }
    }
    [app.boardDict setObject:matchName forKey:@"matchName"];
    [app.boardDict setObject:chat forKey:@"chat"];
    
#pragma mark -     You have received the following telegram message:
    if ([htmlString rangeOfString:@"telegram"].location != NSNotFound)
    {
        [app.boardDict setObject:@"You have received the following telegram message:" forKey:@"message"];
        NSArray *matchHeader  = [xpathParser searchWithXPathQuery:@"//pre"];
        for(TFHppleElement *element in matchHeader)
        {
            [app.boardDict setObject:[element content] forKey:@"chat"];
        }
    }
    
#pragma mark - You have received the following quick message from

    if ([htmlString rangeOfString:@"You have received the following quick message from"].location != NSNotFound)
    {
        NSArray *matchHeader  = [xpathParser searchWithXPathQuery:@"//h3"];
        for(TFHppleElement *element in matchHeader)
        {
            [app.boardDict setObject:[element content] forKey:@"quickMessage"];
        }
        matchHeader  = [xpathParser searchWithXPathQuery:@"//pre"];
        for(TFHppleElement *element in matchHeader)
        {
            [app.boardDict setObject:[element content] forKey:@"chat"];
        }

        NSMutableDictionary *messageDict = [[NSMutableDictionary alloc]init];

        NSArray *elements  = [xpathParser searchWithXPathQuery:@"//form[1]"];
        NSMutableArray *elementArray = [[NSMutableArray alloc]init];
        NSMutableArray *attributesArray = [[NSMutableArray alloc]init ];
        
        for(TFHppleElement *element in elements)
        {
            [elementArray addObject:[element content]];
            [attributesArray addObject:[element attributes]];
            NSString *href = @"";
            href = [element objectForKey:@"href"];

            for (TFHppleElement *child in [element children])
            {
                NSDictionary *dict = [child attributes];
                if([dict objectForKey:@"value"])
                    [messageDict setObject:[dict objectForKey:@"value"] forKey:@"Button"];
            }
            [messageDict setValue:href forKey:@"href"];

            XLog(@"%@",[element content]);
        }
        [messageDict setObject:elementArray forKey:@"chat"];
        [messageDict setObject:attributesArray forKey:@"attributes"];

        [app.boardDict setObject:messageDict forKey:@"messageDict"];
        noBoard = TRUE;
    }
    if ([htmlString rangeOfString:@"Your message has been sent"].location != NSNotFound)
    {
        [app.boardDict setObject:@"sent" forKey:@"messageSent"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"analyzeMatch" object:self];

        return ;
    }
#pragma mark - unexpected Move
    NSString *unexpectedMove = @"";
    if ([htmlString rangeOfString:@"unexpected"].location != NSNotFound)
        unexpectedMove = @"Your opponent made an unexpected move, and the game has been rolled back to that point.";
    [app.boardDict setObject:unexpectedMove forKey:@"unexpectedMove"];

#pragma mark - There are no matches where you can move.
    if ([htmlString rangeOfString:@"There are no matches where you can move."].location != NSNotFound)
    {
        [app.boardDict setObject:@"noMatches" forKey:@"noMatches"];
        noBoard = TRUE;
    }

    // prüfen ob jetzt tatsächlich ein Board abgearbeitet wird, oder ob noch etwas unvorhergesehenes passiert
#pragma mark - unbekanntes HTML.
    if ([htmlString rangeOfString:@"Review Game"].location == NSNotFound)
    {
 //       [boardDict setObject:htmlString forKey:@"unknown"];
 //       return boardDict;
    }
    if(noBoard)
    {
        [app.boardDict setObject:@"NoBoard" forKey:@"NoBoard"];
        [app.actionDict setObject:@"NoBoard" forKey:@"NoBoard"];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"analyzeMatch" object:self];

        return ;
    }
#pragma mark - obere Nummern Reihe
    NSArray *elements  = [xpathParser searchWithXPathQuery:[NSString stringWithFormat: @"//table[%d]/tr[1]/td",tableToAnalyze]];
    NSMutableArray *elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        [elementArray addObject:[element text]];
    }
    [app.boardDict setObject:elementArray forKey:@"nummernOben"];
    
#pragma mark - obere Grafik Reihe
    elements  = [xpathParser searchWithXPathQuery:[NSString stringWithFormat:@"//table[%d]/tr[2]/td",tableToAnalyze]];
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
    [app.boardDict setObject:elementArray forKey:@"grafikOben"];
    
#pragma mark - opponent
    elements  = [xpathParser searchWithXPathQuery:[NSString stringWithFormat:@"//table[%d]/tr[2]/td[17]",tableToAnalyze]];
    elementArray = [[NSMutableArray alloc]init];
    NSString *opponentID = @"";
    for(TFHppleElement *element in elements)
    {
        [app.boardDict setObject:[[element attributes] objectForKey:@"bgcolor"] forKey:@"opponentColor"];

        for (TFHppleElement *child in element.children)
        {
            [elementArray addObject:[child content]];
            if([[[child attributes] objectForKey:@"href"] length] > 0)
                opponentID = [[[child attributes] objectForKey:@"href"]lastPathComponent];
        }
    }
    [app.boardDict setObject:elementArray forKey:@"opponent"];
    [app.boardDict setObject:opponentID forKey:@"opponentID"];

#pragma mark - obere Reihe moveIndicator
    elements  = [xpathParser searchWithXPathQuery:[NSString stringWithFormat:@"//table[%d]/tr[3]/td",tableToAnalyze]];
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
    [app.boardDict setObject:elementArray forKey:@"moveIndicatorOben"];
    
#pragma mark - Würfel Reihe
    elements  = [xpathParser searchWithXPathQuery:[NSString stringWithFormat:@"//table[%d]/tr[4]/td",tableToAnalyze]];
    elementArray = [[NSMutableArray alloc]init];
    NSString *matchLaengeText = @"?";
    for(TFHppleElement *element in elements)
    {
        matchLaengeText = [element  content]; // im letzten TD steht "3 Point Match"
        [app.boardDict setObject:matchLaengeText forKey:@"matchLaengeText"];

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
    [app.boardDict setObject:elementArray forKey:@"dice"];
    
#pragma mark - untere Reihe moveIndicator
    elements  = [xpathParser searchWithXPathQuery:[NSString stringWithFormat:@"//table[%d]/tr[5]/td",tableToAnalyze]];
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
    [app.boardDict setObject:elementArray forKey:@"moveIndicatorUnten"];
    
#pragma mark - untere Grafik Reihe
    elements  = [xpathParser searchWithXPathQuery:[NSString stringWithFormat:@"//table[%d]/tr[6]/td",tableToAnalyze]];
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
    [app.boardDict setObject:elementArray forKey:@"grafikUnten"];
    
#pragma mark - player
    elements  = [xpathParser searchWithXPathQuery:[NSString stringWithFormat:@"//table[%d]/tr[6]/td[17]",tableToAnalyze]];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        [app.boardDict setObject:[[element attributes] objectForKey:@"bgcolor"] forKey:@"playerColor"];

        for (TFHppleElement *child in element.children)
        {
            [elementArray addObject:[child content]];
        }
    }
    [app.boardDict setObject:elementArray forKey:@"player"];
    
#pragma mark - untere Nummern Reihe
    elements  = [xpathParser searchWithXPathQuery:[NSString stringWithFormat:@"//table[%d]/tr[7]/td",tableToAnalyze]];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        if([element text] != nil)
            [elementArray addObject:[element text]];
    }
    [app.boardDict setObject:elementArray forKey:@"nummernUnten"];
    [self readActionForm:[app.boardDict objectForKey:@"htmlData"] withChat:(NSString *)[app.boardDict objectForKey:@"chat"] ];

    return ;
}
- (NSString *)skipNext:(NSString *)htmlString
{
    NSString *htmlStringNeu = htmlString;
    NSString *matchLink = @"";
    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData ] ;
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//a"];
    for(TFHppleElement *element in elements)
    {
        if([[element content] isEqualToString:@"Next Game>&gt"])
        {
            XLog(@"%@",[element objectForKey:@"href"]);
            matchLink = [element objectForKey:@"href"];
        }
    }
    NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",matchLink]];
    
    NSData *data = [NSData dataWithContentsOfURL:urlMatch];
    htmlStringNeu = [[NSString alloc]
                  initWithData:data encoding: NSISOLatin1StringEncoding];

    return htmlStringNeu;
}
-(void) readActionForm:(NSData *)htmlData withChat:(NSString *)chat
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSMutableArray *attributesArray = [[NSMutableArray alloc]init ];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//form[1]"];
    [app.actionDict setObject:elements forKey:@"elements"];

    for(TFHppleElement *element in elements)
    {
        if([[element raw] rangeOfString:@"textarea"].location != NSNotFound)
        {
            //NSArray *pre  = [xpathParser searchWithXPathQuery:@"//pre"];
            [self analyzeChat:element withChat:chat];
        }
        else
        {
            NSDictionary *elementDict = [element attributes];
            [app.actionDict setValue:[elementDict objectForKey:@"action"] forKey:@"action"];
            for (TFHppleElement *child in [element children])
            {
                NSDictionary *dict = [child attributes];
                if([dict objectForKey:@"value"])
                    [attributesArray addObject:dict];
            }
            [app.actionDict setObject:attributesArray forKey:@"attributes"];
            [app.actionDict setObject:[element content] forKey:@"content"];
        }
    }

    elements  = [xpathParser searchWithXPathQuery:@"//h4"];
    for(TFHppleElement *element in elements)
    {
        [app.actionDict setObject:[element content] forKey:@"Message"];
    }

    elements  = [xpathParser searchWithXPathQuery:@"//a"];
    NSMutableArray *reviewArray = [[NSMutableArray alloc]initWithCapacity:4];
    for(int i = 0; i < 4; i++)
    {
        reviewArray[i] = @"";
    }
    for(TFHppleElement *element in elements)
    {
        if([[element content] isEqualToString:@"Skip Game"])
        {
            [app.actionDict setObject:[element objectForKey:@"href"] forKey:@"SkipGame"];
        }
        if([[element content] isEqualToString:@"Swap Dice"])
        {
            [app.actionDict setObject:[element objectForKey:@"href"] forKey:@"SwapDice"];
        }
        if([[element content] isEqualToString:@"Undo Move"])
        {
            [app.actionDict setObject:[element objectForKey:@"href"] forKey:@"UndoMove"];
        }
        if([[element content] isEqualToString:@"Next Game>&gt"])
        {
            [app.actionDict setObject:[element objectForKey:@"href"] forKey:@"Next Game>>"];
        }
#pragma mark - Review Match
        if([[element content] isEqualToString:@"First"])
        {
            reviewArray[0] = [element objectForKey:@"href"];
        }
        if([[element content] isEqualToString:@"Prev"])
        {
            reviewArray[1] = [element objectForKey:@"href"];
        }
        if([[element content] isEqualToString:@"Next"])
        {
            reviewArray[2] = [element objectForKey:@"href"];
        }
        if([[element content] isEqualToString:@"Last"])
        {
            reviewArray[3] = [element objectForKey:@"href"];
        }
        if([[element content] isEqualToString:@"List of Moves"])
        {
            [app.actionDict setObject:[element objectForKey:@"href"] forKey:@"List of Moves"];
        }
    }
    [app.actionDict setObject:elements forKey:@"a"];
    [app.actionDict setObject:reviewArray forKey:@"review"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"analyzeMatch" object:self];

    return ;

}

- (void) analyzeChat:(TFHppleElement *)element withChat:(NSString *)chat
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSMutableArray *attributesArray = [[NSMutableArray alloc]init ];

    NSDictionary *elementDict = [element attributes];
    [app.actionDict setValue:[elementDict objectForKey:@"action"] forKey:@"action"];
    for (TFHppleElement *child in [element children])
    {
        NSDictionary *dict = [child attributes];
        NSMutableArray *childArray = [[NSMutableArray alloc]init ];

        for (TFHppleElement *childChild in [child children])
        {
            [childArray addObject:[childChild attributes]];
        }
        [app.actionDict setObject:childArray forKey:@"childArray"];
        if(dict.count >0)
            [attributesArray addObject:dict];
    }
    [app.actionDict setObject:attributesArray forKey:@"attributes"];
    if([element content] != nil)
        [app.actionDict setObject:[element content] forKey:@"content"];
    else
        [app.actionDict setObject:chat forKey:@"content"];

    return ;
}

- (NSMutableDictionary*) analyzeFinishedMatch: (TFHpple *)xpathParser
{
    
    NSMutableDictionary *finishedMatchDict = [[NSMutableDictionary alloc]init];
    
    NSArray *matchHeader  = [xpathParser searchWithXPathQuery:@"//h3"];
    NSMutableString *matchName = [[NSMutableString alloc]init];
    for(TFHppleElement *element in matchHeader)
    {
        for (TFHppleElement *child in element.children)
        {
            [matchName appendString:[child content]];
        }
    }
    [finishedMatchDict setObject:matchName forKey:@"matchName"];
    
    NSArray *winnerHeader  = [xpathParser searchWithXPathQuery:@"//h4"];
    NSMutableString *winnerName = [[NSMutableString alloc]init];
    for(TFHppleElement *element in winnerHeader)
    {
        for (TFHppleElement *child in element.children)
        {
            [winnerName appendString:[child content]];
        }
    }
    [finishedMatchDict setObject:winnerName forKey:@"winnerName"];
    
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr/th"];
    NSMutableArray *elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        [elementArray addObject:[element text]];
    }
    [finishedMatchDict setObject:elementArray forKey:@"matchLength"];

    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr/td"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        [elementArray addObject:[element content]];
    }
    [finishedMatchDict setObject:elementArray forKey:@"matchPlayer"];
    
    // get User url for button
    elementArray = [[NSMutableArray alloc]init];
    for(TFHppleElement *element in elements)
    {
        for (TFHppleElement *child in element.children)
        {
            for (TFHppleElement *childChild in child.children)
            {
                NSDictionary *dict = [childChild attributes];
                NSString *href = [dict objectForKey:@"href"];
                if(href != nil)
                    [elementArray addObject:href];

            }
        }
    }
    [finishedMatchDict setObject:elementArray forKey:@"href"];

    elements  = [xpathParser searchWithXPathQuery:@"//form[1]"];
    elementArray = [[NSMutableArray alloc]init];
    NSMutableArray *attributesArray = [[NSMutableArray alloc]init ];
    NSMutableArray *buttonArray = [[NSMutableArray alloc]init];

    for(TFHppleElement *element in elements)
    {
        [elementArray addObject:[element content]];
        [attributesArray addObject:[element attributes]];
        for (TFHppleElement *child in [element children])
        {
            NSDictionary *dict = [child attributes];
            if([dict objectForKey:@"value"])
                [finishedMatchDict setObject:[dict objectForKey:@"value"] forKey:@"NextButton"];
            for (TFHppleElement *childs in [child children])
            {
                NSDictionary *dict = [childs attributes];
                if([dict objectForKey:@"value"])
                   [buttonArray addObject:dict];
            }
        }
    }
    [finishedMatchDict setObject:buttonArray forKey:@"buttonArray"];

    [finishedMatchDict setObject:elementArray forKey:@"chat"];
    [finishedMatchDict setObject:attributesArray forKey:@"attributes"];
    return finishedMatchDict;
}

- (NSMutableDictionary*) analyzeFinishedMatchReview: (TFHpple *)xpathParser
{
    
    NSMutableDictionary *finishedMatchDict = [[NSMutableDictionary alloc]init];
    
    NSArray *matchHeader  = [xpathParser searchWithXPathQuery:@"//h3"];
    NSMutableString *matchName = [[NSMutableString alloc]init];
    NSMutableString *move = [[NSMutableString alloc]init];
    TFHppleElement *element = matchHeader[0];
    for (TFHppleElement *child in element.children)
    {
        [matchName appendString:[child content]];
    }
    
    [finishedMatchDict setObject:matchName forKey:@"matchName"];
    element = matchHeader[1];
    for (TFHppleElement *child in element.children)
    {
        [move appendString:[child content]];
    }
    
    [finishedMatchDict setObject:move forKey:@"move"];

    NSArray *winnerHeader  = [xpathParser searchWithXPathQuery:@"//h4"];
    NSMutableString *winnerName = [[NSMutableString alloc]init];
    for(TFHppleElement *element in winnerHeader)
    {
        for (TFHppleElement *child in element.children)
        {
            [winnerName appendString:[child content]];
        }
    }
    [finishedMatchDict setObject:winnerName forKey:@"winnerName"];
    
    NSArray *elements = [xpathParser searchWithXPathQuery:@"//table[2]/tr/th"];
    NSMutableArray *elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        [elementArray addObject:[element content]];
    }
    [finishedMatchDict setObject:elementArray forKey:@"matchLength"];

    elements = [xpathParser searchWithXPathQuery:@"//table[2]/tr/td"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        [elementArray addObject:[element content]];
    }
    [finishedMatchDict setObject:elementArray forKey:@"matchPlayer"];
    
    elementArray = [[NSMutableArray alloc]init];
    for(TFHppleElement *element in elements)
    {
        for (TFHppleElement *child in element.children)
        {
            for (TFHppleElement *childChild in child.children)
            {
                NSDictionary *dict = [childChild attributes];
                NSString *href = [dict objectForKey:@"href"];
                if(href != nil)
                    [elementArray addObject:href];

            }
        }
    }
    [finishedMatchDict setObject:elementArray forKey:@"href"];

    elements  = [xpathParser searchWithXPathQuery:@"//form[1]"];
    elementArray = [[NSMutableArray alloc]init];
    NSMutableArray *attributesArray = [[NSMutableArray alloc]init ];
    
    elements  = [xpathParser searchWithXPathQuery:@"//a"];
    NSMutableArray *reviewArray = [[NSMutableArray alloc]initWithCapacity:4];
    for(int i = 0; i < 4; i++)
    {
        reviewArray[i] = @"";
    }
    for(TFHppleElement *element in elements)
    {
        if([[element content] isEqualToString:@"First"])
        {
            reviewArray[0] = [element objectForKey:@"href"];
        }
        if([[element content] isEqualToString:@"Prev"])
        {
            reviewArray[1] = [element objectForKey:@"href"];
        }
        if([[element content] isEqualToString:@"Next"])
        {
            reviewArray[2] = [element objectForKey:@"href"];
        }
        if([[element content] isEqualToString:@"Last"])
        {
            reviewArray[3] = [element objectForKey:@"href"];
        }
        [finishedMatchDict setObject:reviewArray forKey:@"buttonArray"];

        if([[element content] isEqualToString:@"List of Moves"])
        {
            [finishedMatchDict setObject:[element objectForKey:@"href"] forKey:@"List of Moves"];
        }
        if([[element content] isEqualToString:@"Export match"])
        {
            [finishedMatchDict setObject:[element objectForKey:@"href"] forKey:@"Export match"];
        }

    }
    elements  = [xpathParser searchWithXPathQuery:@"//p[3]"];
    for(TFHppleElement *element in elements)
    {
        for (TFHppleElement *child in [element children])
        {
           for (TFHppleElement *childs in [child children])
            {
                NSDictionary *dict = [childs attributes];
                if([dict objectForKey:@"href"])
                    [finishedMatchDict setObject:[dict objectForKey:@"href"] forKey:@"Export match"];
            }
        }
    }

    return finishedMatchDict;
}

- (NSMutableDictionary*) analyzeInvite: (NSString *)htmlString
{
    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData ] ;
    NSMutableDictionary *inviteDict = [[NSMutableDictionary alloc]init];
    
    NSArray *inviteHeader  = [xpathParser searchWithXPathQuery:@"//h3"];
    
    NSMutableString *inviteName = [[NSMutableString alloc]init];
    for(TFHppleElement *element in inviteHeader)
    {
        for (TFHppleElement *child in element.children)
        {
            [inviteName appendString:[child content]];
        }
    }
    [inviteDict setObject:inviteName forKey:@"inviteHeader"];
    
    for(TFHppleElement *element in inviteHeader)
    {
        for (TFHppleElement *child in element.children)
        {
                NSDictionary *dict = [child attributes];
                NSString *href = [dict objectForKey:@"href"];
                if(href != nil)
                    [inviteDict setObject:[href lastPathComponent] forKey:@"user"];
        }
    }


    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//body"];

    NSMutableArray *inviteDetails = [[NSMutableArray alloc]init ];
    for(TFHppleElement *element in elements)
    {
        for (TFHppleElement *child in [element children])
        {
            NSString *text = [child content];
            if(text.length > 1)
                [inviteDetails addObject:text];
        }
    }
    [inviteDict setObject:inviteDetails forKey:@"inviteDetails"];
    
    elements  = [xpathParser searchWithXPathQuery:@"//pre"];
    for(TFHppleElement *element in elements)
    {
        [inviteDict setObject:[element content] forKey:@"inviteComment"];
    }

    elements  = [xpathParser searchWithXPathQuery:@"//form[1]"];
    NSMutableArray *attributesArray = [[NSMutableArray alloc]init ];

    NSDictionary *dict = [[NSDictionary alloc]init];

    for(TFHppleElement *element in elements)
    {
        dict = [element attributes];
    }
    [inviteDict setObject:dict forKey:@"AcceptButton"];

    elements  = [xpathParser searchWithXPathQuery:@"//form[2]"];
    attributesArray = [[NSMutableArray alloc]init ];
    
    for(TFHppleElement *element in elements)
    {
        dict = [element attributes];
    }
    [inviteDict setObject:dict forKey:@"DeclineButton"];

    return inviteDict;
}

@end
