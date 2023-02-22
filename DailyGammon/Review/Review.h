//
//  Review.h
//  DailyGammon
//
//  Created by Peter Schneider on 18.02.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Design;
@class Tools;

NS_ASSUME_NONNULL_BEGIN

@interface Review : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Tools *tools;

@property (readwrite, retain, nonatomic) NSURL *reviewURL;
@property (readwrite, assign, atomic) int matchLength;

@property (readwrite, retain, nonatomic) NSMutableArray *listArray;

@end

NS_ASSUME_NONNULL_END
