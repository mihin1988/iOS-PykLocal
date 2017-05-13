//
//  WriteReviewViewController.h
//  PykLocal
//
//  Created by Mihin  Patel on 21/11/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WriteReviewViewController : UIViewController
{
    IBOutlet UILabel *lblName;
    IBOutlet UITextField *tfTitle;
    IBOutlet UITextView *tvDiscription;
    IBOutlet UIButton *btnSubmit;
}
@property(nonatomic, retain)NSString *strName;
@property(nonatomic, retain)NSString *strId;

@end
