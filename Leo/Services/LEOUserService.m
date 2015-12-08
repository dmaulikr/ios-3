//
//  LEOUserService.m
//  Leo
//
//  Created by Zachary Drossman on 9/21/15.
//  Copyright (c) 2015 Leo Health. All rights reserved.
//

#import "LEOUserService.h"

#import "User.h"
#import "Guardian.h"
#import "Patient.h"
#import "Family.h"

#import "LEOAPISessionManager.h"
#import "SessionUser.h"
#import "NSUserDefaults+Additions.h"
#import "DeviceToken.h"

@implementation LEOUserService

- (void)createGuardian:(Guardian *)newGuardian withCompletion:(void (^)(Guardian *guardian, NSError *error))completionBlock {
    
    NSDictionary *guardianDictionary = [Guardian dictionaryFromUser:newGuardian];
    
    [[LEOUserService leoSessionManager] standardPOSTRequestForJSONDictionaryToAPIWithEndpoint:APIParamUsers params:guardianDictionary completion:^(NSDictionary *rawResults, NSError *error) {
        
        if (!error) {
            
            [SessionUser setCurrentUserWithJSONDictionary:rawResults[APIParamData]];
            [SessionUser setAuthToken:rawResults[APIParamData][APIParamSession][APIParamToken]];
            
            
            Guardian *guardian = [[Guardian alloc] initWithJSONDictionary:rawResults[APIParamData][APIParamUser]];
            
            completionBlock ? completionBlock (guardian, nil) : completionBlock;
        } else {
            completionBlock ? completionBlock (nil, error) : completionBlock;
        }
    }];
}

- (void)createPatient:(Patient *)newPatient withCompletion:(void (^)(Patient * patient, NSError *error))completionBlock {
    
    NSDictionary *patientDictionary = [Patient dictionaryFromUser:newPatient];
    
    [[LEOUserService leoSessionManager] standardPOSTRequestForJSONDictionaryToAPIWithEndpoint:APIEndpointPatients params:patientDictionary completion:^(NSDictionary *rawResults, NSError *error) {
        
        if (!error) {
            
            Patient *patient = [[Patient alloc] initWithJSONDictionary:rawResults[APIParamData][APIParamUserPatient]];
            patient.avatar = newPatient.avatar;
            
            completionBlock ? completionBlock(patient, nil) : completionBlock;
        } else {
            completionBlock ? completionBlock (nil, error) : completionBlock;
        }
    }];
}

- (void)enrollUser:(Guardian *)guardian password:(NSString *)password withCompletion:(void (^) (BOOL success, NSError *error))completionBlock {
    
    NSMutableDictionary *enrollmentParams = [[User dictionaryFromUser:guardian] mutableCopy];
    enrollmentParams[APIParamUserPassword] = password;
    
    [[LEOUserService leoSessionManager] unauthenticatedPOSTRequestForJSONDictionaryToAPIWithEndpoint:APIEndpointUserEnrollments params:enrollmentParams completion:^(NSDictionary *rawResults, NSError *error) {
        
        if (!error) {
            
            [SessionUser newUserWithJSONDictionary:rawResults[APIParamData]];
            [SessionUser setAuthToken:rawResults[APIParamData][APIParamSession][APIParamToken]];
            completionBlock ? completionBlock(YES, nil) : completionBlock;
        } else {
            completionBlock ? completionBlock (NO, error) : completionBlock;
        }
    }];
}

- (void)enrollPatient:(Patient *)patient withCompletion:(void (^) (BOOL success, NSError *error))completionBlock {
    
    NSMutableDictionary *enrollmentParams = [[Patient dictionaryFromUser:patient] mutableCopy];
    
    [[LEOUserService leoSessionManager] standardPOSTRequestForJSONDictionaryToAPIWithEndpoint:APIEndpointPatientEnrollments params:enrollmentParams completion:^(NSDictionary *rawResults, NSError *error) {
        
        BOOL success = error ? NO : YES;
        completionBlock ? completionBlock(success, error) : completionBlock;
    }];
}

