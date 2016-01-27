//
//  LEOReviewUserCell.m
//  Leo
//
//  Created by Zachary Drossman on 10/5/15.
//  Copyright (c) 2015 Leo Health. All rights reserved.
//

#import "LEOReviewUserCell.h"

@implementation LEOReviewUserCell

- (void)awakeFromNib {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    //TODO: Remove "button, replace with UILabel, since we aren't actually using functionality of the control after all.
    self.editButton.enabled = NO;
}

+ (UINib *)nib {
    
    return [UINib nibWithNibName:@"LEOReviewUserCell" bundle:nil];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
