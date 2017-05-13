//
//  CartlistTableViewCell.h
//  PykLocal
//
//  Created by Saket Singhi on 05/11/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartlistTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *ivImage;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblPrice;
@property (retain, nonatomic) IBOutlet UIButton *btnMore;
@property (retain, nonatomic) IBOutlet UIView *viewOffer;
@property (retain, nonatomic) IBOutlet UIButton *btnProduct;

@property(nonatomic, retain)IBOutlet UILabel *lblQty;

@property(nonatomic, retain)IBOutlet UIButton *btnMinus;
@property(nonatomic, retain)IBOutlet UIButton *btnPlus;
@property(nonatomic, retain)IBOutlet UIButton *btnQty;

@property(nonatomic, retain)IBOutlet UITextField *tfQty;
@property(nonatomic, retain)IBOutlet UILabel *lblTotalPrice;

@property(nonatomic, retain)IBOutlet UILabel *lblOptionName;
@property(nonatomic, retain)IBOutlet UIButton *btnDeliveryType;
@end
