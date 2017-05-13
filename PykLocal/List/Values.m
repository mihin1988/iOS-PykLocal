//
//  Values.m
//  QuickeSelling
//
//  Created by Saket Singhi on 26/12/15.
//  Copyright © 2015 JVSGroup. All rights reserved.
//

#import "Values.h"

@implementation Values


@synthesize strOptionId;
@synthesize strOptionName;
@synthesize strProductCount;
@synthesize strSelected;

- (id)init
{
    self = [super init];
    if (self)
    {
        strOptionId = @"";
        strOptionName = @"";
        strProductCount = @"";
        strSelected = @"";
    }
    return self;
}

@end
