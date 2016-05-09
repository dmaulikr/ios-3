//
//  LEOReviewOnboardingViewController.m
//  Leo
//
//  Created by Zachary Drossman on 10/5/15.
//  Copyright (c) 2015 Leo Health. All rights reserved.
//

#import "LEOReviewOnboardingViewController.h"
#import "Configuration.h"

#import "LEOUserService.h"
#import "LEOPaymentService.h"

#import "SessionUser.h"
#import "Family.h"
#import "Patient.h"
#import "Guardian.h"
#import "InsurancePlan.h"

#import "LEOSignUpPatientViewController.h"
#import "LEOSignUpUserViewController.h"
#import "LEOPaymentViewController.h"

#import "UIColor+LeoColors.h"
#import "UIFont+LeoFonts.h"
#import "UIView+Extensions.h"

#import "LEOStyleHelper.h"

#import "LEOFeedTVC.h"
#import "LEOWebViewController.h"

#import "UIImage+Extensions.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import "LEOReviewOnboardingView.h"
#import "LEOProgressDotsHeaderView.h"
#import "NSObject+XibAdditions.h"
#import "LEOIntrinsicSizeTableView.h"

#import "LEOButtonCell.h"
#import "LEOReviewPatientCell.h"
#import "LEOReviewUserCell.h"
#import "LEOCachedDataStore.h"
#import "LEOPaymentDetailsCell.h"

#import "LEOAlertHelper.h"

@interface LEOReviewOnboardingViewController ()

@property (weak, nonatomic) UILabel *navTitleLabel;
@property (strong, nonatomic) LEOReviewOnboardingView *reviewOnboardingView;
@property (strong, nonatomic) LEOProgressDotsHeaderView *headerView;


@end

@implementation LEOReviewOnboardingViewController


#pragma mark - Constants

static NSString *const kReviewUserSegue = @"ReviewUserSegue";
static NSString *const kReviewPatientSegue = @"ReviewPatientSegue";
static NSString *const kCopyHeaderReviewOnboarding = @"Please confirm your family information";
static NSString *const kReviewPaymentDetails = @"ReviewPaymentDetails";

#pragma mark - View Controller Lifecycle and Helpers

- (void)viewDidLoad {

    [super viewDidLoad];

    [self.view setupTouchEventForDismissingKeyboard];

    self.feature = FeatureOnboarding;
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.stickyHeaderView.snapToHeight = @(0);
    self.stickyHeaderView.datasource = self;
    self.stickyHeaderView.delegate = self;

    [self setupNavigationBar];

    [LEOApiReachability startMonitoringForController:self];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [self setupNavigationBar];
    [self.reviewOnboardingView.tableView reloadData];

    CGFloat percentage = [self transitionPercentageForScrollOffset:self.stickyHeaderView.scrollView.contentOffset];

    self.navigationItem.titleView.hidden = percentage == 0;
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [Localytics tagScreen:kAnalyticScreenReviewRegistration];

    [LEOApiReachability startMonitoringForController:self withOfflineBlock:nil withOnlineBlock:nil];
}

- (void)setupNavigationBar {
    [LEOStyleHelper styleNavigationBarForViewController:self forFeature:self.feature withTitleText:@"Confirm Your Data" dismissal:NO backButton:NO];

    [LEOStyleHelper styleNavigationBar:self.navigationController.navigationBar forFeature:FeatureOnboarding];
    self.navigationItem.hidesBackButton = YES;
}


#pragma <LEOStickyHeaderViewDataSource>

- (UIView *)injectTitleView {
    return self.headerView;
}

- (UIView *)injectBodyView {
    return self.reviewOnboardingView;
}


#pragma mark - Accessors

