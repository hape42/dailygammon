//
//  Tournament.h
//  DailyGammon
//
//  Created by Peter Schneider on 06.02.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Design;
@class Preferences;
@class Rating;
@class Tools;
@class RatingTools;

NS_ASSUME_NONNULL_BEGIN

@interface Tournament : UIViewController<UIScrollViewDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Preferences *preferences;
@property (strong, readwrite, retain, atomic) Rating *rating;
@property (strong, readwrite, retain, atomic) Tools *tools;
@property (strong, readwrite, retain, atomic) RatingTools *ratingTools;

@property (strong, readwrite, retain, atomic) UIScrollView *scrollView;

@property (readwrite, retain, nonatomic) NSMutableArray *drawArray;
@property (readwrite, retain, nonatomic) NSURL *url;
@property (readwrite, retain, nonatomic) NSString *name;

@property (readwrite, assign, atomic) int xFound, yFound;

@end

NS_ASSUME_NONNULL_END
