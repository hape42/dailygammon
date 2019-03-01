//
//  Design.h
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Design : UIView

-(UIButton *) makeNiceButton: (UIButton *)button;
-(UIBarButtonItem *) makeNiceBarButton: (UIBarButtonItem *)button;
-(UIButton *) makeNiceFlatButton: (UIButton *)button;

- (UITableViewCell *) makeNiceCell: (UITableViewCell*)cell;
- (UILabel *) makeNiceLabel: (UILabel*)label;
- (UILabel *) makeNiceTextField: (UILabel*)text;

#define VIEWBACKGROUNDCOLOR [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1]
//#define VIEWBACKGROUNDCOLOR [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1]
#define HEADERBACKGROUNDCOLOR [UIColor colorWithRed:0.0/255 green:102.0/255 blue:0.0/255 alpha:1]

#define GRAYLIGHT [UIColor colorWithRed:235.0/255 green:235.0/255 blue:235.0/255 alpha:1]
#define GRAYDARK [UIColor colorWithRed:214.0/255 green:214.0/255 blue:214.0/255 alpha:1]

-(NSMutableDictionary *)schema:(int)nummer;

@end

NS_ASSUME_NONNULL_END
