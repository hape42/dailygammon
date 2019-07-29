//
//  iPhoneRatingVC.h
//  DailyGammon
//
//  Created by Peter on 11.03.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@class Design;
@class Rating;

@interface iPhoneRatingVC : UIViewController<CPTPlotDataSource>
{
    CPTGraphHostingView *hostingView;
    CPTXYGraph *barLineChart;
}

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Rating *rating;

@end

