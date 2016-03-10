//
//  LEOLoginViewController.m
//  Leo
//
//  Created by Zachary Drossman on 8/31/15.
//  Copyright (c) 2015 Leo Health. All rights reserved.
//

#import "LEOLoginViewController.h"
#import "LEOValidatedFloatLabeledTextField.h"
#import "UIFont+LeoFonts.h"
#import "UIColor+LeoColors.h"
#import "LEOHeaderView.h"

#import "UIImage+Extensions.h"
#import "LEOUserService.h"
#import "LEOValidationsHelper.h"
#import "LEOForgotPasswordViewController.h"
#import "LEOLoginView.h"
#import "LEOHelperService.h"
#import "LEOFeedTVC.h"
#import "LEOStyleHelper.h"
#import "NSObject+XibAdditions.h"
#import "UIView+Extensions.h"
#import <MBProgressHUD/MBProgressHUD.h>


@interface LEOLoginViewController ()

@property (strong, nonatomic) LEOLoginView *loginView;
@property (strong, nonatomic) LEOHeaderView *headerView;

@end

@implementation LEOLoginViewController

static NSString *const kForgotPasswordSegue = @"ForgotPasswordSegue";

#pragma mark - VCL & Helpers

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

    CGFloat percentage = [self transitionPercentageForScrollOffset:self.stickyHeaderView.scrollView.contentOffset];

    self.navigationItem.titleView.hidden = percentage == 0;
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    [LEOApiReachability startMonitoringForController:self withOfflineBlock:nil withOnlineBlock:nil];
}

- (void)setupNavigationBar {
    [LEOStyleHelper styleNavigationBarForViewController:self forFeature:self.feature withTitleText:@"Login" dismissal:NO backButton:YES];
}


#pragma mark - Accessors

- (LEOHeaderView *)headerView {

    if (!_headerView) {

        _headerView = [[LEOHeaderView alloc] initWithTitleText:@"Login to your Leo account"];
        _headerView.intrinsicHeight = @(kHeightOnboardingHeaders);
        [LEOStyleHelper styleExpandedTitleLabel:_headerView.titleLabel feature:self.feature];
    }

    return _headerView;
}

- (LEOLoginView *)loginView {

    if (!_loginView) {

        _loginView = [self leo_loadViewFromNibForClass:[LEOLoginView class]];
        _loginView.tintColor = [UIColor leo_orangeRed];
    }

    return _loginView;
}


#pragma mark - <LEOStickyHeaderViewDataSource>

- (UIView *)injectBodyView {
    return self.loginView;
}

- (UIView *)injectTitleView {
    return self.headerView;
}


#pragma mark - <LEOStickyHeaderViewDelegate>

-(void)updateTitleViewForScrollTransitionPercentage:(CGFloat)transitionPercentage {

    self.headerView.currentTransitionPercentage = transitionPercentage;
    self.navigationItem.titleView.hidden = NO;
    self.navigationItem.titleView.alpha = transitionPercentage;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:kForgotPasswordSegue]) {

        LEOForgotPasswordViewController *forgotPasswordVC = segue.destinationViewController;
        forgotPasswordVC.email = self.emailTextField.text;
    }
}


#pragma mark - Actions

- (void)pop {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)continueTapped:(UIButton *)sender {

    [Crittercism leaveBreadcrumb:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    BOOL validEmail = [LEOValidationsHelper isValidEmail:[self emailTextField].text];
    BOOL validPassword = [LEOValidationsHelper isValidPassword:[self passwordTextField].text];

    [self emailTextField].valid = validEmail;
    [self passwordTextField].valid = validPassword;

    if (validEmail && validPassword) {

        [self.view endEditing:YES];

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        LEOUserService *userService = [[LEOUserService alloc] init];
        [userService loginUserWithEmail:[self emailTextField].text
                               password:[self passwordTextField].text
                         withCompletion:^(SessionUser * user, NSError * error) {

                             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                             if (!error) {

                                 // Response to successful login is handled by a @"membership-changed" notification listener in AppDelegate

                                 //TODO: ZSD Determine whether we really have a flow when there is no error. Otherwise just use if (error) below.
                             } else {

                                 UIAlertController *loginAlert = [UIAlertController alertControllerWithTitle:@"Invalid login" message:@"Looks like your email or password isn't one we recognize. Try entering them again, or reset your password." preferredStyle:UIAlertControllerStyleAlert];

                                 UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];

                                 [loginAlert addAction:continueAction];

                                 [self presentViewController:loginAlert animated:YES completion:nil];
                             }
                         }];
    }
}

- (void)forgotPasswordTapped:(UIButton *)sender {

    [self performSegueWithIdentifier:kForgotPasswordSegue
                              sender:sender];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.view endEditing:YES];
}

#pragma mark - Shorthand Helpers

- (LEOValidatedFloatLabeledTextField *)emailTextField {
    return self.loginView.emailPromptField.textField;
}

- (LEOValidatedFloatLabeledTextField *)passwordTextField {
    return self.loginView.passwordPromptField.textField;
}


@end
