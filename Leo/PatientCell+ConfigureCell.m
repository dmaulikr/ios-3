//
//  PatientCell+ConfigureCell.m
//  LEOCalendar
//
//  Created by Zachary Drossman on 8/5/15.
//  Copyright (c) 2015 Zachary Drossman. All rights reserved.
//

#import "PatientCell+ConfigureCell.h"
#import "Patient.h"
#import "LEOMessagesAvatarImageFactory.h"
#import "UIColor+LeoColors.h"

@implementation PatientCell (ConfigureCell)


- (void)configureForPatient:(Patient *)patient {
    
    self.fullNameLabel.text = patient.fullName;
    
    if (patient.avatar) {
        self.avatarImageView.image = [LEOMessagesAvatarImageFactory circularAvatarImage:[UIImage imageNamed:@"Avatar-Emily"] withDiameter:40 borderColor:[UIColor leoGrayBorder] borderWidth:3];
        //This should really pull from the patient avatar image. But since we haven't set that up yet. This is a placeholder.
    } else {
        self.avatarImageView.image = [LEOMessagesAvatarImageFactory circularAvatarImage:[UIImage imageNamed:@"Avatar-Emily"] withDiameter:40 borderColor:[UIColor leoGrayBorder] borderWidth:3];
        //FIXME: Update with appropriate placeholder image.
    }
}

@end
