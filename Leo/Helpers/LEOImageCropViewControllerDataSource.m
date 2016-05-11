//
//  LEOImageCropViewControllerDataSource.m
//  Leo
//
//  Created by Zachary Drossman on 12/14/15.
//  Copyright © 2015 Leo Health. All rights reserved.
//

#import "LEOImageCropViewControllerDataSource.h"

@implementation LEOImageCropViewControllerDataSource

// Returns a custom rect for the mask.
- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller {
    return [UIScreen mainScreen].bounds;
}

// Returns a custom path for the mask.
- (UIBezierPath *)imageCropViewControllerCustomMaskPath:(RSKImageCropViewController *)controller {

    CGRect rect = controller.maskRect;

    CGPoint point1 = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGPoint point2 = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGPoint point3 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGPoint point4 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));

    UIBezierPath *rectangle = [UIBezierPath bezierPath];
    [rectangle moveToPoint:point1];
    [rectangle addLineToPoint:point2];
    [rectangle addLineToPoint:point3];
    [rectangle addLineToPoint:point4];
    [rectangle closePath];

    return rectangle;
}

// Returns a custom rect in which the image can be moved.
- (CGRect)imageCropViewControllerCustomMovementRect:(RSKImageCropViewController *)controller {
    // If the image is not rotated, then the movement rect coincides with the mask rect.
    return controller.view.bounds;
}
@end
