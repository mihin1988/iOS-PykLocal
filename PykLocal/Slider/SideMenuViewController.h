//
//  SideMenuViewController.h
//  PykLocal
//
//  Created by Mihin  Patel on 21/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuViewController : UIViewController
{
    IBOutlet UITableView *tblSliderList;
}

@property(nonatomic,readwrite) int index;

- (void)setSliderList;
@end
