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

@interface ChatView : UIView<UITextViewDelegate>

@property (strong, readwrite, retain, atomic) NSMutableDictionary *boardDict;
@property (strong, readwrite, retain, atomic) NSMutableDictionary *actionDict;
@property (strong, readwrite, retain, atomic) UIView *boardView;
@property (strong, readwrite, retain, atomic) UISwitch *quoteSwitch;
@property (strong, readwrite, retain, atomic) UITextView *playerChat;

@property (strong, readwrite, retain, atomic) UINavigationController *navigationController;
@property (strong, readwrite, retain, atomic) UIViewController *presentingVC;

@property (strong, readwrite, retain, atomic) UIButton *transparentButton;

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Tools *tools;

- (id)init;
- (void)showChatInView:(UIView *)view;
- (void)dismiss;


@end

NS_ASSUME_NONNULL_END
