//
//  ProductDetailViewController.h
//  PykLocal
//
//  Created by Mihin  Patel on 06/11/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductList.h"
@interface ProductDetailViewController : UIViewController
{
    IBOutlet UIScrollView *svContainer;
    
    IBOutlet UIView *viewName;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UILabel *lblProductName;
    IBOutlet UIButton *btnShare;

    IBOutlet UIView *viewStore;
    IBOutlet UILabel *lblStoreName;
    IBOutlet UIButton *btnStoreProduct;
    
    IBOutlet UIView *viewRating;
    IBOutlet UIButton *btnRating;
    IBOutlet UILabel *lblRating;
    IBOutlet UILabel *lblReview;
    
    IBOutlet UIView *viewPriceDetail;
    IBOutlet UIView *viewPrice;
    IBOutlet UILabel *lblPrice;
    IBOutlet UILabel *lblSpecialPrice;
    IBOutlet UILabel *lblStockStatus;
    IBOutlet UILabel *lblMinimumOrder;
    IBOutlet UIButton *btnOffer;
    
    IBOutlet UIView *viewUpdateQuantity;
    IBOutlet UIButton *btnMinus;
    IBOutlet UIButton *btnPlus;
    IBOutlet UIButton *btnQty;
    IBOutlet UITextField *tfQty;
    IBOutlet UILabel *lblLeftItem;

    
    IBOutlet UIView *viewVariant;
    IBOutlet UITableView *tblVariant;
    
    IBOutlet UIView *viewDescription;
    IBOutlet UILabel *lblDescription;

    IBOutlet UIView *viewBottom;
    IBOutlet UIButton *btnWish;
    IBOutlet UIView *viewbtnAddToCart;
    IBOutlet UIButton *btnbtnAddToCart;
    


}

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, strong) NSMutableDictionary *dicaDetails;
@property (nonatomic, strong) ProductList *productList;

@property (nonatomic, strong) NSString *strMessage;
@property (nonatomic, strong) NSString *strId;


@end
