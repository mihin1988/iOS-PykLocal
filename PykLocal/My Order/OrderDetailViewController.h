//
//  OrderDetailViewController.h
//  PykLocal
//
//  Created by Mihin  Patel on 06/01/17.
//  Copyright © 2017 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
// Delgate
@protocol OrderDetailViewDelegate <NSObject>
- (void)cancelOrder:(NSMutableDictionary *)dicOrderDetail;
@end

@interface OrderDetailViewController : UIViewController
{
    IBOutlet UILabel *lblDate;
    IBOutlet UILabel *lblNumber;
    IBOutlet UILabel *lblTotal;
    
    IBOutlet UIScrollView *svContainer;
    
    IBOutlet UIButton *btnReturn;
    IBOutlet UIButton *btnCancel;
    
    IBOutlet UIView *viewShipments;
    IBOutlet UILabel *lblShipments;
    IBOutlet UILabel *lblPaymentInformation;

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
    
    IBOutlet UITableView *tblCartList;
    IBOutlet UILabel *lblCartList;

    IBOutlet UIView *viewPrice;
    IBOutlet UILabel *lblSubTotalTitle;
    IBOutlet UILabel *lblSubTotal;
}

// Property for delegate
@property (weak, nonatomic) id<OrderDetailViewDelegate> delegate;


@property (retain, nonatomic) NSMutableDictionary *dicOrderDetails;

@end
