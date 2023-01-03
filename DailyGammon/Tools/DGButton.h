//
//  DGButton.h
//  DailyGammon
//
//  Created by Peter Schneider on 03.01.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class Design;

@interface DGButton : UIButton
{
    NSString *title;
}
@property (strong, readwrite, retain, atomic) Design *design;

@end

NS_ASSUME_NONNULL_END
