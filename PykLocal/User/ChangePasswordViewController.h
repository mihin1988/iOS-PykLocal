//
//  ChangePasswordViewController.h
//  PykLocal
//
//  Created by Saket Singhi on 03/12/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : UIViewController
{
    IBOutlet UITextField *tfOldPassword;
    IBOutlet UITextField *tfNewPassword;
    IBOutlet UITextField *tfReTypePassword;

    IBOutlet UIButton *btnSubmit;
}
@end
