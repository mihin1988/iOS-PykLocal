//
//  RatingViewCell.h
//  PykLocal
//
//  Created by Mihin  Patel on 06/11/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatingViewCell : UITableViewCell

@property(nonatomic, retain)IBOutlet UILabel *lblDate;
@property(nonatomic, retain)IBOutlet UIButton *btnRate;
@property(nonatomic, retain)IBOutlet UILabel *lblComment;
@property(nonatomic, retain)IBOutlet UILabel *lblName;
@property(nonatomic, retain)IBOutlet UIButton *btnMoreLess;
@property(nonatomic, retain)IBOutlet UILabel *lblStrip;
@end
