//
//  WaitView.h
//  DailyGammon
//
//  Created by Peter Schneider on 17.03.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class Design;

@interface WaitView : UIView

@property (strong, readwrite, retain, atomic) Design *design;

- (id)initWithText:(NSString *)text;
- (void)showInView:(UIView *)view;
- (void)dismiss;

@property (readwrite, retain, nonatomic) NSString *messageText;

@end

NS_ASSUME_NONNULL_END
