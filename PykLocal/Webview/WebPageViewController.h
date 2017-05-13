//
//  WebPageViewController.h
//  PykLocal
//
//  Created by Mihin  Patel on 12/11/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebPageViewController : UIViewController
{
    IBOutlet UIWebView *wvPage;
}
@property(nonatomic, retain)NSString *strTitle;
@property(nonatomic, retain)NSString *strText;
@property(nonatomic, retain)NSString *strURL;

@end
