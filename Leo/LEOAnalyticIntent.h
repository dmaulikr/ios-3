//
//  LEOAnalyticIntent.h
//  Leo
//
//  Created by Annie Graham on 6/21/16.
//  Copyright © 2016 Leo Health. All rights reserved.
//

#import "LEOAnalyticEvent.h"

@class Family;
@interface LEOAnalyticIntent : LEOAnalyticEvent


+ (void)tagEvent:(NSString *)eventName
  withAttributes:(NSDictionary *)attributeDictionary;

@end
