//
//  LEOAnalyticSession.m
//  Leo
//
//  Created by Zachary Drossman on 4/1/16.
//  Copyright © 2016 Leo Health. All rights reserved.
//

#import "LEOAnalyticSession.h"
#import "NSDate+Extensions.h"

@interface LEOAnalyticSession ()

@property (strong, nonatomic) NSDate *startTime;
@property (copy, nonatomic) NSString *eventName;
@end

@implementation LEOAnalyticSession

NSString *const kSessionLength = @"session_length";

+ (LEOAnalyticSession *)startSessionWithSessionEventName:(NSString *)sessionEventName {

    LEOAnalyticSession *session = [LEOAnalyticSession new];

    session.startTime = [NSDate date];
    session.eventName = sessionEventName;

    return session;
}

- (void)updateSessionWithNewStartTime {
    self.startTime = [NSDate date];
}

- (instancetype)init {
    self = [super init];
    if (self) {

        [self addNotifications];
    }
    return self;
}


//MARK: There has to be a less clutzy way of accomplishing this. I'm probably
// just forgetting an old trick, but for now, this should work.

- (NSNumber *)sessionLength {

    NSNumber *fullNumericSessionLength = @([[NSDate date] secondsLaterThan:self.startTime]);

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    [formatter setRoundingMode: NSNumberFormatterRoundHalfUp];

    NSString *numberString = [formatter stringFromNumber:fullNumericSessionLength];
    NSNumber *roundedNumber = [formatter numberFromString:numberString];

    return roundedNumber;
}

- (void)completeSession {
    [Localytics tagEvent:self.eventName attributes:@{kSessionLength:[self sessionLength]}];
}

- (void)addNotifications {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationReceived:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(notificationReceived:)
                                             name:UIApplicationDidEnterBackgroundNotification
                                           object:nil];
}

- (void)notificationReceived:(NSNotification *)notification {

    if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        [self updateSessionWithNewStartTime];
    }

    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [self completeSession];
    }
}

- (void)removeNotifications {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:self];
}

- (void)dealloc {
    [self removeNotifications];
}


@end
