//
//  TextModul.h
//  DailyGammon
//
//  Created by Peter Schneider on 03.04.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Design;

NS_ASSUME_NONNULL_BEGIN

@interface TextModul : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, readwrite, retain, atomic) Design *design;

@property (readwrite, retain, nonatomic) NSMutableArray *textModulArray;

@end

NS_ASSUME_NONNULL_END
