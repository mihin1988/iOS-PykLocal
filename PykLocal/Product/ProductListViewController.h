//
//  ProductListViewController.h
//  PykLocal
//
//  Created by Mihin  Patel on 11/09/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductListViewController : UIViewController
{
    IBOutlet UILabel *lblTotal;
    IBOutlet UILabel *lblNoProductFound;

    IBOutlet UIButton *btnSort;
    IBOutlet UIButton *btnFilter;
    IBOutlet UIButton *btnChangeView;
    
    IBOutlet UICollectionView *cvProductList;
    IBOutlet UIView *viewLoadMore;
}
@property(nonatomic, retain)NSString *strTitle;
@property(nonatomic, retain)NSString *strId;
@property(nonatomic, retain)NSString *strParentCategoryId;
@property(nonatomic, retain)NSString *strStoreId;
@property(nonatomic, retain)NSString *strSearch;

@end
