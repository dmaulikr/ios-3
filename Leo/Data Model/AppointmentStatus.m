 //
//  AppointmentStatus.m
//  Leo
//
//  Created by Zachary Drossman on 11/18/15.
//  Copyright © 2015 Leo Health. All rights reserved.
//

#import "AppointmentStatus.h"

@implementation AppointmentStatus

- (instancetype)initWithObjectID:(NSString *)objectID name:(NSString *)name athenaCode:(NSString *)athenaCode statusCode:(AppointmentStatusCode)statusCode {

    self = [super init];

    if (self) {

        _objectID = objectID;
        _name = name;
        _athenaCode = athenaCode;
        _statusCode = statusCode;
    }

    return self;
}

- (instancetype)initWithJSONDictionary:(nonnull NSDictionary *)jsonResponse {

    NSString *objectID = [jsonResponse[APIParamID] stringValue];
    NSString *name = jsonResponse[APIParamDescription];
    NSString *athenaCode = jsonResponse[APIParamStatus];
    AppointmentStatusCode statusCode = [jsonResponse[APIParamID] integerValue];

    if (statusCode == AppointmentStatusCodeCancelled) {
        statusCode = AppointmentStatusCodeConfirmingCancelling;
    }

    return [self initWithObjectID:objectID name:name athenaCode:athenaCode statusCode:statusCode];
}

+ (NSDictionary *)serializeToJSON:(AppointmentStatus *)object {

    if (!object) {
        return nil;
    }

    NSMutableDictionary *json = [NSMutableDictionary new];

    json[APIParamID] = object.objectID;
    json[APIParamDescription] = object.name;
    json[APIParamStatus] = object.athenaCode;

    return [json copy];
}

+ (NSNumber *)numberFromString:(NSString *)numberString {

    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterOrdinalStyle;

    return [numberFormatter numberFromString:numberString];
}


@end
