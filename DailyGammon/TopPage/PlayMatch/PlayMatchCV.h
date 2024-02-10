//
//  PlayMatchCV.h
//  DailyGammon
//
//  Created by Peter Schneider on 04.02.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaitView.h"
#import "MenueView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlayMatchCV : UIViewController<NSURLSessionDataDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic, readwrite) WaitView *waitView;
@property (strong, nonatomic, readwrite) MenueView *menueView;

@end

NS_ASSUME_NONNULL_END
