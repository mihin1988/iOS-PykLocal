//
//  BannerList.m
//  PykLocal
//
//  Created by Mihin  Patel on 21/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//


#import "BannerList.h"

@implementation BannerList


@synthesize strId;
@synthesize strName;
@synthesize strImage;

- (id)init
{
    self = [super init];
    if (self)
    {
        strId = @"";
        strName = @"";
        strImage = @"";
    }
    return self;
}
@end
