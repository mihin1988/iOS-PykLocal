//
//  RatingViewController.h
//  PykLocal
//
//  Created by Mihin  Patel on 15/11/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatingViewController : UIViewController
{
    IBOutlet UITableView *tblRating;
}
@property(nonatomic, retain)NSString *strId;
@end
