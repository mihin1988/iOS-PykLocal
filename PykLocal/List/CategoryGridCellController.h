//
//  CategoryGridCellController.h
//  QuickeSelling
//
//  Created by Saket Singhi on 02/12/15.
//  Copyright © 2015 JVSGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryGridCellController : UICollectionViewCell

@property (retain, nonatomic) IBOutlet UIImageView *ivImage;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblPrice;
@property (retain, nonatomic) IBOutlet UIButton *btnAddToWish;
@property (retain, nonatomic) IBOutlet UIButton *btnMore;
@property (retain, nonatomic) IBOutlet UIView *viewOffer;
@end
