//
//  ProductList.m
//  PykLocal
//
//  Created by Mihin  Patel on 21/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//


#import "ProductList.h"

@implementation ProductList


@synthesize strId;
@synthesize strDescription;
@synthesize strDiscount;
@synthesize strReview;
@synthesize strTotalOnHand;
@synthesize strMinimumQuantity;
@synthesize strAverageRatings;
@synthesize strTotalRating;
@synthesize strPrice;
@synthesize strStockStatus;
@synthesize strInWishlist;
@synthesize strName;
@synthesize strSpecialPrice;
@synthesize strMasterVariantId;
@synthesize strStoreName;
@synthesize strStoreAddress;
@synthesize strStoreId;
@synthesize strOptionName;
@synthesize strDeliveryType;
@synthesize strQuantity;
@synthesize strLineItemId;
@synthesize strProductShareLink;

@synthesize arrProductImages;
@synthesize arrVariants;

- (id)init
{
    self = [super init];
    if (self)
    {
        strId = @"";
        strDescription = @"";
        strDiscount = @"";
        strReview = @"";
        strTotalOnHand = @"";
        strMinimumQuantity = @"";
        strAverageRatings = @"";
        strTotalRating = @"";
        strPrice = @"";
        strStockStatus = @"";
        strInWishlist = @"";
        strName = @"";
        strStoreAddress = @"";
        strSpecialPrice = @"";
        strMasterVariantId = @"";
        strStoreName = @"";
        strStoreId = @"";
        strOptionName = @"";
        strDeliveryType = @"";
        strQuantity = @"";
        strLineItemId = @"";
        strProductShareLink = @"";
        
        arrProductImages = [[NSMutableArray alloc]init];
        arrVariants = [[NSMutableArray alloc]init];
    }
    return self;
}
@end
