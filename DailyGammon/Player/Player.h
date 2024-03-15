//
//  Player.h
//  DailyGammon
//
//  Created by Peter on 04.06.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MenueView.h"

@class Design;
@class Tools;

NS_ASSUME_NONNULL_BEGIN

@interface Player : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UIPopoverPresentationControllerDelegate, UISearchControllerDelegate, UITextViewDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Tools *tools;

@property (strong, readwrite, retain, atomic)    NSString *name;

@property (strong, nonatomic, readwrite) MenueView *menueView;

@property (strong, readwrite, retain, atomic) NSMutableArray *chooseArray;

@end

NS_ASSUME_NONNULL_END
