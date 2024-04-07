//
//  TextModulEdit.h
//  DailyGammon
//
//  Created by Peter Schneider on 05.04.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Phrases+CoreDataProperties.h"

@class Design;

NS_ASSUME_NONNULL_BEGIN

@interface TextModulEdit : UIViewController <UITextViewDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (readwrite, retain, nonatomic) Phrases *phraseEdit;

@end

NS_ASSUME_NONNULL_END
