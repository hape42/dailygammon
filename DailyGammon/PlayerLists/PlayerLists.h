//
//  PlayerLists.h
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "WaitView.h"
#import "MenueView.h"

@class Design;
@class Tools;

NS_ASSUME_NONNULL_BEGIN

@interface PlayerLists : UIViewController<MFMailComposeViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Tools *tools;

@property (readwrite, assign, atomic) int listTyp;

@property (strong, nonatomic, readwrite) WaitView *waitView;
@property (strong, nonatomic, readwrite) MenueView *menueView;

@end

NS_ASSUME_NONNULL_END
