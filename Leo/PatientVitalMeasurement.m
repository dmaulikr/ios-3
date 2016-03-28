//
//  PatientVitalMeasurement.m
//  Leo
//
//  Created by Adam Fanslau on 1/6/16.
//  Copyright © 2016 Leo Health. All rights reserved.
//

#import "PatientVitalMeasurement.h"
#import "NSDictionary+Extensions.h"
#import "NSDate+Extensions.h"
#import "LEOConstants.h"

@implementation PatientVitalMeasurement

- (instancetype)initWithTakenAt:(NSDate *)takenAt value:(NSString *)value percentile:(NSString *)percentile unit:(NSString*)unit measurementType:(PatientVitalMeasurementType)measurementType valueAndUnitFormatted:(NSString*)valueAndUnitFormatted {

    self = [super init];
    if (self) {

        _takenAt = takenAt;
        _value = value;
        _percentile = percentile;
        _measurementType = measurementType;
        _unit = unit;
        _valueAndUnitFormatted = valueAndUnitFormatted;
    }

    return self;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary {

    NSDate *takenAt = [NSDate leo_dateFromDateTimeString:[jsonDictionary leo_itemForKey:APIParamVitalMeasurementTakenAt]];
    NSString *value = [NSString stringWithFormat:@"%@", [jsonDictionary leo_itemForKey:APIParamVitalMeasurementValue]];
    NSString *unit = [NSString stringWithFormat:@"%@", [jsonDictionary leo_itemForKey:APIParamVitalMeasurementUnit]];
    NSString *valueAndUnitFormatted = [jsonDictionary leo_itemForKey:APIParamVitalMeasurementFormattedValueAndUnit];
    NSString *percentile = [jsonDictionary leo_itemForKey:APIParamVitalMeasurementPercentile];
    PatientVitalMeasurementType measurementType = [[jsonDictionary leo_itemForKey:APIParamType] integerValue];

    return [self initWithTakenAt:takenAt value:value percentile:percentile unit:unit measurementType:measurementType valueAndUnitFormatted:valueAndUnitFormatted];
}

+ (NSArray *)patientVitalsFromDictionaries:(NSArray *)dictionaries {

    NSMutableArray *array = [NSMutableArray new];

    for (NSDictionary *dict in dictionaries) {
        [array addObject:[[self alloc] initWithJSONDictionary:dict]];
    }

    return [array copy];
}


@end
