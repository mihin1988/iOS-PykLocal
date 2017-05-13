//
//  PaymentViewController.h
//  PykLocal
//
//  Created by Mihin  Patel on 25/12/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentViewController : UIViewController
{
    IBOutlet UIView *viewBottom;
    IBOutlet UILabel *lblTotalCount;
    IBOutlet UILabel *lblTotalAmount;
    IBOutlet UIButton *btnPay;
}
@property (nonatomic, retain) NSString *strTotalCount;
@property (nonatomic, retain) NSString *strTotalAmount;

@property (nonatomic, retain) NSString *strOrderNumber;
@property (nonatomic, retain) NSString *strOrderState;

@property (nonatomic, retain) NSString *strClientToken;
@end
