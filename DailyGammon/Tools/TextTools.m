//
//  TextTools.m
//  DailyGammon
//
//  Created by Peter Schneider on 15.04.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import "TextTools.h"

@implementation TextTools

#pragma mark - methods for outgoing texts


#pragma mark - methods for incoming texts


#pragma mark - general methods

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
         else if([substring isEqualToString:@"&"])
             str = [NSString stringWithFormat:@"%@%@",str, @"+"];
         else if([substring isEqualToString:@"ß"])
             str = [NSString stringWithFormat:@"%@%@",str, @"ss"];
         else
             str = [NSString stringWithFormat:@"%@%@",str, substring];
         
     }];
    
    //return chatString;
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


    // dadurch wird ein Emoji im Format &#128514; in 😂 gewandelt. die Webseite liefert &#128514; wenn 😂 eingegeben wird
//    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
//
//    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
//
//    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:data
//                                                                             options:options
//                                                                  documentAttributes:nil
//                                                                               error:nil];
//    str = [attributedString string];

    NSString *encodedString = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    encodedString = str;
    return encodedString;
}

#pragma mark - only for internal tests

-(void)testingTools
{
    /*
     
    ein Text mit emojis muss übersetzt werden, aber auch der Rückweg wird benötigt. vom Server kommen die  &#..... , der server übersetzt emoji in &#...
     Einfaches Beispiel:
     " test 😂 test" <-> " test &#128514; test"
     
     Komplexeres Beispiel:
     " test 😵‍💫🥶🤌🏼 test" <-> " test &#128565;&#8205;&#128171;&#129398;&#129292;&#127996; test"

     */
    NSString *originalString = @"Da hast Du aber sehr viel Glück gehabt 😂 , aber du hast auch gut gespielt 😎 !";

    // Wandele den Originaltext in HTML-Entitäten um
    NSString *htmlString = [self convertStringToHTML:originalString];

    NSLog(@"HTML-Entitätsmodifizierter String: %@", htmlString);
}
- (NSString *)convertStringToHTML:(NSString *)stringWithEmoji
{
    
    NSString *unicodeString = @"Glück gehabt 😂 und gut gespielt 😎";
//    NSMutableString *result = [NSMutableString new];
//    for (NSUInteger index = 0; index < unicodeString.length; index++)
//    {
//        NSString *subStr = [unicodeString substringWithRange:NSMakeRange(index, 1)];
//        if (subStr.UTF8String != NULL && strlen(subStr.UTF8String) <= 1)
//        {
//            [result appendString:subStr];
//        }
//        else
//        {
//            unichar uniChar = [subStr characterAtIndex:0];
//            NSString *unicodeHex = [NSString stringWithFormat:@"\\U%04x", uniChar].uppercaseString;
//            [result appendString:unicodeHex];
//        }
//    }
    
    
    NSMutableString* const result = [NSMutableString stringWithCapacity:0];
    NSUInteger const len = unicodeString.length;
    NSString* subStr;
    for (NSUInteger index = 0; index < len; index++) 
    {
        subStr = [unicodeString substringWithRange:NSMakeRange(index, 1)];
        const char* utf8Rep = subStr.UTF8String;  // will return NULL for icons that consist of 2 chars
        if (utf8Rep != NULL) 
        {
            unsigned long const length = strlen(utf8Rep);
            if (length <= 2) 
            {
                [result appendString:subStr];
            }
        }
        else
        {
            XLog(@"gefunden %lu %@ %@",(unsigned long)index, subStr, [unicodeString substringWithRange:NSMakeRange(index, 2)]);
            NSString *encoded = [self convertEmojiToHTMLEntity:[unicodeString substringWithRange:NSMakeRange(index, 2)]];
            index++;
        }

    }
    NSLog(@"Result: %@", result);

    return result;

    NSMutableString *htmlString = [NSMutableString string];
    // Durchlaufe den Text und identifiziere jeden Zeichenblock
    NSRange range = NSMakeRange(0, [stringWithEmoji length]);
    while (range.location != NSNotFound)
    {
        // Suche nach dem nächsten Zeichenblock
        NSRange startRange = [stringWithEmoji rangeOfComposedCharacterSequencesForRange:range];
        
        // Wenn kein weiterer Zeichenblock gefunden wurde, beende die Schleife
        if (startRange.location == NSNotFound) 
        {
            break;
        }
        
        // Extrahiere den Zeichenblock
        NSString *characterBlock = [stringWithEmoji substringWithRange:startRange];
        
        // Wandele den Zeichenblock in seine HTML-Entität um und füge ihn zum HTML-String hinzu
        NSString *encodedBlock = [self encodeStringToHTML:characterBlock];
        [htmlString appendString:encodedBlock];
        
        // Aktualisiere den Bereich, um nach dem nächsten Zeichenblock zu suchen
        range.location = NSMaxRange(startRange);
        range.length = [stringWithEmoji length] - range.location;
    }
    
    return htmlString;
}

- (NSString *)encodeStringToHTML:(NSString *)string 
{
    // Erstelle ein NSAttributedString aus dem Zeichenblock
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string];
    
    // Wandele das NSAttributedString in seine HTML-Entität um
    NSData *htmlData = [attributedString dataFromRange:NSMakeRange(0, attributedString.length) documentAttributes:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} error:nil];
    
    // Extrahiere den HTML-String aus dem NSData
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    
    return htmlString;
}

- (NSString *)encodeHTMLtoString:(NSString *)htmlString
{
    // Erstelle ein NSAttributedString aus der HTML-Entität
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    // Extrahiere den NSString aus dem NSAttributedString
    NSString *unicodeString = [attributedString string];
    
    NSLog(@"Unicode-String: %@", unicodeString);
    return unicodeString;
}



- (NSString *)convertEmojiToHTMLEntity:(NSString *)emoji {
    NSMutableString *htmlEntity = [NSMutableString string];
    
    // Zerlege das Emoji in seine Unicode-Zeichenpunkte
    NSString *pattern = @"\\p{Emoji_Presentation}";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:emoji options:0 range:NSMakeRange(0, emoji.length)];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match range];
        NSString *character = [emoji substringWithRange:range];
        
        // Wandele das Emoji in seine Unicode-Zahlenpunkte um
        NSUInteger unicodePoint = [self utf8StringToUnicode:character.UTF8String];
        if (unicodePoint != NSNotFound) {
            // Konvertiere den Unicode-Zahlenpunkt in seine HTML-Entität
            NSString *entity = [NSString stringWithFormat:@"&#%lu;", (unsigned long)unicodePoint];
            [htmlEntity appendString:entity];
        }
    }
    
    return htmlEntity;
}

- (NSUInteger)utf8StringToUnicode:(const char *)utf8String {
    // Konvertiere das UTF-8-Zeichen in seine Unicode-Zahl
    NSUInteger unicodePoint = 0;
    sscanf(utf8String, "%lx", &unicodePoint);
    return unicodePoint;
} 
@end

