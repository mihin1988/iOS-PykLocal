//
//  AllCategoriesViewController.h
//  QuickeSelling
//
//  Created by Saket Singhi on 27/11/15.
//  Copyright © 2015 JVSGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllCategoriesViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITableView *tblList;

@property (nonatomic, retain) NSArray *firstArray;
@property (nonatomic, retain) NSMutableArray *firstForTable;

- (void)miniMizeFirstsRows:(NSArray*)ar;
@end
