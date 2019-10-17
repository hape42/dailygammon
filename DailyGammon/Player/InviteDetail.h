//
//  InviteDetail.h
//  DailyGammon
//
//  Created by Peter on 06.06.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class Design;

@interface InviteDetail : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (strong, readwrite, retain, atomic)    NSString *playerName;
@property (strong, readwrite, retain, atomic)    NSString *playerNummer;


@property (strong, readwrite, retain, atomic) Design *design;

@end

NS_ASSUME_NONNULL_END
