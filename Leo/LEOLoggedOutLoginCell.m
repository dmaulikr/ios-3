//
//  LEOLoggedOutLoginCell.m
//  Leo
//
//  Created by Adam Fanslau on 1/25/16.
//  Copyright © 2016 Leo Health. All rights reserved.
//

#import "LEOLoggedOutLoginCell.h"
#import "UIColor+LeoColors.h"
#import "UIFont+LeoFonts.h"
#import "UIButton+Extensions.h"

@implementation LEOLoggedOutLoginCell

- (void)awakeFromNib {

    [super awakeFromNib];

    self.swipeArrowsView.labelSwipe.hidden = NO;
    self.swipeArrowsView.arrowColor = LEOSwipeArrowsColorOptionOrangeRed;
}


@end
