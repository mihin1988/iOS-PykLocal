//
//  ReviewOrderViewController.h
//  PykLocal
//
//  Created by Saket Singhi on 20/12/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewOrderViewController : UIViewController
{
    IBOutlet UIScrollView *svContainer;
    IBOutlet UITableView *tblCartList;
    IBOutlet UILabel *lblCartList;
    
    IBOutlet UIView *viewBillingAddress;
    IBOutlet UILabel *lblBillingName;
    IBOutlet UIButton *btnBillingPhone;
    IBOutlet UIButton *btnBillingAddress;
    IBOutlet UIButton *btnAddBillingAddress;


    IBOutlet UIView *viewShippingAddress;
    IBOutlet UILabel *lblShippingName;
    IBOutlet UIButton *btnShippingPhone;
    IBOutlet UIButton *btnShippingAddress;
    IBOutlet UIButton *btnAddShippingAddress;

    IBOutlet UIView *viewShoppingCart;
    
    IBOutlet UIButton *btnUse;
    
    IBOutlet UIView *viewPriceCouponCode;
    IBOutlet UIView *viewPrice;
    
    IBOutlet UILabel *lblSubTotalTitle;
    IBOutlet UILabel *lblSubTotal;

    IBOutlet UITextField *tfCouponCode;


    IBOutlet UIView *viewBottom;
    IBOutlet UILabel *lblTotalCount;
    IBOutlet UILabel *lblTotalAmount;
    IBOutlet UIButton *btnCheckOut;
}

@property (nonatomic, retain) NSMutableArray *arrCartList;
@property (nonatomic, retain) NSString *strOrderNumber;

@end
