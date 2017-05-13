//
//  UserProfileViewController.h
//  PykLocal
//
//  Created by Saket Singhi on 08/12/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileViewController : UIViewController
{
    IBOutlet UIScrollView *svContainer;
    
    IBOutlet UITextField *tfEmail;
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
    IBOutlet UIButton *btnAddressSubmit;

}
@end
