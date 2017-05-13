//
//  ThankYouViewController.h
//  PykLocal
//
//  Created by Mihin  Patel on 25/12/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThankYouViewController : UIViewController
{
    IBOutlet UILabel *lblOrdernumber;
    
    IBOutlet UIButton *btnViewYourOrder;
    IBOutlet UIButton *btnContinueShopping;
}
@property (nonatomic, retain) NSString *strOrderNumber;
@end
