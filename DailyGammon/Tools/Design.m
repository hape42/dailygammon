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
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
        return [self makeNiceFlatButton:button];
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
    [button setTitleColor:GRAYLIGHT forState:UIControlStateNormal];
    
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

- (UILabel *) makeNiceLabel: (UILabel*)label
{
    label.font = [UIFont fontWithName:@"System Bold" size:14];
    //    label.textColor = WEBSITEGREEN;
    label.textAlignment = NSTextAlignmentLeft;
    
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
       }
            break;

        default:
            break;
    }
    return schemaDict;
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
                
            case 1920:
            case 2208:
                //return @"iPhone 6+/6S+/7+/8+";
                return FALSE;
                break;
                
            case 2436:
                //return @"iPhone X, XS";
                return TRUE;
                break;
                
            case 2688:
                //return @"iPhone XS Max";
                return TRUE;
                break;
                
            case 1792:
                //return @"iPhone XR";
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
