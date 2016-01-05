//
//  LEOPHRHeaderView.m
//  Leo
//
//  Created by Zachary Drossman on 12/28/15.
//  Copyright © 2015 Leo Health. All rights reserved.
//

#import "LEOPHRHeaderView.h"
#import "LEOPatientProfileView.h"
#import "LEOPatientSelectorView.h"
#import "UIColor+LeoColors.h"
#import <GNZSlidingSegment/GNZSegmentedControl.h>

@interface LEOPHRHeaderView ()

@property (weak, nonatomic) LEOPatientProfileView *patientProfileView;
@property (weak, nonatomic) LEOPatientSelectorView *patientSelectorView;

@property (strong, nonatomic) NSArray *patients;
@property (nonatomic) BOOL alreadyUpdatedConstraints;

@end

@implementation LEOPHRHeaderView

- (instancetype)initWithPatients:(NSArray *)patients {

    self = [super init];

    if (self) {
        _patients = patients;

        [self.segmentControl addTarget:self action:@selector(segmentDidChange:) forControlEvents:UIControlEventValueChanged];
    }

    return self;
}

- (LEOPatientProfileView *)patientProfileView {

    if (!_patientProfileView) {

        NSUInteger patientIndex = [self.patientSelectorView.segmentedControl selectedSegmentIndex];

        LEOPatientProfileView *strongPatientProfileView = [[LEOPatientProfileView alloc] initWithPatient:self.patients[patientIndex]];

        _patientProfileView = strongPatientProfileView;
        _patientProfileView.backgroundColor = [UIColor leo_orangeRed];
        [self addSubview:_patientProfileView];
    }

    return _patientProfileView;
}

- (LEOPatientSelectorView *)patientSelectorView {

    if (!_patientSelectorView) {

        LEOPatientSelectorView *strongPatientSelectorView = [[LEOPatientSelectorView alloc] initWithPatients:self.patients];

        _patientSelectorView = strongPatientSelectorView;

        [self addSubview:_patientSelectorView];

        _patientSelectorView.backgroundColor = [UIColor leo_orangeRed];
        _patientSelectorView.showsHorizontalScrollIndicator = NO;
    }

    return _patientSelectorView;
}

-(GNZSegmentedControl *)segmentControl {
    return self.patientSelectorView.segmentedControl;
}

- (void)updateConstraints {

    if (!self.alreadyUpdatedConstraints) {

        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.patientProfileView.translatesAutoresizingMaskIntoConstraints = NO;
        self.patientSelectorView.translatesAutoresizingMaskIntoConstraints = NO;

        NSDictionary *bindings = NSDictionaryOfVariableBindings(_patientProfileView, _patientSelectorView);

        NSArray *verticalConstraints;

        if ([self.patients count] > 1) {
            verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_patientProfileView]-(1)-[_patientSelectorView]|" options:0 metrics:nil views:bindings];

            NSArray *horizontalConstraintsForSelector = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_patientSelectorView]|" options:0 metrics:nil views:bindings];
            [self addConstraints:horizontalConstraintsForSelector];

        } else {
            verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_patientProfileView]|" options:0 metrics:nil views:bindings];
        }

        NSArray *horizontalConstraintsForProfile = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_patientProfileView]|" options:0 metrics:nil views:bindings];

        [self addConstraints:verticalConstraints];
        [self addConstraints:horizontalConstraintsForProfile];

        self.alreadyUpdatedConstraints = YES;
    }

    [super updateConstraints];
}

- (void)segmentDidChange:(UISegmentedControl *)sender
{
    NSUInteger segmentIndex = [sender selectedSegmentIndex];

    [self.patientSelectorView didChangeSegmentSelection:segmentIndex];
    self.patientProfileView.patient = self.patients[segmentIndex];
}


//- (void)didChangeSegmentSelection:(NSUInteger)segmentIndex {
//
//    [self.patientSelectorView didChangeSegmentSelection:segmentIndex];
//    self.patientProfileView.patient = self.patients[segmentIndex];
//}

@end
