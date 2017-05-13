//
//  Attributes.m
//  QuickeSelling
//
//  Created by Saket Singhi on 26/12/15.
//  Copyright © 2015 JVSGroup. All rights reserved.
//

#import "Attributes.h"

@implementation Attributes


@synthesize strLabel;
@synthesize strCode;
@synthesize arrValues;


- (id)init
{
    self = [super init];
    if (self)
    {
        strLabel = @"";
        strCode = @"";
        arrValues = [[NSMutableArray alloc]init];
    }
    return self;
}

@end
