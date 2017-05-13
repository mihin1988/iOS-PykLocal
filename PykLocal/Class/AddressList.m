//
//  AddressList.m
//  PykLocal
//
//  Created by Mihin  Patel on 21/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//


#import "AddressList.h"

@implementation AddressList

@synthesize strPhone;
@synthesize strFirstName;
@synthesize strLastName;
@synthesize strAddress1;
@synthesize strAddress2;
@synthesize strCountryId;
@synthesize strCountryName;
@synthesize strStateId;
@synthesize strStateName;
@synthesize strCity;
@synthesize strZipcode;

- (id)init
{
    self = [super init];
    if (self)
    {
        strPhone = @"";
        strFirstName = @"";
        strLastName = @"";
        strAddress1 = @"";
        strAddress2 = @"";
        strCountryId = @"";
        strCountryName = @"";
        strStateId = @"";
        strStateName = @"";
        strCity = @"";
        strZipcode = @"";
    }
    return self;
}
@end
