//
//  Constants.h
//  DailyGammon
//
//  Created by Peter Schneider on 25.02.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//


extern NSString * const chatViewNextButtonNotification;
extern NSString * const chatViewTopButtonNotification;

extern NSString * const changeSchemaNotification;
extern NSString * const matchCountChangedNotification;
extern NSString * const sortNotification;
extern NSString * const sortButton;

#define ALERT_VIEW_TAG 42

#define SORT_GRACE_THEN_POOL 0
#define SORT_POOL 1
#define SORT_GRACE_PLUS_POOL 2
#define SORT_RECENT_OPPONENT_MOVE 3
#define SORT_EVENT_DOWN 5
#define SORT_EVENT_UP 51
#define SORT_ROUND_DOWN 6
#define SORT_ROUND_UP 61
#define SORT_LENGTH_DOWN 7
#define SORT_LENGTH_UP 71
#define SORT_OPPONENT_NAME_DOWN 8
#define SORT_OPPONENT_NAME_UP 81
