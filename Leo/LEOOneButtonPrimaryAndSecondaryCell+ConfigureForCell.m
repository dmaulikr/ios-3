//
//  LEOOneButtonPrimaryAndSecondaryCell+ConfigureForCell.m
//  Leo
//
//  Created by Zachary Drossman on 6/30/15.
//  Copyright (c) 2015 Leo Health. All rights reserved.
//

#import "LEOOneButtonPrimaryAndSecondaryCell+ConfigureForCell.h"
#import "LEOCard.h"
#import "UIFont+LeoFonts.h"
#import "UIColor+LeoColors.h"
#import "LEOSecondaryUserView.h"

@implementation LEOOneButtonPrimaryAndSecondaryCell (ConfigureForCell)

- (void)configureForCard:(LEOCard *)card {
    
    self.iconImageView.image = [card icon];
    self.titleLabel.text = [card title];
    
    self.primaryUserLabel.text = [[card primaryUser].firstName uppercaseString];
    
    self.secondaryUserView.provider = (Provider *)card.secondaryUser;
    self.secondaryUserView.timeStamp = card.timestamp;
    self.secondaryUserView.cardLayout = CardLayoutOneButtonPrimaryAndSecondary;
    self.secondaryUserView.backgroundColor = [UIColor clearColor];
    self.bodyLabel.text = [card body];
    
    [self.buttonOne setTitle:[card stringRepresentationOfActionsAvailableForState][0] forState:UIControlStateNormal];
    [self.buttonOne removeTarget:nil action:NULL forControlEvents:self.buttonOne.allControlEvents];
    [self.buttonOne addTarget:card action:NSSelectorFromString([card actionsAvailableForState][0]) forControlEvents:UIControlEventTouchUpInside];
    
    [self formatSubviewsWithTintColor:card.tintColor];
    [self setCopyFontAndColor];
    
    //FIXME: Should I have access to this method outside of secondaryUserViews
    [self.secondaryUserView refreshSubviews];
}


- (void)formatSubviewsWithTintColor:(UIColor *)tintColor {
    
    self.borderViewAtTopOfBodyView.backgroundColor = tintColor;
    self.secondaryUserView.cardColor = tintColor;
}

- (void)setCopyFontAndColor {
    
    self.titleLabel.font = [UIFont leoCollapsedCardTitlesFont];
    self.titleLabel.textColor = [UIColor leoGrayForTitlesAndHeadings];
    
    self.primaryUserLabel.font = [UIFont leoFieldAndUserLabelsAndSecondaryButtonsFont];
    //self.primaryUserLabel.textColor to be set by card.
    
    self.bodyLabel.font = [UIFont leoStandardFont];
    self.bodyLabel.textColor = [UIColor leoGrayStandard];
    
    self.buttonOne.titleLabel.font = [UIFont leoButtonLabelsAndTimeStampsFont];
    [self.buttonOne setTitleColor:[UIColor leoGrayStandard] forState:UIControlStateNormal];
}


@end
