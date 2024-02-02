//
//  TopPageCV.h
//  DailyGammon
//
//  Created by Peter Schneider on 31.01.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "WaitView.h"
#import "MenueView.h"
#import "SortView.h"

@class Design;

NS_ASSUME_NONNULL_BEGIN

@interface TopPageCV : UIViewController < UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, readwrite, retain, atomic) Design *design;

@property (strong, nonatomic, readwrite) MenueView *menueView;
@property (strong, nonatomic, readwrite) SortView *sortView;

@end

NS_ASSUME_NONNULL_END
