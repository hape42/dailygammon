//
//  TopPageVC.h
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Header;
@class Design;

NS_ASSUME_NONNULL_BEGIN

@interface TopPageVC : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, readwrite, retain, atomic) Header *header;
@property (strong, readwrite, retain, atomic) Design *design;

@end

NS_ASSUME_NONNULL_END