- (LEOReviewOnboardingView *)reviewOnboardingView {

    if (!_reviewOnboardingView) {

        _reviewOnboardingView = [self leo_loadViewFromNibForClass:[LEOReviewOnboardingView class]];
        _reviewOnboardingView.family = self.family;
        _reviewOnboardingView.tableView.delegate = self;
        _reviewOnboardingView.controller = self;
        _reviewOnboardingView.paymentDetails = self.paymentDetails;
    }

    return _reviewOnboardingView;
}

- (LEOProgressDotsHeaderView *)headerView {

    if (!_headerView) {

        _headerView = [[LEOProgressDotsHeaderView alloc] initWithTitleText:kCopyHeaderReviewOnboarding numberOfCircles:kNumberOfProgressDots currentIndex:5 fillColor:[UIColor leo_orangeRed]];
        _headerView.intrinsicHeight = @(kHeightOnboardingHeaders);
        [LEOStyleHelper styleExpandedTitleLabel:_headerView.titleLabel feature:self.feature];
    }
    
    return _headerView;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
        case TableViewSectionButton:
            return [[LEOButtonCell new] intrinsicContentSize].height;

        case TableViewSectionGuardians:
            return [[LEOReviewUserCell new] intrinsicContentSize].height;

        case TableViewSectionPaymentDetails:
            return [[LEOPaymentDetailsCell new] intrinsicContentSize].height;
            
        case TableViewSectionPatients:
            return [[LEOReviewPatientCell new] intrinsicContentSize].height;
    }
    return 0;
}

- (void)editButtonTouchUpInside:(UIButton *)sender {

    CGPoint center = [sender convertPoint:sender.center toView:self.reviewOnboardingView.tableView];
    NSIndexPath *ip = [self.reviewOnboardingView.tableView indexPathForRowAtPoint:center];
    [self tableView:self.reviewOnboardingView.tableView didSelectRowAtIndexPath:ip];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
        case TableViewSectionGuardians: {

            [LEOBreadcrumb crumbWithObject:[NSString stringWithFormat:@"%s edit guardian", __PRETTY_FUNCTION__]];

            Guardian *guardian = self.family.guardians[indexPath.row];
            [self performSegueWithIdentifier:kReviewUserSegue sender:guardian];
            break;
        }

        case TableViewSectionPatients: {

            [LEOBreadcrumb crumbWithObject:[NSString stringWithFormat:@"%s edit patient", __PRETTY_FUNCTION__]];

            Patient *patient = self.family.patients[indexPath.row];
            [self performSegueWithIdentifier:kReviewPatientSegue sender:patient];
            break;
        }

        case TableViewSectionPaymentDetails: {

            [LEOBreadcrumb crumbWithObject:[NSString stringWithFormat:@"%s edit payment details", __PRETTY_FUNCTION__]];

            [self performSegueWithIdentifier:kReviewPaymentDetails sender:nil];
        }

        case TableViewSectionButton:
            break;
    }
}


#pragma mark - Actions

- (void)tapOnTermsOfServiceLink:(UITapGestureRecognizer *)tapGesture {

    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        [self performSegueWithIdentifier:kSegueTermsAndConditions sender:nil];
    }
}

