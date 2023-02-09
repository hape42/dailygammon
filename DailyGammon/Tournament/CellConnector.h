//
//  CellConnector.h
//  DailyGammon
//
//  Created by Peter Schneider on 09.02.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CellConnector : UIView

- (id)initFromLabels:(DGLabel *)topLabel rootLabel1:(DGLabel *)rootLabel1 rootLabel2:(DGLabel *)rootLabel2;

@end

NS_ASSUME_NONNULL_END
