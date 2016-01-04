//
//  LEOStickyHeaderView.m
//  Leo
//
//  Created by Zachary Drossman on 11/23/15.
//  Copyright © 2015 Leo Health. All rights reserved.
//

#import "LEOStickyHeaderView.h"
#import "UIColor+LeoColors.h"
#import "LEOStyleHelper.h"
#import <TPKeyboardAvoidingScrollView.h>
#import "LEOGradientView.h"

CGFloat const kTitleViewTopConstraintOriginalConstant = 0;

@interface LEOStickyHeaderView ()

@property (nonatomic) BOOL breakerIsOnScreen;
@property (strong, nonatomic) CAShapeLayer *pathLayer;
@property (weak, nonatomic) TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) UIView *titleView;
@property (strong, nonatomic) NSLayoutConstraint* titleViewTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint* bodyViewTopConstraint;
@property (weak, nonatomic) UIView *bodyView;
@property (weak, nonatomic) UIView *contentView;
@property (weak, nonatomic) UIView *separatorLine;
@property (weak, nonatomic) UIView *footerView;

@end

@implementation LEOStickyHeaderView

@synthesize bodyView = _bodyView;

- (instancetype)initWithBodyView:(UIView *)bodyView {

    self = [super init];
    if (self) {
        _bodyView = bodyView;
        [self commonInit];
    }
    return self;
}

- (instancetype) init {

    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {

    // default values
    self.collapsible = YES;
    [self setupSubviews];
    [self setupConstraints];
}

- (UIView *)contentView {

    if (!_contentView) {

        UIView *strongContentView = [UIView new];
        _contentView = strongContentView;

        UIView *strongBodyView = [UIView new];
        _bodyView = strongBodyView;

        UIView *strongTitleView = [UIView new];
        _titleView = strongTitleView;

        UIView *strongFooterView = [UIView new];
        _footerView = strongFooterView;


        [self.scrollView addSubview:_contentView];
        [_contentView addSubview:_bodyView];
        [_contentView addSubview:_titleView];
        [self addSubview:_footerView];
    }

    return _contentView;
}

- (UIScrollView *)scrollView {

    if (!_scrollView) {

        TPKeyboardAvoidingScrollView *strongView = [TPKeyboardAvoidingScrollView new];
        _scrollView = strongView;

        [self addSubview:_scrollView];

        _scrollView.delegate = self;
        _scrollView.bounces = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
    }

    return _scrollView;
}

- (UIView *)separatorLine {

    if (!_separatorLine) {

        UIView *strongView = [UIView new];
        _separatorLine = strongView;
        _separatorLine.backgroundColor = [UIColor leo_grayForPlaceholdersAndLines];
        [self addSubview:_separatorLine];
    }
    return _separatorLine;
}

- (void)reloadBodyView {

    [self.bodyView removeFromSuperview];
    UIView *strongBodyView = [self.datasource injectBodyView];
    _bodyView = strongBodyView;
    [self.contentView addSubview:_bodyView];
    [self setupConstraints];
}

- (void)reloadTitleView {

    [self.titleView removeFromSuperview];
    UIView* strongTitleView = [self.datasource injectTitleView];
    _titleView = strongTitleView;
    [self.contentView addSubview:_titleView];
    [self setupConstraints];
}

- (void)reloadFooterView {

    if ([self.datasource respondsToSelector:@selector(injectFooterView)]) {
        UIView* strongFooterView = [self.datasource injectFooterView];

        if (strongFooterView) {

            [self.footerView removeFromSuperview];

            _footerView = strongFooterView;
            [self addSubview:_footerView];
            [self setupConstraints];
        }
    }
}

- (void)setDatasource:(id<LEOStickyHeaderDataSource>)datasource {

    _datasource = datasource;

    [self reloadBodyView];
    [self reloadTitleView];
    [self reloadFooterView];
}

- (void)setupSubviews {

    self.contentView.backgroundColor = [UIColor blackColor];
    self.bodyView.backgroundColor = [UIColor redColor];
}

#pragma mark - Layout
-(CGSize)intrinsicContentSize {

    // Force the Scroll view to calculate its height
    [self.scrollView layoutIfNeeded];

    CGFloat heightWeWouldLikeTheScrollViewContentAreaToBe = [self heightOfScrollViewFrame] + [self heightOfHeaderCellExcludingOverlapWithNavBar];

    if ([self totalHeightOfScrollViewContentArea] > [self heightOfScrollViewFrame] && [self totalHeightOfScrollViewContentArea] < heightWeWouldLikeTheScrollViewContentAreaToBe) {

        CGFloat bottomInsetWeNeedToGetToHeightWeWouldLikeTheScrollViewContentAreaToBe = heightWeWouldLikeTheScrollViewContentAreaToBe - [self totalHeightOfScrollViewContentArea];
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, bottomInsetWeNeedToGetToHeightWeWouldLikeTheScrollViewContentAreaToBe, 0);
    }

    [self.scrollView layoutIfNeeded];

    return self.scrollView.contentSize;
}

