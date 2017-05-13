//
//  CategoryProductDetails.h
//  QuickeSelling
//
//  Created by Saket Singhi on 03/11/15.
//  Copyright © 2015 JVSGroup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryProductDetails : NSObject

@property (nonatomic, retain) NSString *strSKU;
@property (nonatomic, retain) NSString *strName;
@property (nonatomic, retain) NSString *strImage;
@property (nonatomic, retain) NSString *strPrice;
@property (nonatomic, readwrite) float fltPrice;
@property (nonatomic, retain) NSString *strProductid;
@property (nonatomic, retain) NSString *strTypeid;
@property (nonatomic, retain) NSString *strSRP;
@property (nonatomic, retain) NSString *strshortdescription;
@property (nonatomic, retain) NSString *strThumbnailURL;
@property (nonatomic, retain) NSString *strSmallImageURL;
@property (nonatomic, retain) NSString *strSpecialprice;
@property (nonatomic, retain) NSString *strDescription;
@property (nonatomic, retain) NSString *strDiscount;
@property (nonatomic, retain) NSString *strProductDetailType;

@property (nonatomic, retain) NSMutableDictionary *dicProductDetails;
@property (nonatomic, retain) NSMutableArray *arrCategory;

@end
