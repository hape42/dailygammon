//
//  Design.h
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Design : UIView

- (UIColor *) schemaColor;

-(UIButton *) makeReverseButton: (UIButton *)button;

-(UIBarButtonItem *) makeNiceBarButton: (UIBarButtonItem *)button;
-(UIButton *) makeNiceFlatButton: (UIButton *)button;

- (UITableViewCell *) makeNiceCell: (UITableViewCell*)cell;

- (UISwitch *) makeNiceSwitch: (UISwitch*)mySwitch;

- (UILabel *) makeSortLabel: (UILabel*)label sortOrderDown: (BOOL) down;

- (DGLabel *) makeNiceLabel: (DGLabel*)label;
- (UILabel *) makeNiceTextField: (UILabel*)text;

- (DGLabel *) makeLabelColor: (DGLabel*)label forColor: (NSString *)color forPlayer:(BOOL)player;

- (UIAlertController *) makeBackgroundColor:(UIAlertController*)alert;

- (UIButton *)designMoreButton:(UIButton *)moreButton;

- (BOOL)isX;

//#define VIEWBACKGROUNDCOLOR [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1]
#define VIEWBACKGROUNDCOLOR [UIColor yellowColor]

//#define VIEWBACKGROUNDCOLOR [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1]
#define HEADERBACKGROUNDCOLOR [UIColor colorWithRed:0.0/255 green:102.0/255 blue:0.0/255 alpha:1]

#define GRAYLIGHT [UIColor colorWithRed:235.0/255 green:235.0/255 blue:235.0/255 alpha:1]
#define GRAYDARK [UIColor colorWithRed:214.0/255 green:214.0/255 blue:214.0/255 alpha:1]
#define DARK [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
-(NSMutableDictionary *)schema:(int)nummer;

- (NSString *)changeCheckerColor:(NSString *)imgName forColor: (NSString *)color;

#define FEEDBACK_TEXT @"\nFound a bug?\nThen write me a short message and I'll try to fix it as soon as possible.\n\nGot a missing feature in mind?\nThen write me a short message. I collect all the suggestions and will implement them one after another if they make sense for most people."
@end

NS_ASSUME_NONNULL_END