-(void)layoutSubviews {

    [super layoutSubviews];
    if (!self.pathLayer) {
        [self setupBreaker];
    }
    self.bodyViewTopConstraint.constant = CGRectGetHeight(self.titleView.bounds);
    [super layoutSubviews];
}

//FIXME: Remove magic numbers / hard coding.
//TODO: Consider moving autolayout out of a single method into accessor helper methods.
- (void)setupConstraints {

    [self.scrollView removeConstraints:self.scrollView.constraints];
    [self.contentView removeConstraints:self.contentView.constraints];

    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bodyView.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleView.translatesAutoresizingMaskIntoConstraints = NO;
    self.separatorLine.translatesAutoresizingMaskIntoConstraints = NO;
    self.footerView.translatesAutoresizingMaskIntoConstraints = NO;

    // set Z index so other views will scroll underneath the title view
    if ([self.titleView.superview.subviews indexOfObject:self.titleView] != self.titleView.superview.subviews.count) {
        [self.titleView.superview bringSubviewToFront:self.titleView];
    }

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_titleView, _bodyView, _scrollView, _contentView, _separatorLine, _footerView);

    NSArray *verticalLayoutConstraintsForScrollView = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView][_separatorLine(==1)][_footerView]|" options:0 metrics:nil views:viewDictionary];
    NSArray *horizontalLayoutConstraintsForButtonView = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_footerView]|" options:0 metrics:nil views:viewDictionary];
    NSArray *horizontalLayoutConstraintsForScrollView = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:viewDictionary];
    NSArray *horizontalLayoutConstraintsForSeparatorLineView = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_separatorLine]|" options:0 metrics:nil views:viewDictionary];

    [self addConstraints:verticalLayoutConstraintsForScrollView];
    [self addConstraints:horizontalLayoutConstraintsForScrollView];
    [self addConstraints:horizontalLayoutConstraintsForSeparatorLineView];
    [self addConstraints:horizontalLayoutConstraintsForButtonView];

    NSArray *verticalLayoutConstraintsForContentView = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|" options:0 metrics:nil views:viewDictionary];
    NSArray *horizontalLayoutConstraintsForContentView = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|" options:0 metrics:nil views:viewDictionary];
    [self.scrollView addConstraints:verticalLayoutConstraintsForContentView];
    [self.scrollView addConstraints:horizontalLayoutConstraintsForContentView];

// handled in subview
//    NSLayoutConstraint *titleHeightConstraint = [NSLayoutConstraint constraintWithItem:_titleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kTitleHeight];

    self.titleViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:kTitleViewTopConstraintOriginalConstant];
    self.bodyViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.bodyView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:100];

    NSArray *verticalLayoutConstraintsForBodyView = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bodyView]|" options:0 metrics:nil views:viewDictionary];

    //TODO: This definitely is not the "right" solution. It is the "work" solution. The hardcoding here cannot be removed with this as the solution. Revisit and think through alternative.
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width - 20;
    CGFloat screenWidthWithMargins = screenWidth - 60;
    NSArray *horizontalTitleViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleView(w)]" options:0 metrics:@{@"w" : @(screenWidth)} views:viewDictionary];
    NSArray *horizontalBodyViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(30)-[_bodyView(wM)]-(30)-|" options:0 metrics:@{@"wM" : @(screenWidthWithMargins)} views:viewDictionary];

    [self.contentView addConstraints:horizontalBodyViewConstraints];
    [self.contentView addConstraints:horizontalTitleViewConstraints];
    [self.contentView addConstraint:self.titleViewTopConstraint];
    [self.contentView addConstraint:self.bodyViewTopConstraint];
    [self.contentView addConstraints:verticalLayoutConstraintsForBodyView];
}

- (void)animateBreakerIfNeeded {

    if ([self isCollapsed] && !self.breakerIsOnScreen) {
        [self fadeBreakerIn];
    } else if (![self isCollapsed] && self.breakerIsOnScreen) {
        [self fadeBreakerOut];
    }
}

- (void)fadeBreakerOut {

    [self updateBreakerWithBlock:^(CABasicAnimation *fadeAnimation) {

        [self fadeAnimation:fadeAnimation fromColor:[LEOStyleHelper tintColorForFeature:self.feature] toColor:[UIColor clearColor]];
    }];

    self.breakerIsOnScreen = NO;
}

- (void)fadeBreakerIn {

    [self updateBreakerWithBlock:^(CABasicAnimation *fadeAnimation) {

        [self fadeAnimation:fadeAnimation fromColor:[UIColor clearColor] toColor:[LEOStyleHelper tintColorForFeature:self.feature]];
    }];

    self.breakerIsOnScreen = YES;
}

