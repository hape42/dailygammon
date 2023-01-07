//
//  DGLabel.m
//  DailyGammon
//
//  Created by Peter Schneider on 07.01.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "DGLabel.h"

@implementation DGLabel

- (id)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    if (self)
    {
        [self customizeLabel];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{

    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self customizeLabel];
    }
    return self;
}

- (void)customizeLabel
{

    self.numberOfLines = 0;
    self.adjustsFontSizeToFitWidth = YES;
    self.minimumScaleFactor = 0.1;
}
@end
