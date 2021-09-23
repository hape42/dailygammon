//
//  Design.m
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "Design.h"

@implementation Design


-(UIButton *) makeNiceButton: (UIButton *)button
{

//    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
//        return [self makeNiceFlatButton:button];
    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;
        
    button.layer.cornerRadius = 14.0f;
    button.layer.masksToBounds = YES;
    
    switch (boardSchema)
    {
        case 1:
            [button setBackgroundImage:[UIImage imageNamed:@"button_gruen.png"] forState:UIControlStateNormal];
            break;
        case 2:
            [button setBackgroundImage:[UIImage imageNamed:@"button_gruen.png"] forState:UIControlStateNormal];
            break;
        case 3:
            [button setBackgroundImage:[UIImage imageNamed:@"button_blau.png"] forState:UIControlStateNormal];
            break;
        case 4:
            [button setBackgroundImage:[UIImage imageNamed:@"button_rot.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    [button setBackgroundImage:[UIImage imageNamed:@"button_grau.png"] forState:UIControlStateNormal];

    NSMutableDictionary *schemaDict = [self schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];

    [button setTitleColor:[schemaDict objectForKey:@"TintColor"] forState:UIControlStateNormal];
    
    button.titleLabel.numberOfLines = 1;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.lineBreakMode = NSLineBreakByClipping; // <-- MAGIC LINE

    return button;
}

-(UIButton *) makeNiceFlatButton: (UIButton *)button
{
    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;
    NSMutableDictionary *schemaDict = [self schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];

    button.layer.cornerRadius = 10.0f;
    button.layer.masksToBounds = YES;
    
    button.layer.borderWidth = 1;
    button.layer.borderColor = [[schemaDict objectForKey:@"TintColor"]CGColor];
    button.tintColor = [schemaDict objectForKey:@"TintColor"];
    
    if([button.titleLabel.text isEqualToString:@"Cancel"])
    {
        button.backgroundColor = [schemaDict objectForKey:@"TintColor"];
        button.tintColor = [UIColor whiteColor];
    }
    return button;
}

-(UIBarButtonItem *) makeNiceBarButton: (UIBarButtonItem *)button
{
    button.customView.layer.cornerRadius = 14.0f;
    button.customView.layer.masksToBounds = YES;
    button.customView.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1];
    [button.customView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    //    button.imageView.layer.cornerRadius = 14.0f;
    button.customView.layer.shadowRadius = .0f;
    button.customView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    button.customView.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    button.customView.layer.shadowOpacity = 0.5f;
    button.customView.layer.masksToBounds = NO;
    
    return button;
}

- (UITableViewCell *) makeNiceCell: (UITableViewCell*)cell
{
    cell.layer.cornerRadius = 10.0f;
    cell.layer.masksToBounds = NO;
    cell.layer.borderWidth = .5f;
    
    return cell;
}
#pragma mark - label

- (UILabel *) makeSortLabel: (UILabel*)label sortOrderDown: (BOOL) down
{
    if(label.text == nil) return label;

    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;
    
    NSMutableDictionary *schemaDict = [self schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];

    //https://stackoverflow.com/questions/28427935/how-can-i-change-image-tintcolor
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    UIImage *pfeil = (down) ? [UIImage imageNamed:@"PfeilDown.png"] : [UIImage imageNamed:@"PfeilUp.png"];
    UIImage *newImage = [pfeil imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(pfeil.size, NO, newImage.scale);
    UIColor *myTintColor = [schemaDict objectForKey:@"TintColor"];
    [myTintColor set];
    [newImage drawInRect:CGRectMake(0, 0, pfeil.size.width, newImage.size.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    imageAttachment.image = newImage;
    CGFloat imageOffsetY = 0.0;
    CGFloat imageOffsetX = -3.0;

    imageAttachment.bounds = CGRectMake(imageOffsetX, imageOffsetY, imageAttachment.image.size.width, imageAttachment.image.size.height);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText= [[NSMutableAttributedString alloc] initWithString:@""];
    [completeText appendAttributedString:attachmentString];
    if(label.text == nil) label.text = @"?";
    NSMutableAttributedString *textAfterIcon= [[NSMutableAttributedString alloc] initWithString:label.text];
    [completeText appendAttributedString:textAfterIcon];
//    label.textAlignment = NSTextAlignmentCenter;
    label.attributedText = completeText;
    label.textColor = [schemaDict objectForKey:@"TintColor"];
    label.tintColor = [schemaDict objectForKey:@"TintColor"];

    return label;
}

- (UILabel *) makeNiceLabel: (UILabel*)label
{
    [label setFont:[label.font fontWithSize: 50]];
    label.adjustsFontSizeToFitWidth = YES;
    label.numberOfLines = 0;
    label.minimumScaleFactor = 0.1;

    return label;
}

- (UILabel *) makeLabelColor: (UILabel*)label forColor: (NSString *)color forPlayer:(BOOL)player
{
    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;

    NSMutableDictionary *schemaDict = [self schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];

    int sameColor = [[[NSUserDefaults standardUserDefaults] valueForKey:@"sameColor"]intValue];
    bool myColorB = FALSE;
    
    if(sameColor == 1)
        myColorB = TRUE;
    else
        myColorB = FALSE;

    if([color isEqualToString:@"#3399CC"] || [color isEqualToString:@"#9999FF"])
    {
        label.backgroundColor = [schemaDict objectForKey:@"labelColor1"];
        label.textColor = [schemaDict objectForKey:@"labelTextColor1"];
        if(sameColor)
        {
            if(player)
            {
                if(!myColorB)
                {
                    label.backgroundColor = [schemaDict objectForKey:@"labelColor2"];
                    label.textColor = [schemaDict objectForKey:@"labelTextColor2"];
                }
            }
            else
            {
                if(myColorB)
                {
                    label.backgroundColor = [schemaDict objectForKey:@"labelColor2"];
                    label.textColor = [schemaDict objectForKey:@"labelTextColor2"];
                }
            }
        }
    }
    if([color isEqualToString:@"#FFFFFF"] || [color isEqualToString:@"#FFFF66"])
    {
        label.backgroundColor = [schemaDict objectForKey:@"labelColor2"];
        label.textColor = [schemaDict objectForKey:@"labelTextColor2"];
        if(sameColor)
        {
            if(player)
            {
                if(myColorB)
                {
                    label.backgroundColor = [schemaDict objectForKey:@"labelColor1"];
                    label.textColor = [schemaDict objectForKey:@"labelTextColor1"];
                }
            }
            else
            {
                if(!myColorB)
                {
                    label.backgroundColor = [schemaDict objectForKey:@"labelColor1"];
                    label.textColor = [schemaDict objectForKey:@"labelTextColor1"];
                }
            }
        }
    }

//    label.layer.borderWidth = 1;
//    label.layer.borderColor = [label.textColor CGColor];
    
    return label;
}
- (UILabel *) makeNiceTextField: (UILabel*)text
{
    text.font = [UIFont fontWithName:@"Helvetica" size:12];
    text.textColor = [UIColor blackColor];
    text.textAlignment = NSTextAlignmentLeft;
    
    return text;
}

#pragma mark - Schema
-(NSMutableDictionary *)schema:(int)nummer
{
    NSMutableDictionary *schemaDict = [[NSMutableDictionary alloc]init];
    
    switch (nummer)
    {
        case 1:
        {
            UIColor *schemaColor = [UIColor colorWithRed:255.0/255 green:254.0/255 blue:209.0/255 alpha:1];
            [schemaDict setObject:schemaColor forKey:@"BoardSchemaColor"];
            
            UIColor *randColor = [UIColor colorWithRed:63.0/255 green:148.0/255 blue:104.0/255 alpha:1];
            [schemaDict setObject:randColor forKey:@"RandSchemaColor"];
            [schemaDict setObject:[UIColor blackColor] forKey:@"barMittelstreifenColor"];
            [schemaDict setObject:[UIColor blackColor] forKey:@"nummerColor"];
            [schemaDict setObject:HEADERBACKGROUNDCOLOR forKey:@"TintColor"];
            
            [schemaDict setObject:[UIColor colorWithRed:0.0/255 green:33.0/255 blue:188.0/255 alpha:1] forKey:@"labelColor1"];
            [schemaDict setObject:[UIColor whiteColor] forKey:@"labelTextColor1"];
            
            [schemaDict setObject:[UIColor colorWithRed:248.0/255 green:195.0/255 blue:69.0/255 alpha:1] forKey:@"labelColor2"];
            [schemaDict setObject:[UIColor blackColor] forKey:@"labelTextColor2"];

        }
            break;
        case 2:
        {
            UIColor *schemaColor = [UIColor colorWithRed:255.0/255 green:254.0/255 blue:209.0/255 alpha:1];
            [schemaDict setObject:schemaColor forKey:@"BoardSchemaColor"];
            
            UIColor *randColor = [UIColor colorWithRed:63.0/255 green:148.0/255 blue:104.0/255 alpha:1];
            [schemaDict setObject:randColor forKey:@"RandSchemaColor"];
            [schemaDict setObject:[UIColor blackColor] forKey:@"barMittelstreifenColor"];
            [schemaDict setObject:[UIColor blackColor] forKey:@"nummerColor"];
            [schemaDict setObject:HEADERBACKGROUNDCOLOR forKey:@"TintColor"];
            
            [schemaDict setObject:[UIColor colorWithRed:0.0/255 green:33.0/255 blue:188.0/255 alpha:1] forKey:@"labelColor1"];
            [schemaDict setObject:[UIColor whiteColor] forKey:@"labelTextColor1"];
            
            [schemaDict setObject:[UIColor colorWithRed:248.0/255 green:195.0/255 blue:69.0/255 alpha:1] forKey:@"labelColor2"];
            [schemaDict setObject:[UIColor blackColor] forKey:@"labelTextColor2"];

        }
            break;
        case 3:
        {
            UIColor *schemaColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1];
            [schemaDict setObject:schemaColor forKey:@"BoardSchemaColor"];

            UIColor *randColor = [UIColor colorWithRed:142.0/255 green:142.0/255 blue:142.0/255 alpha:1];
            [schemaDict setObject:randColor forKey:@"RandSchemaColor"];
            [schemaDict setObject:[UIColor blackColor] forKey:@"barMittelstreifenColor"];
            [schemaDict setObject:[UIColor blackColor] forKey:@"nummerColor"];
            schemaColor = [UIColor colorWithRed:32.0/255 green:102.0/255 blue:194.0/255 alpha:1];
            [schemaDict setObject:schemaColor forKey:@"TintColor"];
            schemaColor = [UIColor colorWithRed:179.0/255 green:83.0/255 blue:80.0/255 alpha:1];
            [schemaDict setObject:schemaColor forKey:@"ButtonSchattenColor"];

            [schemaDict setObject:[UIColor colorWithRed:32.0/255 green:104.0/255 blue:197.0/255 alpha:1] forKey:@"labelColor1"];
            [schemaDict setObject:[UIColor whiteColor] forKey:@"labelTextColor1"];
            
            [schemaDict setObject:[UIColor whiteColor] forKey:@"labelColor2"];
            [schemaDict setObject:[UIColor colorWithRed:32.0/255 green:104.0/255 blue:197.0/255 alpha:1] forKey:@"labelTextColor2"];

        }
            break;
      case 4:
        {
            [schemaDict setObject:[UIColor lightGrayColor] forKey:@"BoardSchemaColor"];
            
            [schemaDict setObject:[UIColor grayColor] forKey:@"RandSchemaColor"];
            [schemaDict setObject:[UIColor darkGrayColor] forKey:@"barMittelstreifenColor"];
            [schemaDict setObject:[UIColor lightGrayColor] forKey:@"nummerColor"];
           
            UIColor *schemaColor = [UIColor colorWithRed:165.0/255 green:46.0/255 blue:40.0/255 alpha:1];
            [schemaDict setObject:schemaColor forKey:@"TintColor"];
            schemaColor = [UIColor colorWithRed:179.0/255 green:83.0/255 blue:80.0/255 alpha:1];
            [schemaDict setObject:schemaColor forKey:@"ButtonSchattenColor"];
            
            [schemaDict setObject:[UIColor colorWithRed:43.0/255 green:43.0/255 blue:43.0/255 alpha:1] forKey:@"labelColor1"];
            [schemaDict setObject:[UIColor whiteColor] forKey:@"labelTextColor1"];
            
            [schemaDict setObject:[UIColor colorWithRed:166.0/255 green:46.0/255 blue:40.0/255 alpha:1] forKey:@"labelColor2"];
            [schemaDict setObject:[UIColor whiteColor] forKey:@"labelTextColor2"];
       }
            break;

        default:
            break;
    }
    return schemaDict;
}

- (NSString *)changeCheckerColor:(NSString *)imgName forColor: (NSString *)color
{
    int sameColor = [[[NSUserDefaults standardUserDefaults] valueForKey:@"sameColor"]intValue];
    if(!sameColor)
        return imgName;

    bool myColorB = FALSE;
    
    if(sameColor == 1)
        myColorB = TRUE;
    else
        myColorB = FALSE;

    if([color isEqualToString:@"#3399CC"] || [color isEqualToString:@"#9999FF"])
    {
        // dailygammon liefert mir B als color
        if(myColorB)
        {
            return imgName;
        }
        else
        {
            // ausgespielte checker haben auch ein _b, das verkompliziert alles. kurz umbenennen
            if([imgName rangeOfString:@"_bot"].location != NSNotFound)
            {
                imgName = [imgName stringByReplacingOccurrencesOfString:@"_bot" withString:@"_unten"];
            }

            // _b muss zu _y und umgekehrt
            if([imgName rangeOfString:@"_b"].location != NSNotFound)
            {
                imgName = [imgName stringByReplacingOccurrencesOfString:@"_b" withString:@"_y"];
            } else
            if([imgName rangeOfString:@"_y"].location != NSNotFound)
            {
                imgName = [imgName stringByReplacingOccurrencesOfString:@"_y" withString:@"_b"];
            }
            if([imgName rangeOfString:@"_unten"].location != NSNotFound)
            {
                imgName = [imgName stringByReplacingOccurrencesOfString:@"_unten" withString:@"_bot"];
            }

        }
        return imgName;
        //XLog(@"b %@ %@",imgName, color);
    }
    if([color isEqualToString:@"#FFFFFF"] || [color isEqualToString:@"#FFFF66"])
    {
        // dailygammon liefert mir Y als color
        if(!myColorB)
        {
            return imgName;
        }
        else
        {
            // ausgespielte checker haben auch ein _b, das verkompliziert alles. kurz umbenennen
            if([imgName rangeOfString:@"_bot"].location != NSNotFound)
            {
                imgName = [imgName stringByReplacingOccurrencesOfString:@"_bot" withString:@"_unten"];
            }

            // _b muss zu _y und umgekehrt
            if([imgName rangeOfString:@"_b"].location != NSNotFound)
            {
                imgName = [imgName stringByReplacingOccurrencesOfString:@"_b" withString:@"_y"];
            } else
            if([imgName rangeOfString:@"_y"].location != NSNotFound)
            {
                imgName = [imgName stringByReplacingOccurrencesOfString:@"_y" withString:@"_b"];
            }
            if([imgName rangeOfString:@"_unten"].location != NSNotFound)
            {
                imgName = [imgName stringByReplacingOccurrencesOfString:@"_unten" withString:@"_bot"];
            }

            return imgName;
        }
        //XLog(@"y %@ %@",imgName, color);
    }
    //XLog(@"? %@ %@",imgName, color);
    return imgName;
}
- (BOOL)isX
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height)
        {
            case 1136:
                //return @"iPhone 5 or 5S or 5C";
                return FALSE;
                break;
                
            case 1334:
                //return @"iPhone 6/6S/7/8";
                return FALSE;
                break;
            case 1792:
                //return @"iPhone 11, XR";
                return FALSE;
                break;

            case 1920:
            case 2208:
                //return @"iPhone 6+/6S+/7+/8+";
                return FALSE;
                break;
                
            case 2436:
                //return @"iPhone X, XS, 11 Pro, 12 mini";
                return TRUE;
                break;
 
            case 2532:
                //return @"iPhone 12, 12 Pro";
                return TRUE;
                break;

            case 2688:
                //return @"iPhone XS Max, 11 Pro max";
                return TRUE;
                break;
                
            case 2778:
                //return @"iPhone 12 Pro Max";
                return TRUE;
                break;

            default:
                return FALSE;
                break;
        }
    }
    return FALSE;
    
}
@end