- (void)updateEnrollmentOfPatient:(Patient *)patient  withCompletion:(void (^) (BOOL success, NSError *error))completionBlock {
    
    NSDictionary *patientDictionary = [Patient dictionaryFromUser:patient];
    
    [[LEOUserService leoSessionManager] standardPUTRequestForJSONDictionaryToAPIWithEndpoint:APIEndpointPatientEnrollments params:patientDictionary completion:^(NSDictionary *rawResults, NSError *error) {
        
        BOOL success = error ? NO : YES;
        completionBlock ? completionBlock(success, error) : completionBlock;
    }];
}

- (void)updateEnrollmentOfUser:(Guardian *)guardian withCompletion:(void (^) (BOOL success, NSError *error))completionBlock {
    
    NSDictionary *guardianDictionary = [Guardian dictionaryFromUser:guardian];
    
    [[LEOUserService leoSessionManager] standardPUTRequestForJSONDictionaryToAPIWithEndpoint:APIEndpointUserEnrollments params:guardianDictionary completion:^(NSDictionary *rawResults, NSError *error) {
        
        BOOL success = error ? NO : YES;
        completionBlock ? completionBlock(success, error) : completionBlock;
    }];
}

- (void)updateUser:(Guardian *)guardian withCompletion:(void (^) (BOOL success, NSError *error))completionBlock {

    NSDictionary *guardianDictionary = [Guardian dictionaryFromUser:guardian];
    
    [[LEOUserService leoSessionManager] standardPUTRequestForJSONDictionaryToAPIWithEndpoint:APIEndpointUsers params:guardianDictionary completion:^(NSDictionary *rawResults, NSError *error) {
        
        BOOL success = error ? NO : YES;
        completionBlock ? completionBlock(success, error) : completionBlock;
    }];
}

- (void)updatePatient:(Patient *)patient withCompletion:(void (^) (BOOL success, NSError *error))completionBlock {

    NSDictionary *patientDictionary = [Patient dictionaryFromUser:patient];

    NSString *updatePatientEndpoint = [NSString stringWithFormat:@"%@/%@", APIEndpointPatients, patient.objectID];

    [[LEOUserService leoSessionManager] standardPUTRequestForJSONDictionaryToAPIWithEndpoint:updatePatientEndpoint params:patientDictionary completion:^(NSDictionary *rawResults, NSError *error) {
        
        BOOL success = error ? NO : YES;
        completionBlock ? completionBlock(success, error) : completionBlock;
    }];
}

- (void)loginUserWithEmail:(NSString *)email password:(NSString *)password withCompletion:(void (^)(SessionUser *user, NSError *error))completionBlock {

    NSMutableDictionary *loginParams = [@{APIParamUserEmail:email, APIParamUserPassword:password} mutableCopy];

    if ([DeviceToken token]) {
        [loginParams setValue:[DeviceToken token] forKey:APIParamSessionDeviceToken];
    }

    [[LEOUserService leoSessionManager] unauthenticatedPOSTRequestForJSONDictionaryToAPIWithEndpoint:APIEndpointLogin params:loginParams completion:^(NSDictionary *rawResults, NSError *error) {
        
        if (!error) {
            
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"SessionUser"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [SessionUser setAuthToken:rawResults[APIParamData][APIParamSession][APIParamToken]];
            [SessionUser setCurrentUserWithJSONDictionary:rawResults[APIParamData]];
            
            completionBlock ? completionBlock([SessionUser currentUser], nil) : nil;
        } else {
            completionBlock ? completionBlock(nil, error) : nil;
        }
    }];
}

