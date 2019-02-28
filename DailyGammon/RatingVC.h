//
//  RatingVC.h
//  DailyGammon
//
//  Created by Peter on 27.02.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

NS_ASSUME_NONNULL_BEGIN

@class Design;
@class Preferences;
@class Rating;

@interface RatingVC : UIViewController<CPTPlotDataSource>
{
    CPTGraphHostingView *hostingView;
    CPTXYGraph *barLineChart;
}

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Preferences *preferences;
@property (strong, readwrite, retain, atomic) Rating *rating;

@end

NS_ASSUME_NONNULL_END