- (void)tapOnPrivacyPolicyLink:(UITapGestureRecognizer *)tapGesture {

    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        [self performSegueWithIdentifier:kSeguePrivacyPolicy sender:nil];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:kReviewUserSegue]) {

        LEOSignUpUserViewController *signUpUserVC = segue.destinationViewController;
        signUpUserVC.guardian = sender;
        signUpUserVC.managementMode = ManagementModeEdit;
    }

    if ([segue.identifier isEqualToString:kReviewPatientSegue]) {

        LEOSignUpPatientViewController *signUpPatientVC = segue.destinationViewController;
        signUpPatientVC.patient = sender;
        signUpPatientVC.feature = FeatureOnboarding;
        signUpPatientVC.managementMode = ManagementModeEdit;
    }

    if ([segue.identifier isEqualToString:kSegueTermsAndConditions]) {

        LEOWebViewController *webVC = (LEOWebViewController *)segue.destinationViewController;
        webVC.urlString = [NSString stringWithFormat:@"%@%@", [Configuration providerBaseURL], kURLTermsOfService];
        webVC.titleString = kCopyTermsOfService;
        webVC.feature = FeatureOnboarding;
    }

    if ([segue.identifier isEqualToString:kSeguePrivacyPolicy]) {

        LEOWebViewController *webVC = (LEOWebViewController *)segue.destinationViewController;
        webVC.urlString = [NSString stringWithFormat:@"%@%@", [Configuration providerBaseURL], kURLPrivacyPolicy];
        webVC.titleString = @"Privacy Policy";
        webVC.feature = FeatureOnboarding;
    }

    if ([segue.identifier isEqualToString:kReviewPaymentDetails]) {
        LEOPaymentViewController *paymentVC = (LEOPaymentViewController *)segue.destinationViewController;
        paymentVC.family = self.family;
        paymentVC.feature = FeatureOnboarding;
        paymentVC.managementMode = ManagementModeEdit;
        paymentVC.delegate = self;
    }
}

-(void)updatePaymentWithPaymentDetails:(STPToken *)paymentDetails {

    _paymentDetails = paymentDetails;

    self.reviewOnboardingView.paymentDetails = paymentDetails;
}

- (void)continueTapped:(UIButton *)sender {

    [LEOBreadcrumb crumbWithFunction:__PRETTY_FUNCTION__];

    BOOL isSecondGuardian = self.family.guardians.count > 1;
    __block BOOL attemptedAdditionOfCaregiver;
    __block BOOL attemptedPatientCreation;

    __block UIButton *button = sender;

    button.enabled = NO;

    NSArray *patients = [self.family.patients copy];
    self.family.patients = @[];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    LEOUserService *userService = [LEOUserService new];

    [userService createGuardian:self.family.guardians.firstObject withCompletion:^(Guardian *guardian, NSError *error) {

        if (!error && guardian) {

            if (isSecondGuardian) {

                Guardian *otherGuardian = self.family.guardians.lastObject;
                [userService addCaregiver:otherGuardian withCompletion:^(BOOL success, NSError *error) {


                    attemptedAdditionOfCaregiver = YES;

                    if (success) {
                        [Localytics tagEvent:kAnalyticEventAddCaregiverFromRegistration];
                    }

                    if (attemptedPatientCreation) {

                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        button.enabled = YES;
                    }
                }];
            }

            //The guardian that is created should technically take the place of the original, given it will have an id and family_id.t=
            self.family.guardians = @[guardian];

            [userService createPatients:patients withCompletion:^(NSArray<Patient *> *responsePatients, NSError *error) {

                attemptedPatientCreation = YES;

                if (error) {

                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    button.enabled = YES;
                    [LEOAlertHelper alertForViewController:self error:error backupTitle:@"Something went wrong!" backupMessage:@"Please check your information and your internet connection and try again."];

                    return;
                }


                [[LEOPaymentService new] createChargeWithToken:self.paymentDetails completion:^(BOOL success, NSError *error) {

                    if (error) {

                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        button.enabled = YES;
                        [LEOAlertHelper alertForViewController:self error:error backupTitle:@"Something went wrong!" backupMessage:@"Please check your information and your internet connection and try again."];

                        return;
                    }

                    [Localytics tagEvent:kAnalyticEventConfirmAccount];

                    [self.analyticSession completeSession];

                    self.analyticSession = nil;

                    self.family.patients = responsePatients;

                    [LEOCachedDataStore sharedInstance].family = self.family;

                    [userService postAvatarsForUsers:responsePatients withCompletion:^(BOOL success, NSError *error) {
                        [LEOCachedDataStore sharedInstance].family = self.family;
                    }];


                    if (isSecondGuardian && attemptedAdditionOfCaregiver) {

                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        button.enabled = YES;
                    }
                }];
            }];
        }
    }];
}

@end
