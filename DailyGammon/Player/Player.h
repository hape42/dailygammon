//
//  Player.h
//  DailyGammon
//
//  Created by Peter on 04.06.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Design;
@class Tools;

NS_ASSUME_NONNULL_BEGIN

@interface Player : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIPopoverPresentationControllerDelegate, UITextFieldDelegate, UISearchControllerDelegate, UITextViewDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Tools *tools;

@property (strong, readwrite, retain, atomic)    NSString *name;

@end

NS_ASSUME_NONNULL_END
