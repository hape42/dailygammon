//
//  MenueView.h
//  DailyGammon
//
//  Created by Peter Schneider on 29.12.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class Design;
@class Tools;
@class DGButton;

@interface MenueView : UIView<UIPopoverPresentationControllerDelegate>

@property (strong, readwrite, retain, atomic) UINavigationController *navigationController;
@property (strong, readwrite, retain, atomic) UIView *presentingView;

@property (strong, readwrite, retain, atomic) DGButton *button1;

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Tools *tools;

- (id)init;
- (void)showMenueInView:(UIView *)view;
- (void)dismiss;


@end

NS_ASSUME_NONNULL_END
