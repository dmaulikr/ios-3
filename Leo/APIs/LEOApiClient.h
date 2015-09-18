//
//  LEOApiClient.h
//  Leo
//
//  Created by Zachary Drossman on 5/12/15.
//  Copyright (c) 2015 Leo Health. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@class Appointment;


@interface LEOApiClient : NSObject
NS_ASSUME_NONNULL_BEGIN

//Users
+ (void)createUserWithParameters:(NSDictionary *)userParams withCompletion:(void (^)(NSDictionary *rawResults, NSError *error))completionBlock;
+ (void)loginUserWithParameters:(NSDictionary *)loginParams withCompletion:(void (^)(NSDictionary * rawResults, NSError *error))completionBlock;
+ (void)resetPasswordWithParameters:(NSDictionary *)resetParams withCompletion:(void (^)(NSDictionary * rawResults, NSError *error))completionBlock;
+ (void)getAvatarFromURL:(NSString *)avatarURL withCompletion:(void (^)(UIImage *rawImage, NSError *error))completionBlock;


//Cards
+ (void)getCardsForUser:(NSDictionary *)userParams withCompletion:(void (^)(NSDictionary *rawResults, NSError *error))completionBlock;

//Support API
+ (void)getPracticesWithParameters:(NSDictionary *)practiceParameters withCompletion:(void (^)(NSDictionary *rawResults, NSError *error))completionBlock;
+ (void)getAppointmentTypesWithParameters:(NSDictionary *)appointmentTypeParams withCompletion:(void (^)(NSDictionary *rawResults, NSError *error))completionBlock;
+ (void)getFamilyWithUserParameters:(NSDictionary *)userParams withCompletion:(void (^)(NSDictionary *rawResults, NSError *error))completionBlock;
+ (void)getPracticeWithParameters:(NSDictionary *)practiceParams withCompletion:(void (^)(NSDictionary *rawResults, NSError *error))completionBlock;

//Conversations
+ (void)createMessageForConversation:(NSString *)conversationID withParameters:(NSDictionary *)messageParams withCompletion:(void (^)(NSDictionary *rawResults, NSError *error))completionBlock;
+ (void)getConversationsForFamilyWithParameters:(NSDictionary *)conversationParams withCompletion:(void (^)(NSDictionary  * rawResults, NSError *error))completionBlock;
+ (void)getMessagesForConversation:(NSString *)conversationID withParameters:(NSDictionary *)messageParams withCompletion:(void (^)(NSDictionary *rawResults, NSError *error))completionBlock;


NS_ASSUME_NONNULL_END
@end