- (void)updateBreakerWithBlock:(void (^) (CABasicAnimation *fadeAnimation))transitionBlock {

    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    fadeAnimation.duration = .3;

    transitionBlock(fadeAnimation);

    [self.pathLayer addAnimation:fadeAnimation forKey:@"strokeColor"];
}

- (void)fadeAnimation:(CABasicAnimation *)fadeAnimation fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor {

    fadeAnimation.fromValue = (id)fromColor.CGColor;
    fadeAnimation.toValue = (id)toColor.CGColor;
    self.pathLayer.strokeColor = toColor.CGColor;
}

- (void)drawBreaker {

    CGPoint beginningOfLine = CGPointMake(0, [self navBarHeight]);
    CGPoint endOfLine = CGPointMake(CGRectGetMaxX(self.bounds), [self navBarHeight]);

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:beginningOfLine];
    [path addLineToPoint:endOfLine];

    self.pathLayer = [CAShapeLayer layer];
    self.pathLayer.frame = self.bounds;
    self.pathLayer.path = path.CGPath;
    self.pathLayer.strokeColor = [UIColor clearColor].CGColor;
    self.pathLayer.lineWidth = 1.f;
    self.pathLayer.lineJoin = kCALineJoinBevel;

    [self.layer addSublayer:self.pathLayer];
}

- (void)setupBreaker {

    [self drawBreaker];
    self.breakerIsOnScreen = NO;
}

#pragma mark - <UIScrollViewDelegate> & Helper Methods

-(void)updateTransitionPercentageForScrollOffset:(CGPoint)offset {

    [self animateBreakerIfNeeded];

    // stick titleView to top
    if (self.scrollView.contentOffset.y > [self heightOfTitleView] - [self navBarHeight]) {
        self.titleViewTopConstraint.constant = self.scrollView.contentOffset.y - [self heightOfTitleView] + [self navBarHeight];
    } else {
        self.titleViewTopConstraint.constant = kTitleViewTopConstraintOriginalConstant;
    }

    // update gradient
    CGFloat percentage = [self transitionPercentageForScrollOffset:offset];
    percentage = percentage > 1 ? 1 : percentage;
    [self.delegate updateTitleViewForScrollTransitionPercentage:percentage];
}

-(CGFloat)transitionPercentageForScrollOffset:(CGPoint)offset {
    return self.scrollView.contentOffset.y / ([self heightOfTitleView] - [self navBarHeight]);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView == self.scrollView) {

        [self updateTransitionPercentageForScrollOffset:self.scrollViewContentOffset];
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

    if (scrollView == self.scrollView) {

        decelerate ? nil : [self navigationTitleViewSnapsForScrollView:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    if (scrollView == self.scrollView) {
        [self navigationTitleViewSnapsForScrollView:scrollView];
    }
}

- (void)navigationTitleViewSnapsForScrollView:(UIScrollView *)scrollView {

    // Note: what is the desired functionality here? Do we want to disable the scrolling animations as well?
    if (self.isCollapsible) {

        // Force collapse
        if ([self scrollViewVerticalContentOffset] > [self heightOfNoReturn] && [self scrollViewVerticalContentOffset] < [self heightOfHeaderCellExcludingOverlapWithNavBar]) {

            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{

                scrollView.contentOffset = CGPointMake(0.0, [ self heightOfHeaderCellExcludingOverlapWithNavBar]);
            } completion:^(BOOL finished) {

                [self animateBreakerIfNeeded];
            }];
        }

        // Force expand
        else if ([self scrollViewVerticalContentOffset] < [self heightOfNoReturn]) {

            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{

                scrollView.contentOffset = CGPointMake(0.0, 0.0);
            } completion:^(BOOL finished) {

                [self animateBreakerIfNeeded];
            }];
        }
    }
}

-(BOOL)isCollapsed {
    return [self scrollViewVerticalContentOffset] >= [self heightOfHeaderCellExcludingOverlapWithNavBar];
}

#pragma mark - Shorthand Helpers

- (CGFloat)heightOfScrollViewFrame {
    return self.scrollView.frame.size.height;
}

- (CGFloat)totalHeightOfScrollViewContentArea {
    return self.scrollView.contentSize.height + self.scrollView.contentInset.bottom;
}

- (CGFloat)heightOfNoReturn {
    return [self heightOfTitleView] * kHeightOfNoReturnConstant;
}

- (CGFloat)heightOfHeaderCellExcludingOverlapWithNavBar {
    return [self heightOfTitleView] - [self navBarHeight];
}

- (CGFloat)navBarHeight {
    return self.snapToHeight;
}

- (CGFloat)heightOfTitleView {
    return self.titleView.bounds.size.height;
}

- (UIView *)headerView {
    return self.titleView;
}

- (CGFloat)scrollViewVerticalContentOffset {
    return self.scrollViewContentOffset.y;
}

-(CGPoint)scrollViewContentOffset {
    return self.scrollView.contentOffset;
}


@end
