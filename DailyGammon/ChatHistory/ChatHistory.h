//
//  ChatHistory.h
//  DailyGammon
//
//  Created by Peter Schneider on 19.04.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Design;

NS_ASSUME_NONNULL_BEGIN

@interface ChatHistory : UIViewController<UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, readwrite, retain, atomic) Design *design;

@property (strong, readwrite, retain, atomic)    NSString *playerName;
@property (strong, readwrite, retain, atomic)    NSString *playerID;

@property (readwrite, retain, nonatomic) NSMutableArray *chatHistoryArray;

- (void)saveChat:(NSString *)text
      opponentID:(NSString *)opponentID
         autorID:(NSString *)autorID
             typ:(int)typ
     matchNumber:(int)matchNumber
       matchName:(NSString *)matchName;

@end

NS_ASSUME_NONNULL_END
