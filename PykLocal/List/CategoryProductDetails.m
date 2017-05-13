//
//  CategoryProductDetails.m
//  QuickeSelling
//
//  Created by Saket Singhi on 03/11/15.
//  Copyright © 2015 JVSGroup. All rights reserved.
//

#import "CategoryProductDetails.h"

@implementation CategoryProductDetails


@synthesize strSKU;
@synthesize strName;
@synthesize strImage;
@synthesize strPrice;
@synthesize fltPrice;
@synthesize strProductid;
@synthesize strTypeid;
@synthesize strSRP;
@synthesize strshortdescription;
@synthesize strThumbnailURL;
@synthesize strSmallImageURL;
@synthesize strSpecialprice;
@synthesize strDescription;
@synthesize strDiscount;
@synthesize strProductDetailType;

@synthesize dicProductDetails;
@synthesize arrCategory;

- (id)init
{
    self = [super init];
    if (self)
    {

        strSKU = @"";
        strName = @"";
        strImage = @"";
        strPrice = @"";
        fltPrice = 0.0;
        strProductid = @"";
        strTypeid = @"";
        strSRP = @"";
        strshortdescription = @"";
        strThumbnailURL = @"";
        strSmallImageURL = @"";
        strSpecialprice = @"";
        strDescription = @"";
        strDiscount = @"";
        strProductDetailType = @"";
        
        dicProductDetails = [[NSMutableDictionary alloc]init];
        arrCategory = [[NSMutableArray alloc]init];
    }
    return self;
}

@end