- (void)logoutUserWithCompletion:(void (^)(BOOL success, NSError *error))completionBlock {

    [[LEOUserService leoSessionManager] standardDELETERequestForJSONDictionaryToAPIWithEndpoint:@"logout" params:nil completion:^(NSDictionary *rawResults, NSError *error) {

        if (!error) {
            
            if ([rawResults[APIParamStatus] isEqualToString:@"ok"]) {
                [SessionUser logout];
            } else {
                completionBlock ? completionBlock(NO, nil) : nil;
            }
        } else {
            completionBlock ? completionBlock(NO, error) : nil;
        }
    }];
}

- (void)resetPasswordWithEmail:(NSString *)email withCompletion:(void (^)(NSDictionary *  rawResults, NSError *error))completionBlock {
    
    NSDictionary *resetPasswordParams = @{APIParamUserEmail:email};
    
    [[LEOUserService leoSessionManager] standardPOSTRequestForJSONDictionaryToAPIWithEndpoint:APIEndpointResetPassword params:resetPasswordParams completion:^(NSDictionary *rawResults, NSError *error) {
        
        completionBlock ? completionBlock(rawResults, error) : nil;
    }];
}

- (void)changePasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword retypedNewPassword:(NSString *)retypedNewPassword withCompletion:(void (^) (BOOL success, NSError *error))completionBlock {
    
    NSDictionary *changePasswordParams = @{APIParamUserPasswordExisting : oldPassword, APIParamUserPassword : newPassword, APIParamUserPasswordNewRetyped : retypedNewPassword};
    
    [[LEOUserService leoSessionManager] standardPUTRequestForJSONDictionaryToAPIWithEndpoint:APIEndpointChangePassword params:changePasswordParams completion:^(NSDictionary *rawResults, NSError *error) {
        
        BOOL success = error ? NO : YES;
        completionBlock ? completionBlock(success, error) : nil;
    }];
}

- (void)getAvatarForUser:(User *)user withCompletion:(void (^)(UIImage *rawImage, NSError *error))completionBlock {
    
    if (user.avatarURL) {
        
        [[LEOUserService leoSessionManager] unauthenticatedImageGETRequestForJSONDictionaryFromAPIWithEndpoint:user.avatarURL params:nil completion:^(UIImage *rawImage, NSError *error) {
            
            completionBlock ? completionBlock(rawImage, error) : nil;
        }];
        
    } else {
        completionBlock ? completionBlock(nil, nil) : nil;
    }
}

- (void)postAvatarForUser:(User *)user withCompletion:(void (^)(BOOL success, NSError *error))completionBlock {
    
    NSString *avatarData = [UIImagePNGRepresentation(user.avatar) base64EncodedStringWithOptions:0];
    
    NSDictionary *avatarParams = @{@"avatar":avatarData, @"patient_id":@([user.objectID integerValue]) };
    
    [[LEOUserService leoSessionManager] standardPOSTRequestForJSONDictionaryToAPIWithEndpoint:APIEndpointAvatars params:avatarParams completion:^(NSDictionary *rawResults, NSError *error) {
        
        //The extra "avatar" is not a "mistake" here; that is how it is provided by the backend. Should be updated eventually.
        user.avatarURL = rawResults[APIParamData][@"avatar"][@"avatar"][@"url"];
        
        completionBlock ? completionBlock (nil, error) : nil;
    }];
}

- (void)inviteUser:(User *)user withCompletion:(void (^) (BOOL success, NSError *error))completionBlock {
    
    NSDictionary *userDictionary = [User dictionaryFromUser:user];
    
    NSString *inviteEndpoint = [NSString stringWithFormat:@"%@/%@", APIEndpointUserEnrollments, APIEndpointInvite];
    
    [[LEOUserService leoSessionManager] standardPOSTRequestForJSONDictionaryToAPIWithEndpoint:inviteEndpoint params:userDictionary completion:^(NSDictionary *rawResults, NSError *error) {
        
        BOOL success = error ? NO : YES;
        
        completionBlock ? completionBlock (success, error) : nil;
    }];
}

+ (LEOAPISessionManager *)leoSessionManager {
    return [LEOAPISessionManager sharedClient];
}

@end
