//
//  LEOTwoButtonPrimaryAndSecondaryCell.m
//  Leo
//
//  Created by Zachary Drossman on 6/30/15.
//  Copyright (c) 2015 Leo Health. All rights reserved.
//

#import "LEOTwoButtonPrimaryAndSecondaryCell.h"

@implementation LEOTwoButtonPrimaryAndSecondaryCell

- (void)awakeFromNib {
   
    self.bodyView.layer.cornerRadius = 2.0;
    self.bodyView.layer.masksToBounds = YES;
    
    [self.bodyView.layer setShouldRasterize:YES];
    [self.bodyView.layer setRasterizationScale:[UIScreen mainScreen].scale];
}


+ (UINib *)nib {
    
    return [UINib nibWithNibName:@"LEOTwoButtonPrimaryAndSecondaryCell" bundle:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



@end