//
//  ProfileVC.h
//  DailyGammon
//
//  Created by Peter Schneider on 11.04.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaitView.h"

@class Design;

NS_ASSUME_NONNULL_BEGIN

@interface ProfileVC : UIViewController <UITextViewDelegate, NSURLSessionDelegate>

@property (strong, readwrite, retain, atomic) Design *design;

@property (readwrite, retain, nonatomic) NSMutableArray *profileArray;

@property (strong, nonatomic, readwrite) WaitView *waitView;

@end

NS_ASSUME_NONNULL_END
