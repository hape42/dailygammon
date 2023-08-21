//
//  Match.m
//  DailyGammon
//
//  Created by Peter on 16.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "Match.h"
#import "TFHpple.h"

@interface Match ()

@end

@implementation Match

@synthesize noBoard;

-(NSMutableDictionary *) readMatch:(NSString *)matchLink reviewMatch:(BOOL)isReview
{
    noBoard = FALSE;
    int tableToAnalyze = 1;
    if(isReview)
        tableToAnalyze = 2;
    NSMutableDictionary *boardDict = [[NSMutableDictionary alloc]init];
    
#pragma mark - matchName
    NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",matchLink]];
//    XLog(@"%@",urlMatch);
    NSData *matchHtmlData = [NSData dataWithContentsOfURL:urlMatch];
    NSError *error = nil;
//    NSStringEncoding encoding = 0;
//    NSString *matchString = [[NSString alloc] initWithContentsOfURL:urlMatch
//                                                       usedEncoding:&encoding
//                                                              error:&error];
    if(error)
        XLog(@"error %@ %@",error ,urlMatch);
    
//    NSData *data = [NSData dataWithContentsOfURL:urlMatch];
    
    // wie bekomme ich nur sauber die Sonderzeichen gelesen???
//    NSString *htmlString = [NSString stringWithUTF8String:[data bytes]];
    NSString *htmlString = [[NSString alloc]
              initWithData:matchHtmlData encoding: NSISOLatin1StringEncoding];
    
    if ([htmlString rangeOfString:@"<TD ALIGN=CENTER>13</TD>"].location == NSNotFound)
    {
        noBoard = TRUE;
        [boardDict setObject:htmlString forKey:@"htmlString"];
        [boardDict setObject:@"NoBoard" forKey:@"NoBoard"];
 //       return boardDict;
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
//    if ([htmlString rangeOfString:@"<u>Score</u>"].location != NSNotFound)
//    {
//        XLog(@" <u>Score</u>> %@", urlMatch);
//        htmlString = [self skipNext:htmlString];
//    }
    if ([htmlString rangeOfString:@"Welcome to DailyGammon"].location != NSNotFound)
    {
        XLog(@"Welcome to DailyGammon %@", urlMatch);
        [boardDict setObject:@"TopPage" forKey:@"TopPage"];
//        return boardDict;
    }
    if ([htmlString rangeOfString:@"invites you to play"].location != NSNotFound)
    {
        XLog(@"invites you to play %@", urlMatch);
        [boardDict setObject:@"Invite" forKey:@"Invite"];
        [boardDict setObject:[self analyzeInvite:htmlString] forKey:@"inviteDict"];
//        return boardDict;
    }
//    htmlString = @"DailyGammon Backups";
    if ([htmlString rangeOfString:@"DailyGammon Backups"].location != NSNotFound)
    {
        XLog(@"invites you to play %@", urlMatch);
        [boardDict setObject:@"Backups" forKey:@"Backups"];
 //       return boardDict;
    }

    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:matchHtmlData ] ;
    
    xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData ] ;

    [boardDict setObject:htmlData forKey:@"htmlData"];
    [boardDict setObject:htmlString forKey:@"htmlString"];

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
                    [boardDict setObject:finishedMatchDict forKey:@"finishedMatch"];
                    
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
    }

#pragma mark - The http request you submitted was in error.
    NSString *errorText = @"";
    if ([htmlString rangeOfString:@"The http request you submitted was in error."].location != NSNotFound)
    {
        errorText = @"The http request you submitted was in error.";
        [boardDict setObject:errorText forKey:@"error"];
        noBoard = TRUE;

  //      return boardDict;
    }
