//
//  WishlistViewController.h
//  PykLocal
//
//  Created by Saket Singhi on 05/11/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WishlistViewController : UIViewController
{
    IBOutlet UITableView *tblWishList;
    IBOutlet UILabel *lblMessage;
}
@property(nonatomic, readwrite)BOOL back;
@end
