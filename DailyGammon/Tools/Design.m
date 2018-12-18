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
    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;
    
    NSMutableDictionary *schemaDict = [self schema:boardSchema];

    UIColor *buttonColor = [schemaDict objectForKey:@"TintColor"];
    
    button.layer.cornerRadius = 14.0f;
    button.layer.masksToBounds = YES;
    button.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1];
    button.backgroundColor = buttonColor;
    [button setTitleColor:GRAYLIGHT forState:UIControlStateNormal];
    
    button.imageView.layer.cornerRadius = 14.0f;
    button.layer.shadowRadius = .0f;
    button.layer.shadowColor = buttonColor.CGColor;
    button.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    button.layer.shadowOpacity = 0.5f;
    button.layer.masksToBounds = NO;
    
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
            UIColor *schemaColor = [UIColor colorWithRed:197.0/255 green:197.0/255 blue:197.0/255 alpha:1];
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
            
            [schemaDict setObject:[UIColor blackColor] forKey:@"RandSchemaColor"];
            [schemaDict setObject:[UIColor grayColor] forKey:@"barMittelstreifenColor"];
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
@end
