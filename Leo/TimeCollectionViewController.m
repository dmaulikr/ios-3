//
//  TimeCollectionViewController.m
//  Leo
//
//  Created by Zachary Drossman on 6/4/15.
//  Copyright (c) 2015 Leo Health. All rights reserved.
//

#import "TimeCollectionViewController.h"
#import "LEOCoreDataManager.h"
#import <NSDate+DateTools.h>
#import "LEOTimeCell.h"
#import "CollectionViewDataSource.h"

@interface TimeCollectionViewController ()

@property (strong, nonatomic) LEOCoreDataManager *coreDataManager;
@property (strong, nonatomic) CollectionViewDataSource *dataSource;

@end

@implementation TimeCollectionViewController

static NSString * const timeReuseIdentifier = @"TimeCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.coreDataManager = [LEOCoreDataManager sharedManager];
    [self setupTimeCollectionView];
}

- (void)setupTimeCollectionView {
    
    NSArray *times = [self.coreDataManager availableTimesForDate:self.selectedDate];
   
    void (^configureCell)(LEOTimeCell *, NSDate*) = ^(LEOTimeCell* cell, NSDate* date) {
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        timeFormat.dateFormat = @"h':'mm a";
        
        cell.timeLabel.text = [[timeFormat stringFromDate:date] lowercaseString];
    
    };
    
    self.dataSource = [[CollectionViewDataSource alloc] initWithItems:times cellIdentifier:timeReuseIdentifier configureCellBlock:configureCell];
    
    //repetitive since in the storyboard...
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:5.0f];
    [flowLayout setMinimumLineSpacing:5.0f];
    self.collectionView.collectionViewLayout = flowLayout;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self.dataSource;

    [self.collectionView registerNib:[UINib nibWithNibName:@"LEOTimeCell" bundle:nil]
              forCellWithReuseIdentifier:timeReuseIdentifier];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
        return CGSizeMake(100.0, 50.0);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
        return UIEdgeInsetsMake(0, 5, 0, 5);
}



@end