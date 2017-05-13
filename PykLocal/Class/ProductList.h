//
//  ProductList.h
//  PykLocal
//
//  Created by Mihin  Patel on 21/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductList : NSObject

@property (nonatomic, retain) NSString *strId;
@property (nonatomic, retain) NSString *strDescription;
@property (nonatomic, retain) NSString *strDiscount;
@property (nonatomic, retain) NSString *strReview;
@property (nonatomic, retain) NSString *strTotalOnHand;
@property (nonatomic, retain) NSString *strMinimumQuantity;
@property (nonatomic, retain) NSString *strAverageRatings;
@property (nonatomic, retain) NSString *strTotalRating;
@property (nonatomic, retain) NSString *strPrice;
@property (nonatomic, retain) NSString *strStockStatus;
@property (nonatomic, retain) NSString *strInWishlist;
@property (nonatomic, retain) NSString *strName;
@property (nonatomic, retain) NSString *strSpecialPrice;
@property (nonatomic, retain) NSString *strMasterVariantId;
@property (nonatomic, retain) NSString *strStoreName;
@property (nonatomic, retain) NSString *strStoreAddress;
@property (nonatomic, retain) NSString *strStoreId;
@property (nonatomic, retain) NSString *strOptionName;
@property (nonatomic, retain) NSString *strDeliveryType;
@property (nonatomic, retain) NSString *strQuantity;
@property (nonatomic, retain) NSString *strLineItemId;
@property (nonatomic, retain) NSString *strProductShareLink;

@property (nonatomic, retain) NSMutableArray *arrProductImages;
@property (nonatomic, retain) NSMutableArray *arrVariants;

@end
