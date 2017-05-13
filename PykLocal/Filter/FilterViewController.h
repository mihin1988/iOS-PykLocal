//
//  FilterViewController.h
//  PykLocal
//
//  Created by Mihin  Patel on 11/09/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

// Delgate
@protocol FilterViewDelegate <NSObject>
- (void)filteredData:(NSMutableArray *)arrFilteredattribute ISReset:(BOOL)isReset;
@end

@interface FilterViewController : UIViewController

// Property for delegate
@property (weak, nonatomic) id<FilterViewDelegate> delegate;

@property(nonatomic, retain)IBOutlet UITableView *tblAttributes;
@property(nonatomic, retain)IBOutlet UITableView *tblValues;

@property(nonatomic, retain)IBOutlet UIButton *btnCancel;
@property (retain, nonatomic) IBOutlet UIButton *btnApply;


@property(nonatomic, retain)NSString *strTotalCount;


@property(nonatomic, retain)NSMutableArray *arrAttributes;
@property(nonatomic, retain)NSMutableArray *arrFilteredAttribute;


-(IBAction)btnCancelPressed:(UIButton *)sender;
-(IBAction)btnApplyPressed:(UIButton *)sender;
-(IBAction)btnResetPressed:(UIButton *)sender;
@end
