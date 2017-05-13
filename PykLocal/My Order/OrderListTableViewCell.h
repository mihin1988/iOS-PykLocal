//
//  OrderListTableViewCell.h
//  PykLocal
//
//  Created by Mihin  Patel on 05/01/17.
//  Copyright © 2017 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderListTableViewCell : UITableViewCell
{

}

@property (retain, nonatomic) IBOutlet UILabel *lblDate;
@property (retain, nonatomic) IBOutlet UILabel *lblNumber;
@property (retain, nonatomic) IBOutlet UILabel *lblTotal;
@end
