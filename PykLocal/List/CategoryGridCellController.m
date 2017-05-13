//
//  CategoryGridCellController.h
//  QuickeSelling
//
//  Created by Saket Singhi on 02/12/15.
//  Copyright © 2015 JVSGroup. All rights reserved.
//

#import "CategoryGridCellController.h"

@implementation CategoryGridCellController

@synthesize ivImage;
@synthesize lblTitle;
@synthesize lblPrice;
@synthesize btnAddToWish;
@synthesize btnMore;
@synthesize viewOffer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:ivImage];
        [self.contentView addSubview:lblTitle];
        [self.contentView addSubview:lblPrice];
        [self.contentView addSubview:btnAddToWish];
        [self.contentView addSubview:btnMore];
        [self.contentView addSubview:viewOffer];

    }
    return self;
}


@end
