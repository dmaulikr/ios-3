//
//  PatientVitalMeasurement.h
//  Leo
//
//  Created by Adam Fanslau on 1/6/16.
//  Copyright © 2016 Leo Health. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PatientVitalMeasurement : NSObject

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PatientVitalMeasurementType) {

    PatientVitalMeasurementTypeBMI,
    PatientVitalMeasurementTypeHeight,
    PatientVitalMeasurementTypeWeight,
};

@property (strong, nonatomic) NSDate *takenAt;
@property (copy, nonatomic) NSString *value;
@property (copy, nonatomic) NSString *percentile;
@property (copy, nonatomic) NSString *unit;
@property (copy, nonatomic) NSString *valueAndUnitFormatted;
@property (nonatomic) PatientVitalMeasurementType measurementType;

- (instancetype)initWithTakenAt:(NSDate *)takenAt
                          value:(NSString *)value
                     percentile:(NSString *)percentile
                           unit:(NSString*)unit
                measurementType:(PatientVitalMeasurementType)measurementType
          valueAndUnitFormatted:(NSString*)valueAndUnitFormatted;
- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary;
+ (NSArray *)patientVitalsFromDictionaries:(NSArray *)dictionaries;


NS_ASSUME_NONNULL_END
@end
