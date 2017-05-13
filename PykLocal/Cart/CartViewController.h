//
//  CartViewController.h
//  PykLocal
//
//  Created by Mihin  Patel on 11/09/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartViewController : UIViewController
{
    IBOutlet UITableView *tblCartList;
    IBOutlet UILabel *lblMessage;
    
    IBOutlet UIView *viewBottom;
    IBOutlet UILabel *lblTotalCount;
    IBOutlet UILabel *lblTotalAmount;
    IBOutlet UIButton *btnCheckOut;
}
@end
