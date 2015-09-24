//
//  LEOAPISlotsOperation.m
//  LEOCalendar
//
//  Created by Zachary Drossman on 8/6/15.
//  Copyright (c) 2015 Zachary Drossman. All rights reserved.
//

#import "LEOAPISlotsOperation.h"
#import "LEOCalendarDataSource.h" //TODO: Replace with data manager when slots are finished being integrated
#import "LEOAppointmentService.h"
#import "PrepAppointment.h"
#import <DateTools.h>
@interface LEOAPISlotsOperation()

@property (strong, nonatomic) PrepAppointment *prepAppointment;

@end

@implementation LEOAPISlotsOperation

NSInteger const dayRangeForSlots = 45;

-(instancetype)initWithPrepAppointment:(PrepAppointment *)prepAppointment {
    
    self = [super init];
    
    if (self) {
        _prepAppointment = prepAppointment;
    }
    
    return self;
}

-(void)main {
    
    LEOAppointmentService *appointmentService = [[LEOAppointmentService alloc] init];

    [appointmentService getSlotsForPrepAppointment:self.prepAppointment withCompletion:^(NSArray *slots, NSError *error) {
        
        id data = [LEOCalendarDataSource formatSlots:slots forDaysFromToday:dayRangeForSlots];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.requestBlock(data, error);
        }];
    }];
}

@end