//
#pragma mark - There has been an internal error.
    if ([htmlString rangeOfString:@"There has been an internal error. "].location != NSNotFound)
    {
        errorText = @"The http request you submitted was in error.";
        [boardDict setObject:@"There has been an internal error. " forKey:@"internal error"];
        noBoard = TRUE;

        return boardDict;
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
    [boardDict setObject:matchName forKey:@"matchName"];
    [boardDict setObject:chat forKey:@"chat"];
    
#pragma mark -     You have received the following telegram message:
//    [boardDict setObject:@"You have received the following telegram message:" forKey:@"message"];
//    [boardDict setObject:@"!DailyGammon is pleased to announce that the Three Pointer #3317 tournament has begun.  Good luck!" forKey:@"chat"];
    if ([htmlString rangeOfString:@"telegram"].location != NSNotFound)
    {
        [boardDict setObject:@"You have received the following telegram message:" forKey:@"message"];
        NSArray *matchHeader  = [xpathParser searchWithXPathQuery:@"//pre"];
        for(TFHppleElement *element in matchHeader)
        {
            [boardDict setObject:[element content] forKey:@"chat"];
        }
//        return boardDict;
    }
    
#pragma mark - You have received the following quick message from

    if ([htmlString rangeOfString:@"You have received the following quick message from"].location != NSNotFound)
    {
        NSArray *matchHeader  = [xpathParser searchWithXPathQuery:@"//h3"];
        for(TFHppleElement *element in matchHeader)
        {
            [boardDict setObject:[element content] forKey:@"quickMessage"];
        }
        matchHeader  = [xpathParser searchWithXPathQuery:@"//pre"];
        for(TFHppleElement *element in matchHeader)
        {
            [boardDict setObject:[element content] forKey:@"chat"];
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

        [boardDict setObject:messageDict forKey:@"messageDict"];
        
   //     return boardDict;
    }
    if ([htmlString rangeOfString:@"Your message has been sent"].location != NSNotFound)
    {
        [boardDict setObject:@"sent" forKey:@"messageSent"];
        return boardDict;
    }
#pragma mark - unexpected Move
    NSString *unexpectedMove = @"";
    if ([htmlString rangeOfString:@"unexpected"].location != NSNotFound)
        unexpectedMove = @"Your opponent made an unexpected move, and the game has been rolled back to that point.";
    [boardDict setObject:unexpectedMove forKey:@"unexpectedMove"];

#pragma mark - There are no matches where you can move.
    if ([htmlString rangeOfString:@"There are no matches where you can move."].location != NSNotFound)
    {
        [boardDict setObject:@"noMatches" forKey:@"noMatches"];
        noBoard = TRUE;

 //       return boardDict;
    }

    // prüfen ob jetzt tatsächlich ein Board abgearbeitet wird, oder ob noch etwas unvorhergesehenes passiert
#pragma mark - unbekanntes HTML.
    if ([htmlString rangeOfString:@"Review Game"].location == NSNotFound)
    {
 //       [boardDict setObject:htmlString forKey:@"unknown"];
 //       return boardDict;
    }
// hier könnte ein return boardDict kommen, wenn noBoard == True 🤔
    if(noBoard)
        return boardDict;
#pragma mark - obere Nummern Reihe
    NSArray *elements  = [xpathParser searchWithXPathQuery:[NSString stringWithFormat: @"//table[%d]/tr[1]/td",tableToAnalyze]];
    NSMutableArray *elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        [elementArray addObject:[element text]];
    }
    [boardDict setObject:elementArray forKey:@"nummernOben"];
    
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
    [boardDict setObject:elementArray forKey:@"grafikOben"];
    
#pragma mark - opponent
    elements  = [xpathParser searchWithXPathQuery:[NSString stringWithFormat:@"//table[%d]/tr[2]/td[17]",tableToAnalyze]];
    elementArray = [[NSMutableArray alloc]init];
    NSString *opponentID = @"";
    for(TFHppleElement *element in elements)
    {
        [boardDict setObject:[[element attributes] objectForKey:@"bgcolor"] forKey:@"opponentColor"];

        for (TFHppleElement *child in element.children)
        {
            [elementArray addObject:[child content]];
            if([[[child attributes] objectForKey:@"href"] length] > 0)
                opponentID = [[[child attributes] objectForKey:@"href"]lastPathComponent];
        }
    }
    [boardDict setObject:elementArray forKey:@"opponent"];
    [boardDict setObject:opponentID forKey:@"opponentID"];

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
    [boardDict setObject:elementArray forKey:@"moveIndicatorOben"];
    
#pragma mark - Würfel Reihe
    elements  = [xpathParser searchWithXPathQuery:[NSString stringWithFormat:@"//table[%d]/tr[4]/td",tableToAnalyze]];
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
    [boardDict setObject:elementArray forKey:@"moveIndicatorUnten"];
    
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
    [boardDict setObject:elementArray forKey:@"grafikUnten"];
    
#pragma mark - player
    elements  = [xpathParser searchWithXPathQuery:[NSString stringWithFormat:@"//table[%d]/tr[6]/td[17]",tableToAnalyze]];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        [boardDict setObject:[[element attributes] objectForKey:@"bgcolor"] forKey:@"playerColor"];

        for (TFHppleElement *child in element.children)
        {
            [elementArray addObject:[child content]];
        }
    }
    [boardDict setObject:elementArray forKey:@"player"];
    
