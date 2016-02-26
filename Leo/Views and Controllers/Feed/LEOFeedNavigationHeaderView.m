//
//  LEOFeedNavigationHeaderView.m
//  Leo
//
//  Created by Zachary Drossman on 2/23/16.
//  Copyright © 2016 Leo Health. All rights reserved.
//

#import "LEOFeedNavigationHeaderView.h"

#import "UIColor+LeoColors.h"
#import "UIFont+LeoFonts.h"
#import "UIButton+Extensions.h"
#import "UIView+Extensions.h"

@interface LEOFeedNavigationHeaderView ()

@property (nonatomic) BOOL alreadyUpdatedConstraints;

@end

@implementation LEOFeedNavigationHeaderView

static NSInteger const kInset = 8;
static NSInteger const kButtonHeight = 44;
static NSInteger const kLineThickness = 1;

#pragma mark - Accessors

- (UIButton *)bookAppointmentButton {

    if (!_bookAppointmentButton) {

         UIButton *strongButton = [UIButton leo_newButtonWithDisabledStyling];

        _bookAppointmentButton = strongButton;

        [self addSubview:_bookAppointmentButton];

        [_bookAppointmentButton setTitle:@"SCHEDULE A VISIT" forState:UIControlStateNormal];
        [_bookAppointmentButton setTitleColor:[UIColor leo_orangeRed] forState:UIControlStateNormal];
        _bookAppointmentButton.titleLabel.font = [UIFont leo_buttonLabelsAndTimeStampsFont];

        [_bookAppointmentButton addTarget:self action:@selector(bookAppointmentTouchedUpInside) forControlEvents:UIControlEventTouchUpInside];
    }

    return _bookAppointmentButton;
}

- (UIButton *)messageUsButton {

    if (!_messageUsButton) {

        UIButton *strongButton = [UIButton leo_newButtonWithDisabledStyling];

        _messageUsButton = strongButton;

        [self addSubview:_messageUsButton];

        [_messageUsButton setTitle:@"MESSAGE US" forState:UIControlStateNormal];
        [_messageUsButton setTitleColor:[UIColor leo_orangeRed] forState:UIControlStateNormal];
        _messageUsButton.titleLabel.font = [UIFont leo_buttonLabelsAndTimeStampsFont];

        [_messageUsButton addTarget:self action:@selector(messageUsTouchedUpInside) forControlEvents:UIControlEventTouchUpInside];
    }

    return _messageUsButton;
}


#pragma mark - Actions

- (void)bookAppointmentTouchedUpInside {

    if ([self.delegate respondsToSelector:@selector(bookAppointmentTouchedUpInside)]) {
        [self.delegate bookAppointmentTouchedUpInside];
    }
}

- (void)messageUsTouchedUpInside {

    if ([self.delegate respondsToSelector:@selector(messageUsTouchedUpInside)]) {
        [self.delegate messageUsTouchedUpInside];
    }
}


#pragma mark - Autolayout

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {

    [super updateConstraints];
    
    if (!self.alreadyUpdatedConstraints) {

        self.bookAppointmentButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.messageUsButton.translatesAutoresizingMaskIntoConstraints = NO;

        UIView *splitView = [UIView new];
        splitView.backgroundColor = [UIColor leo_orangeRed];
        [self addSubview:splitView];
        splitView.translatesAutoresizingMaskIntoConstraints = NO;

        UIView *breakerView = [UIView new];
        breakerView.backgroundColor = [UIColor leo_grayForTimeStamps];
        [self addSubview:breakerView];
        breakerView.translatesAutoresizingMaskIntoConstraints = NO;

        NSDictionary *bindings = @{@"bookAppointment":_bookAppointmentButton, @"split":splitView, @"messageUs":_messageUsButton, @"breaker":breakerView};

        NSDictionary *metrics = @{@"lineThickness":@(kLineThickness), @"buttonHeight":@(kButtonHeight), @"splitInset": @(kInset)};

        NSArray *verticalConstraintForMessageButton = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[messageUs(buttonHeight)][breaker(lineThickness)]|" options:0 metrics:metrics views:bindings];

        NSArray *verticalConstraintForBookAppointmentButton = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bookAppointment(buttonHeight)]" options:0 metrics:metrics views:bindings];

        NSArray *verticalConstraintForSplitView = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(splitInset)-[split]-(splitInset)-|" options:0 metrics:metrics views:bindings];

        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bookAppointment][split(lineThickness)][messageUs(==bookAppointment)]|" options:0 metrics:metrics views:bindings];

        NSArray *horizontalConstraintsForBreaker = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[breaker]|" options:0 metrics:metrics views:bindings];

        [self addConstraints:verticalConstraintForBookAppointmentButton];
        [self addConstraints:verticalConstraintForMessageButton];
        [self addConstraints:verticalConstraintForSplitView];
        [self addConstraints:horizontalConstraints];
        [self addConstraints:horizontalConstraintsForBreaker];

        self.alreadyUpdatedConstraints = YES;
    }

    [super updateConstraints];
}


@end
