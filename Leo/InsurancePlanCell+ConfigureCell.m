//
//  InsurerCell+ConfigureCell.m
//  Leo
//
//  Created by Zachary Drossman on 9/3/15.
//  Copyright (c) 2015 Leo Health. All rights reserved.
//

#import "InsurancePlanCell+ConfigureCell.h"
#import "InsurancePlan.h"
#import "UIColor+LeoColors.h"
#import "UIFont+LeoFonts.h"
#import "Insurer.h"

@implementation InsurancePlanCell (ConfigureCell)

- (void)configureForPlan:(InsurancePlan *)plan {
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentLeft];
    [style setLineBreakMode:NSLineBreakByWordWrapping]; //TODO: May want to do some sort of resizing of the text here such that we don't end up wrapping ever.
    
    UIFont *font1 = [UIFont leoMenuOptionsAndSelectedTextInFormFieldsAndCollapsedNavigationBarsFont];
    UIFont *font2 = [UIFont leoFieldAndUserLabelsAndSecondaryButtonsFont];
    
    UIColor *color1 = [UIColor leoGrayForTitlesAndHeadings];
    UIColor *color2 = [UIColor leoGrayStandard];
    
    NSDictionary *attributedDictionary1 = @{NSForegroundColorAttributeName:color1,
                                            NSFontAttributeName:font1,
                                            NSParagraphStyleAttributeName:style};
    
    NSDictionary *attributedDictionary2 = @{NSForegroundColorAttributeName:color2,
                                            NSFontAttributeName:font2,
                                            NSParagraphStyleAttributeName:style};
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
    
    
    [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", plan.insurer.name]
                                                                       attributes:attributedDictionary1]];
    
    [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:plan.name
                                                                       attributes:attributedDictionary2]];
    
    self.insurancePlanLabel.attributedText = attrString;
}

@end