#pragma mark - untere Nummern Reihe
    elements  = [xpathParser searchWithXPathQuery:[NSString stringWithFormat:@"//table[%d]/tr[7]/td",tableToAnalyze]];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        if([element text] != nil)
            [elementArray addObject:[element text]];
    }
    [boardDict setObject:elementArray forKey:@"nummernUnten"];
    
    return boardDict;
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
-(NSMutableDictionary *) readActionForm:(NSData *)htmlData withChat:(NSString *)chat
{
    NSMutableDictionary *actionDict = [[NSMutableDictionary alloc]init];
    NSMutableArray *attributesArray = [[NSMutableArray alloc]init ];
  //  NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",matchLink]];
    
//    NSData *matchHtmlData = [NSData dataWithContentsOfURL:urlMatch];
    
    // vv nur zum testen um zu sehen, warum es immer wieder unbekannte action gibt
//    NSString *htmlString = [[NSString alloc] initWithData:matchHtmlData encoding: NSISOLatin1StringEncoding];
//    [actionDict setObject:htmlString forKey:@"htmlString"];
    // ^^
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//form[1]"];
    [actionDict setObject:elements forKey:@"elements"];

    for(TFHppleElement *element in elements)
    {
        if([[element raw] rangeOfString:@"textarea"].location != NSNotFound)
        {
            //NSArray *pre  = [xpathParser searchWithXPathQuery:@"//pre"];
            actionDict = [self analyzeChat:element withChat:chat];
        }
        else
        {
            NSDictionary *elementDict = [element attributes];
            [actionDict setValue:[elementDict objectForKey:@"action"] forKey:@"action"];
            for (TFHppleElement *child in [element children])
            {
                NSDictionary *dict = [child attributes];
                if([dict objectForKey:@"value"])
                    [attributesArray addObject:dict];
            }
            [actionDict setObject:attributesArray forKey:@"attributes"];
            [actionDict setObject:[element content] forKey:@"content"];
        }
    }

    elements  = [xpathParser searchWithXPathQuery:@"//h4"];
    for(TFHppleElement *element in elements)
    {
        [actionDict setObject:[element content] forKey:@"Message"];
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
            [actionDict setObject:[element objectForKey:@"href"] forKey:@"SkipGame"];
        }
        if([[element content] isEqualToString:@"Swap Dice"])
        {
            [actionDict setObject:[element objectForKey:@"href"] forKey:@"SwapDice"];
        }
        if([[element content] isEqualToString:@"Undo Move"])
        {
            [actionDict setObject:[element objectForKey:@"href"] forKey:@"UndoMove"];
        }
        if([[element content] isEqualToString:@"Next Game>&gt"])
        {
            [actionDict setObject:[element objectForKey:@"href"] forKey:@"Next Game>>"];
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
            [actionDict setObject:[element objectForKey:@"href"] forKey:@"List of Moves"];
        }
    }
    [actionDict setObject:elements forKey:@"a"];
    [actionDict setObject:reviewArray forKey:@"review"];

    return actionDict;

}

- (NSMutableDictionary *) analyzeChat:(TFHppleElement *)element withChat:(NSString *)chat
{
    NSMutableDictionary *actionDict = [[NSMutableDictionary alloc]init];
    NSMutableArray *attributesArray = [[NSMutableArray alloc]init ];

    NSDictionary *elementDict = [element attributes];
    [actionDict setValue:[elementDict objectForKey:@"action"] forKey:@"action"];
    for (TFHppleElement *child in [element children])
    {
        NSDictionary *dict = [child attributes];
        NSMutableArray *childArray = [[NSMutableArray alloc]init ];

        for (TFHppleElement *childChild in [child children])
        {
            [childArray addObject:[childChild attributes]];
        }
        [actionDict setObject:childArray forKey:@"childArray"];
        if(dict.count >0)
            [attributesArray addObject:dict];
    }
    [actionDict setObject:attributesArray forKey:@"attributes"];
    if([element content] != nil)
        [actionDict setObject:[element content] forKey:@"content"];
    else
        [actionDict setObject:chat forKey:@"content"];

    return actionDict;
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

    elements  = [xpathParser searchWithXPathQuery:@"//form[1]"];
    elementArray = [[NSMutableArray alloc]init];
    NSMutableArray *attributesArray = [[NSMutableArray alloc]init ];

    for(TFHppleElement *element in elements)
    {
        [elementArray addObject:[element content]];
        [attributesArray addObject:[element attributes]];
        for (TFHppleElement *child in [element children])
        {
            NSDictionary *dict = [child attributes];
            if([dict objectForKey:@"value"])
                [finishedMatchDict setObject:[dict objectForKey:@"value"] forKey:@"NextButton"];
        }

        XLog(@"%@",[element content]);
    }
    [finishedMatchDict setObject:elementArray forKey:@"chat"];
    [finishedMatchDict setObject:attributesArray forKey:@"attributes"];
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
