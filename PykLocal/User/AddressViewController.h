//
//  AddressViewController.h
//  PykLocal
//
//  Created by Saket Singhi on 19/12/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressList.h"

@protocol AddressViewDelegate <NSObject>
@optional
- (void)selectedAddress:(AddressList *)selectedAddress;
- (void)moveAddressToDelivery;

@end

@interface AddressViewController : UIViewController
{
    IBOutlet UIScrollView *svContainer;
    
    IBOutlet UITextField *tfFirstName;
    IBOutlet UITextField *tfLastName;
    IBOutlet UITextField *tfPhone;
    IBOutlet UITextField *tfAddress1;
    IBOutlet UITextField *tfAddress2;
    IBOutlet UITextField *tfCountry;
    IBOutlet UITextField *tfState;
    IBOutlet UITextField *tfCity;
    IBOutlet UITextField *tfZipcode;
    
    IBOutlet UIPickerView *pvSelect;
    
    IBOutlet UIButton *btnSubmit;
}

@property (nonatomic, assign) id <AddressViewDelegate> delegate;

@property (nonatomic, retain) AddressList *addressList;
@property (nonatomic, retain) NSString *strTitle;

@end
