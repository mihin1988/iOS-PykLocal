//
//  LoginSignUpViewController.h
//  PykLocal
//
//  Created by Mihin  Patel on 04/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginSignUpViewController : UIViewController
{
    IBOutlet UIView *viewContainer;
    IBOutlet UIPageControl *pageControl;
}

- (IBAction)btnContinueAsGuestPressed:(UIButton *)sender;
@end
