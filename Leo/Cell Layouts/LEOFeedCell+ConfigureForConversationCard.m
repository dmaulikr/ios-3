//
//  LEOFeedCell+ConfigureForConversationCard.m
//  Leo
//
//  Created by Zachary Drossman on 3/3/16.
//  Copyright © 2016 Leo Health. All rights reserved.
//

#import "LEOFeedCell+ConfigureForConversationCard.h"
#import "LEOCardConversation.h"
#import "LEOFeedCellButtonView.h"
#import "LEOCardUserView.h"
#import "NSDate+DateTools.h"
#import "UIView+Extensions.h"
#import "UIColor+LeoColors.h"
#import "UIFont+LeoFonts.h"

@implementation LEOFeedCell (ConfigureForConversationCard)

- (void)configureSubviewsForConversationCard:(LEOCardConversation *)card {

    [self conversation_configureFooterViewForCard:card];
    [self conversation_configureHeaderViewForCard:card];
    [self conversation_configureButtonViewForCard:card];
}


- (void)conversation_configureButtonViewForCard:(LEOCardConversation *)card {

    LEOFeedCellButtonView *activityView = [[LEOFeedCellButtonView alloc] initWithCard:card];
    activityView.tintColor = self.tintColor;

    [activityView leo_pinToSuperView:self.buttonView];

}

- (void)conversation_configureHeaderViewForCard:(LEOCardConversation *)card {

    LEOCardUserView *userView = [[LEOCardUserView alloc] initWithUser:(Provider *)card.secondaryUser cardColor:card.tintColor];

    [userView leo_pinToSuperView:self.headerView];
}

- (void)conversation_configureFooterViewForCard:(LEOCardConversation *)card {

    UILabel *timestampLabel = [UILabel new];

    [timestampLabel leo_pinToSuperView:self.footerView];

    timestampLabel.text = [NSString stringWithFormat:@"Sent %@",[card.timestamp.timeAgoSinceNow lowercaseString]];
    timestampLabel.textColor = [UIColor leo_grayForTimeStamps];
    timestampLabel.font = [UIFont leo_buttonLabelsAndTimeStampsFont];
}


@end
