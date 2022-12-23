//
//  BoardSchemeVC.h
//  DailyGammon
//
//  Created by Peter on 05.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Design;

NS_ASSUME_NONNULL_BEGIN

@interface BoardSchemeVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, readwrite, retain, atomic) Design *design;

@property (readwrite, retain, nonatomic) NSMutableArray *boardsArray;

@end

NS_ASSUME_NONNULL_END
