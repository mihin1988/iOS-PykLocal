//
//  SignUpViewController.h
//  PykLocal
//
//  Created by Mihin  Patel on 06/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController
{
    IBOutlet UITextField *tfFirstName;
    IBOutlet UITextField *tfLastName;
    IBOutlet UITextField *tfEmail;
    IBOutlet UITextField *tfPassword;
    
    IBOutlet UIButton *btnSignUp;
    IBOutlet UIButton *btnFacebook;
    IBOutlet UIButton *btnGooglePlus;
}

@property (nonatomic, retain) IBOutlet UIScrollView *svContainer;
@end
