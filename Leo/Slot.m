//
//  Slot.m
//  LEOCalendar
//
//  Created by Zachary Drossman on 7/30/15.
//  Copyright (c) 2015 Zachary Drossman. All rights reserved.
//

#import "Slot.h"
#import "NSDate+Extensions.h"
#import "LEOConstants.h"
#import "PrepAppointment.h"
#import "AppointmentType.h"
#import "Practice.h"
#import "Provider.h"

@implementation Slot


- (instancetype)initWithStartDateTime:(NSDate *)startDateTime duration:(NSNumber *)duration providerID:(NSString *)providerID practiceID:(NSString *)practiceID {
    
    self = [super init];
    
    if (self) {
        _startDateTime = startDateTime;
        _duration = duration;
        _providerID = providerID;
        _practiceID = practiceID;
    }
    
    return self;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonResponse {
    
    NSDate *startDateTime = [NSDate dateFromDateTimeString:jsonResponse[APIParamSlotStartDateTime]];
    NSNumber *duration = jsonResponse[APIParamSlotDuration];
    NSString *providerID = [jsonResponse[APIParamUserProviderID] stringValue];
    NSString *practiceID = [jsonResponse[APIParamPracticeID] stringValue];
    
    return [self initWithStartDateTime:startDateTime duration:duration providerID:providerID practiceID:practiceID];
}

+ (NSDictionary *)slotsRequestDictionaryFromPrepAppointment:(PrepAppointment *)prepAppointment {
    
    NSDate *now = [[NSDate date] dateByAddingMinutes:30];
    NSDate *twelveWeeksFromTheBeginningOfThisWeek = [[[NSDate date] beginningOfWeekForStartOfWeek:1] dateByAddingDays:84];
    
    NSDictionary *slotRequestParameters = @{
                                 APIParamAppointmentTypeID : prepAppointment.appointmentType.objectID,
                                 APIParamUserProviderID : prepAppointment.provider.objectID,
                                 APIParamStartDate : [NSDate stringifiedShortDate:now],
                                 APIParamEndDate: [NSDate stringifiedShortDate:twelveWeeksFromTheBeginningOfThisWeek]
                                 };

    return slotRequestParameters;
}

+ (Slot *)slotFromExistingAppointment:(PrepAppointment *)appointment {
    
    return [[Slot alloc] initWithStartDateTime:appointment.date duration:appointment.appointmentType.duration providerID:appointment.provider.objectID practiceID:appointment.practice.objectID];
}

+ (NSArray *)slotsFromRawJSON:(NSDictionary *)rawJSON {
    
    NSArray *slotDictionaries = rawJSON[APIParamData][0][APIParamSlots];
    
    NSMutableArray *slots = [[NSMutableArray alloc] init];
    
    for (NSDictionary *slotDictionary in slotDictionaries) {
        
        Slot *slot = [[Slot alloc] initWithJSONDictionary:slotDictionary];
        
        [slots addObject:slot];
    }
    
    return slots;
}

- (NSString *) description {
    
    return [NSString stringWithFormat:@"<Slot: %p> | Date / Time: %@", self, self.startDateTime];
}

@end
