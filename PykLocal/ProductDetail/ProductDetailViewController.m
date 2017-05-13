//
//  ProductDetailViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 06/11/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "ProductListViewController.h"
#import "PowerfulBannerView.h"
#import "MWPhotoBrowser.h"
#import "WebPageViewController.h"
#import "RatingViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "WriteReviewViewController.h"
#import "DXPopover.h"

@interface ProductDetailViewController ()<MWPhotoBrowserDelegate>
{
    AppDelegate *appDelegate;
    Common *common;
    BarcodeScannerViewController *barcodeScannerViewController;
    PowerfulBannerView *bannerView;

    NSUserDefaults *prefs;
    CGRect frmaeViewPriceDetail;
    UIButton *btnSelected;
    NSMutableDictionary *dicRelatedItemResponse;
    
    NSString *strMasterVariantId;
    BOOL isScanned;

    int y;
    int selectedVariant;
    
    float fltWidth;
    float fltHeight;
}
@end

@implementation ProductDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    dicRelatedItemResponse = [[NSMutableDictionary alloc]init];
    
    [viewbtnAddToCart setBackgroundColor:RGB];
    [btnbtnAddToCart setBackgroundColor:RGB];
    
    btnShare.layer.cornerRadius = 17.5;
    [btnShare setBackgroundColor:RGB];

    selectedVariant = 0;
    
    fltWidth = [[UIScreen mainScreen] bounds].size.width;
    fltHeight = [[UIScreen mainScreen] bounds].size.height;
    
    NSLog(@"%f",fltWidth);
    NSLog(@"%f",fltHeight);
    
    [self.view setFrame:CGRectMake(0, 0, fltWidth, fltHeight)];
    
    if(_dicaDetails)
    {
        [self parseData:_dicaDetails];
    }
    else if(_strId)
    {
        [self getProductDetail];
    }
    else
    {
        strMasterVariantId = _productList.strMasterVariantId;
        if([_productList.arrVariants count])
        {
            [self setData:[_productList.arrVariants objectAtIndex:0]];
        }
        else
        {
            [self displayData];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
    //Mange Slider
    appDelegate.isHandlePan = FALSE;
    
    //Mange NavigationBar With Cart Count
    [self setNavigationBar:appDelegate.strCartCount];
    
    if(isScanned && [[prefs objectForKey:@"scanCode"] length])
    {
        sqlite3_stmt *statement;
        
        NSString *insertSQL = [NSString stringWithFormat:@"insert or replace into search values(\"%@\")",[prefs objectForKey:@"scanCode"]];
        
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(appDelegate.dbPykLocal, insert_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            sqlite3_bind_text(statement, 1, [insertSQL UTF8String], -1, SQLITE_TRANSIENT);
            NSLog(@"Search Inserted Successfully.");
            
        }
        else
        {
            NSLog(@"Error while Insert Search :- '%s'", sqlite3_errmsg(appDelegate.dbPykLocal));
        }
        sqlite3_finalize(statement);
        
        ProductListViewController *productListViewController = [[ProductListViewController alloc]initWithNibName:@"ProductListViewController" bundle:nil];
        productListViewController.strTitle = @"Search Product";
        productListViewController.strId = @"";
        productListViewController.strSearch = [prefs objectForKey:@"scanCode"];
        [self.navigationController pushViewController:productListViewController animated:YES];
        
        [prefs setObject:@"" forKey:@"scanCode"];
        [prefs synchronize];
        isScanned = FALSE;
    }
    
    if([_strMessage length])
    {
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:nil//NSLocalizedString(@"Whoa!", nil)
                                           subtitle:_strMessage
                                              image:nil
                                               type:TSMessageNotificationTypeError
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionBottom
                               canBeDismissedByUser:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method -

- (void)setNavigationBar:(NSString *)strCartValue
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    
    [self.navigationController setNavigationBarHidden:FALSE];
    
    UIButton *logoView = [[UIButton alloc] initWithFrame:CGRectMake(0,0,60,60)];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,60,60)];
    image.contentMode = UIViewContentModeScaleAspectFit;
    [image setImage: [UIImage imageNamed:@"Img-Logo.png"]];
    [logoView addSubview:image];
    [logoView setUserInteractionEnabled:NO];
//    self.navigationItem.titleView = logoView;
    self.navigationItem.title = @"Product Detail";
    
    UIImage *imgWish = [UIImage imageNamed:@"Img-TopWish.png"];
    UIButton *buttonWish = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonWish.frame = CGRectMake(0,0,imgWish.size.width, imgWish.size.height);
    [buttonWish addTarget:self action:@selector(btnWishListPressed:) forControlEvents:UIControlEventTouchDown];
    [buttonWish setBackgroundImage:imgWish forState:UIControlStateNormal];
    
    // Make BarButton Item
    UIBarButtonItem *btnWish = [[UIBarButtonItem alloc] initWithCustomView:buttonWish];
    //btnWish.badgeValue = strCartValue;

    
    UIImage *img = [UIImage imageNamed:@"Img-Cart.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,img.size.width, img.size.height);
    [button addTarget:self action:@selector(btnCartPressed:) forControlEvents:UIControlEventTouchDown];
    [button setBackgroundImage:img forState:UIControlStateNormal];
    
    // Make BarButton Item
    UIBarButtonItem *btnCart = [[UIBarButtonItem alloc] initWithCustomView:button];
    btnCart.badgeValue = strCartValue;
    
    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(btnSearchPressed:)];
    btnSearch.imageInsets = UIEdgeInsetsMake(0, 8, 0, -10);
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnCart,btnWish, nil]];
    
}

- (void)getProductDetail
{
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        [SVProgressHUD show];
        
        NSString *strURL = [NSString stringWithFormat:@"%@%@/%@",WS_BaseUrl,WS_Products,_strId];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
       
        [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:ProductDetail HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
    
}

- (void)parseData:(NSMutableDictionary *)dicData
{
    _productList = [[ProductList alloc]init];
    
    _productList.strId = [dicData objectForKey:@"id"];
    _productList.strDescription = [dicData objectForKey:@"description"];
    _productList.strDiscount = [dicData objectForKey:@"discount"];
    _productList.strReview = [dicData objectForKey:@"review"];
    _productList.strTotalOnHand = [dicData objectForKey:@"total_on_hand"];
    _productList.strMinimumQuantity = [dicData objectForKey:@"minimum_quantity"];
    _productList.strAverageRatings = [dicData objectForKey:@"average_ratings"];
    _productList.strTotalRating = [dicData objectForKey:@"total_rating"];
    _productList.strPrice = [dicData objectForKey:@"price"];
    _productList.strStockStatus = [dicData objectForKey:@"stock_status"];
    _productList.strInWishlist = [dicData objectForKey:@"in_wishlist"];
    _productList.strName = [dicData objectForKey:@"name"];
    _productList.strSpecialPrice = [dicData objectForKey:@"special_price"];
    _productList.arrProductImages = [dicData objectForKey:@"product_images"];
    _productList.arrVariants = [dicData objectForKey:@"variants"];
    _productList.strMasterVariantId = [dicData objectForKey:@"master_variant_id"];
    strMasterVariantId = [dicData objectForKey:@"master_variant_id"];
    _productList.strStoreId = [dicData objectForKey:@"store_id"];
    _productList.strStoreName = [dicData objectForKey:@"store_name"];
    _productList.strProductShareLink = [dicData objectForKey:@"product_share_link"];

    if([_productList.arrVariants count])
    {
        [self setData:[_productList.arrVariants objectAtIndex:0]];
    }
    else
        [self displayData];
}

- (void)setData:(NSMutableDictionary *)dicData
{
    _productList.strDiscount = [dicData objectForKey:@"discount"];
    _productList.strTotalOnHand = [dicData objectForKey:@"total_on_hand"];
    _productList.strMinimumQuantity = [dicData objectForKey:@"minimum_quantity"];
    _productList.strPrice = [dicData objectForKey:@"price"];
    _productList.strStockStatus = [dicData objectForKey:@"stock_status"];
    _productList.strSpecialPrice = [dicData objectForKey:@"special_price"];
    _productList.arrProductImages = [dicData objectForKey:@"product_images"];
    _productList.strMasterVariantId = [dicData objectForKey:@"id"];
    
    [self displayData];

}

- (void)displayData
{
    [svContainer setFrame:CGRectMake(0, 109, fltWidth,fltHeight-158)];
    
    [self addGallery:_productList.arrProductImages];

    [viewName setFrame:CGRectMake(0, y, fltWidth, 64)];
    [lblProductName setText:_productList.strName];
    [svContainer addSubview:viewName];
    y += viewName.frame.size.height + 1;
    
    
    if([_productList.strStoreName length])
    {
        [viewStore setFrame:CGRectMake(0, y, fltWidth, 50)];
        [lblStoreName setText:[NSString stringWithFormat:@"Product Sold by : %@",_productList.strStoreName]];
        [svContainer addSubview:viewStore];
        y += viewStore.frame.size.height;
    }
    
    if([_productList.strAverageRatings floatValue])
    {
        [viewRating setFrame:CGRectMake(0, y, fltWidth, 50)];
        btnRating.layer.cornerRadius = 5.0;
        [btnRating setBackgroundColor:RGB];
        [btnRating setTitle:[NSString stringWithFormat:@"%.1f",[_productList.strAverageRatings doubleValue]] forState:UIControlStateNormal];
        [lblRating setText:[NSString stringWithFormat:@"from %@ Ratings",_productList.strTotalRating]];
        [lblReview setText:[NSString stringWithFormat:@"%@ Reviews",_productList.strReview]];
        [svContainer addSubview:viewRating];
        y += viewRating.frame.size.height + 1;
    }

    [viewPriceDetail setFrame:CGRectMake(0, y, fltWidth, 50)];
    [self setPriceDetail];
    [svContainer addSubview:viewPriceDetail];
    y += viewPriceDetail.frame.size.height + 1;

    if([_productList.strTotalOnHand length])
    {
        [viewUpdateQuantity setFrame:CGRectMake(0, y, fltWidth, 86)];
        [lblLeftItem setText:[NSString stringWithFormat:@"%@ Item left",_productList.strTotalOnHand]];
        [svContainer addSubview:viewUpdateQuantity];
        [self setBorder:btnMinus];
        [self setBorder:btnQty];
        [self setBorder:btnPlus];
        y += viewUpdateQuantity.frame.size.height + 1;
    }
    
    if([_productList.arrVariants count])
    {
        [viewVariant setFrame:CGRectMake(0, y, fltWidth, ([_productList.arrVariants count] * 36) + 37)];
        [tblVariant setFrame:CGRectMake(0, 37, fltWidth, ([_productList.arrVariants count] * 36))];
        [svContainer addSubview:viewVariant];
        y += viewVariant.frame.size.height + 1;
    }
    
    [viewDescription setFrame:CGRectMake(0, y, fltWidth, 37)];
    [lblDescription setText:_productList.strDescription];
    [svContainer addSubview:viewDescription];
    y += viewDescription.frame.size.height;

    if([_productList.strInWishlist intValue] == 1)
    {
        [btnWish setImage:[UIImage imageNamed:@"Img-Selected-Wish-List.png"] forState:UIControlStateNormal];
    }
    else
    {
        [btnWish setImage:[UIImage imageNamed:@"Img-Wish-List.png"] forState:UIControlStateNormal];
    }
    
    [svContainer setContentSize:CGSizeMake(fltWidth, y)];
    
    [self getRelatedProduct];
}

- (void)addGallery:(NSMutableArray *)arrImageDetail
{
    y = 0;
    if(![arrImageDetail count])
        [arrImageDetail addObject:@""];
    
    [bannerView removeFromSuperview];
    bannerView = [[PowerfulBannerView alloc] initWithFrame:CGRectMake(0.f, y, fltWidth, 350)];
    [bannerView setBackgroundColor:[UIColor clearColor]];
    [pageControl setCurrentPageIndicatorTintColor:RGB];
    bannerView.pageControl = pageControl;
    [pageControl setCurrentPageIndicatorTintColor:RGB];
    
    bannerView.items = arrImageDetail;
    
    bannerView.bannerItemConfigurationBlock = ^UIView *(PowerfulBannerView *banner, id item, UIView *reusableView) {
        
        UIImageView *view = (UIImageView *)reusableView;
        if (!view) {
            view = [[UIImageView alloc] initWithFrame:CGRectZero];
            view.contentMode = UIViewContentModeScaleAspectFit;
            //                AspectFit  AspectFill
            view.clipsToBounds = YES;
        }
    
        [view sd_setImageWithURL:[NSURL URLWithString:item] placeholderImage:[UIImage imageNamed:@"Img-Logo.png"] options:SDWebImageProgressiveDownload progress:nil completed:nil];
        
        return view;
    };
    __weak typeof(self) weakSelf = self;
    bannerView.bannerDidSelectBlock = ^(PowerfulBannerView *banner, NSInteger index) {
        //            printf("banner did select index at: %zd \n", index);
        [weakSelf ShowPhotoBrowser:arrImageDetail];
        
        //            btnGalleryPressed;
    };
    
    bannerView.bannerIndexChangeBlock = ^(PowerfulBannerView *banner, NSInteger fromIndex, NSInteger toIndex) {
        //            printf("banner changed index from %zd to %zd\n", fromIndex, toIndex);
    };
    
    bannerView.longTapGestureHandler = ^(PowerfulBannerView *banner, NSInteger index, id item, UIView *view) {
        //            printf("banner long gesture recognized on index: %zd !\n", index);
    };
    
    if ([bannerView.items count] <=1)
        [pageControl setHidden:TRUE];
    
    bannerView.loopingInterval = 100.f;
    bannerView.autoLooping = YES;
    
    [svContainer addSubview:bannerView];
    
    y += 350;
    
}

- (void)setPriceDetail
{
    if([_productList.strDiscount floatValue])
    {
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[appDelegate numberFormatter:_productList.strPrice CurrencySymbol:appDelegate.strCurrencySymbol]]];
        
        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                value:@1                            range:NSMakeRange(0, [attributeString length])];
        [lblPrice setAttributedText:attributeString];
        [lblPrice setBackgroundColor:[UIColor clearColor]];
        [lblPrice sizeToFit];
        
        [lblSpecialPrice setText:[NSString stringWithFormat:@"%@",[appDelegate numberFormatter:_productList.strSpecialPrice CurrencySymbol:appDelegate.strCurrencySymbol]]];
        [lblSpecialPrice sizeToFit];
        
        CGRect frame = btnOffer.frame;
        frame.origin.x = lblSpecialPrice.frame.size.width + 20;
        btnOffer.frame = frame;
        
        btnOffer.titleLabel.textAlignment = NSTextAlignmentCenter;
        btnOffer.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        if([_productList.strDiscount floatValue]<0)
            _productList.strDiscount = [NSString stringWithFormat:@"%.2f",[_productList.strDiscount doubleValue]*-1];
        
        if([_productList.strDiscount floatValue] - [_productList.strDiscount intValue] == 0)
            [btnOffer setTitle:[NSString stringWithFormat:@"%d%%\nOFF",[_productList.strDiscount intValue]] forState:UIControlStateNormal];
        else
            [btnOffer setTitle:[NSString stringWithFormat:@"%.2f%%\nOFF",[_productList.strDiscount doubleValue]] forState:UIControlStateNormal];
        
        btnOffer.titleLabel.numberOfLines = 2;
        [btnOffer.layer setBorderColor:[[[UIColor redColor] colorWithAlphaComponent:1.0] CGColor]];
        [btnOffer.layer setBorderWidth:.5];
        btnOffer.layer.cornerRadius = btnOffer.frame.size.width/2;
        btnOffer.clipsToBounds = YES;
        
        [lblPrice setHidden:FALSE];
        [btnOffer setHidden:FALSE];
        frame = viewPrice.frame;
        frame.origin.y = 25;
        [viewPrice setFrame:frame];
    }
    else
    {
        [lblSpecialPrice setText:[NSString stringWithFormat:@"%@",[appDelegate numberFormatter:_productList.strPrice CurrencySymbol:appDelegate.strCurrencySymbol]]];
        [lblSpecialPrice sizeToFit];
        
        [lblPrice setHidden:TRUE];
        [btnOffer setHidden:TRUE];
        CGRect frame = viewPrice.frame;
        frame.origin.y = viewPriceDetail.frame.size.height/2 -frame.size.height/2;
        [viewPrice setFrame:frame];
    }
    
    if([_productList.strStockStatus intValue])
    {
        [lblStockStatus setText:@"In Stock"];
        [lblStockStatus setTextColor:[UIColor colorWithRed:97.0/255.0 green:173.0/255.0 blue:5.0/255.0 alpha:1.0]];
    }
    else
    {
        [lblStockStatus setText:@"Out of Stock"];
        [lblStockStatus setTextColor:[UIColor redColor]];
    }
    
    [lblMinimumOrder setText:[NSString stringWithFormat:@"Minimum Order %@",_productList.strMinimumQuantity]];
    [tfQty setText:_productList.strMinimumQuantity];

    frmaeViewPriceDetail = viewPriceDetail.frame;
}

- (void)setBorder:(UIButton *)btn
{
    [btn.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
    [btn.layer setBorderWidth:1.0];
    btn.layer.cornerRadius = 4;
    btn.clipsToBounds = YES;
}

- (void)getRelatedProduct
{
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        NSString *strURL = [NSString stringWithFormat:@"%@products/%@/%@",WS_BaseUrl,_productList.strId,WS_RelatedProduct];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
    
        [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:RelatedProduct HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
    
}

- (void)addProductView:(int)yValue Height:(int)height Data:(NSMutableDictionary *)dicData
{
    
    NSMutableArray *arrItemList = [dicData objectForKey:@"details"];
    
    if([arrItemList count])
    {
        UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, yValue-7, appDelegate.window.bounds.size.width-80, 20)];
        [lblTitle setFont:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium]];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [lblTitle setTextColor:[UIColor darkGrayColor]];
        [lblTitle setText:@"Related Items"];
        [svContainer addSubview:lblTitle];
        
        
//        UIButton *btnViewAll = [[UIButton alloc]initWithFrame:CGRectMake(appDelegate.window.bounds.size.width-70, yValue, 60, 20)];
//        [btnViewAll.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
//        [btnViewAll setTitle:@"View All" forState:UIControlStateNormal];
//        [btnViewAll setTag:[[dicData objectForKey:@"index"]intValue]];
//        
//        if(![[dicData objectForKey:@"parent_category_id"] intValue])
//            [btnViewAll setHidden:TRUE];
//        
//        [btnViewAll setBackgroundColor:[UIColor clearColor]];
//        [btnViewAll setTitleColor:RGB forState:UIControlStateNormal];
//        btnViewAll.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//        [btnViewAll addTarget:self action:@selector(btnViewAllPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        yValue +=23;
        
        
        UILabel *lblStrip = [[UILabel alloc]initWithFrame:CGRectMake(0, yValue, appDelegate.window.bounds.size.width, 1)];
        [lblStrip setBackgroundColor:[UIColor colorWithRed:212.0/255.0 green:212.0/255.0 blue:212.0/255.0 alpha:1.0]];
        [svContainer addSubview:lblStrip];
        
        UIScrollView *svProductContainer = [[UIScrollView alloc]initWithFrame:CGRectMake(0, yValue, appDelegate.window.bounds.size.width, 205)];
        
        int space = 0;
        int x = space;
        
        int width = space * (int)([arrItemList count]+1);
        width += 150 * [arrItemList count];
        
        [svProductContainer setContentSize:CGSizeMake(width, 205)];
        for(int j = 0 ; j < [arrItemList count] ; j++)
        {
            NSDictionary *dicProduct = [arrItemList objectAtIndex:j];
            
            
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(x, 0, 150, 205)];
            [view setBackgroundColor:[UIColor clearColor]];
            //            [view.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
            //            [view.layer setBorderWidth:0.5];
            //            view.layer.cornerRadius = 5.0;
            //            view.clipsToBounds = YES;
            
            UIButton *btnWishList = [[UIButton alloc]initWithFrame:CGRectMake(150-40, 0, 40, 40)];
            [btnWishList.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:0]];
            [btnWishList setTitle:[dicProduct objectForKey:@"in_wishlist"] forState:UIControlStateNormal];
            [btnWishList setTag:[[dicData objectForKey:@"id"] intValue]];
            [btnWishList setBackgroundColor:[UIColor clearColor]];
            [btnWishList setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [btnWishList addTarget:self action:@selector(btnWishPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            UIView *viewBorder = [[UIView alloc]initWithFrame:CGRectMake(5, 4, 30, 30)];
            [viewBorder.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
            [viewBorder.layer setBorderWidth:1];
            viewBorder.layer.cornerRadius = 15.0;
            viewBorder.clipsToBounds = YES;
            [viewBorder setUserInteractionEnabled:FALSE];
            //            [btnWishList addSubview:viewBorder];
            
//            if([[dicProduct objectForKey:@"in_wishlist"] intValue] == 1)
//            {
//                [btnWishList setImage:[UIImage imageNamed:@"Img-Selected-Wish-List1.png"] forState:UIControlStateNormal];
//                
//                wishList = [[WishList alloc]init];
//                
//                wishList.strId = [dicProduct objectForKey:@"id"];
//                wishList.strName = [dicProduct objectForKey:@"name"];
//                wishList.strImage = ([[dicProduct objectForKey:@"product_images"]count])?[[dicProduct objectForKey:@"product_images"] objectAtIndex:0]:@"";
//                
//                //                [toOrderList insertRecordForProduct:toOrderList];
//            }
//            else
//                [btnWishList setImage:[UIImage imageNamed:@"Img-Wish-List1.png"] forState:UIControlStateNormal];
            
            
            
            UIImageView *ivProduct = [[UIImageView alloc]initWithFrame:CGRectMake(5, 15, 140, 130)];
            
            //          [ivProduct setBackgroundColor:[UIColor blackColor]];
            ivProduct.contentMode = UIViewContentModeScaleAspectFit;
            [ivProduct sd_setImageWithURL:[NSURL URLWithString:([[dicProduct objectForKey:@"product_images"]count])?[[dicProduct objectForKey:@"product_images"] objectAtIndex:0]:@""] placeholderImage:[UIImage imageNamed:@"Img-Logo.png"] options:SDWebImageProgressiveDownload progress:nil completed:nil];
            [view addSubview:ivProduct];
            
            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(5, 150, 140, 15)];
            [lblName setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
            [lblName setTextAlignment:NSTextAlignmentCenter];
            [lblName setNumberOfLines:1];
            [lblName setBackgroundColor:[UIColor clearColor]];
            [lblName setTextColor:[UIColor grayColor]];
            [lblName setText:[dicProduct objectForKey:@"name"]];
            [view addSubview:lblName];
            
            
            UILabel *lblRelatedPrice = [[UILabel alloc]initWithFrame:CGRectMake(5, 170, 140, 15)];
            [lblRelatedPrice setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12]];
            [lblRelatedPrice setTextAlignment:NSTextAlignmentCenter];
            [lblRelatedPrice setBackgroundColor:[UIColor clearColor]];
            [lblRelatedPrice setTextColor:[UIColor grayColor]];
            [lblRelatedPrice setText:[appDelegate numberFormatter:[dicProduct objectForKey:@"price"] CurrencySymbol:appDelegate.strCurrencySymbol]];
            
            [view addSubview:lblRelatedPrice];
            
            
            NSString *strTitle = [NSString stringWithFormat:@"%d",j];
            //            [dicProduct objectForKey:@"id"]
            
            UIButton *btnProduct = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 150, 205)];
            [btnProduct setTitle:strTitle forState:UIControlStateNormal];
            [btnProduct setTag:j];
            [btnProduct setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [btnProduct addTarget:self action:@selector(btnProductPressed:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btnProduct];
            //            [view addSubview:btnWishList];
            
            if([[dicProduct objectForKey:@"discount"] floatValue])
            {
                
                [lblRelatedPrice setText:[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",[[dicProduct objectForKey:@"special_price"]doubleValue]] CurrencySymbol:appDelegate.strCurrencySymbol]];
                
                UILabel *lblRelatedPrice = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 140, 15)];
                [lblRelatedPrice setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10]];
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[appDelegate numberFormatter:[dicProduct objectForKey:@"price"] CurrencySymbol:appDelegate.strCurrencySymbol]];
                
                [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                        value:@1
                                        range:NSMakeRange(0, [attributeString length])];
                
                lblRelatedPrice.attributedText = attributeString;
                [lblRelatedPrice sizeToFit];
                [lblRelatedPrice setBackgroundColor:[UIColor clearColor]];
                [lblRelatedPrice setTextColor:[UIColor grayColor]];
                
                
                UILabel *lblDiscount = [[UILabel alloc]initWithFrame:CGRectMake(lblRelatedPrice.frame.size.width+lblRelatedPrice.frame.origin.x+5, 0, 140, 15)];
                [lblDiscount setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:10]];
                [lblDiscount setBackgroundColor:[UIColor clearColor]];
                [lblDiscount setTextColor:RGB];
                
                if([[dicProduct objectForKey:@"discount"]floatValue] - [[dicProduct objectForKey:@"discount"]intValue] == 0)
                    [lblDiscount setText:[NSString stringWithFormat:@"%d%% OFF",[[dicProduct objectForKey:@"discount"]intValue]]];
                else
                    [lblDiscount setText:[NSString stringWithFormat:@"%.2f%% OFF",[[dicProduct objectForKey:@"discount"]doubleValue]]];
                [lblDiscount sizeToFit];
                
                
                CGRect frame = lblRelatedPrice.frame;
                frame.origin.y = 185;
                frame.size.width += lblDiscount.frame.size.width;
                frame.origin.x = (view.frame.size.width/2) - (frame.size.width/2);
                
                UIView *viewOffer = [[UIView alloc]initWithFrame:frame];
                
                [viewOffer addSubview:lblRelatedPrice];
                [viewOffer addSubview:lblDiscount];
                
                [view addSubview:viewOffer];
                
            }
            
//            [svContainer addSubview:btnViewAll];
            
            [svProductContainer addSubview:view];
            
            x += 150+space;
        }
        [svProductContainer setShowsHorizontalScrollIndicator:FALSE];
        [svContainer addSubview:svProductContainer];
        [svContainer setContentSize:CGSizeMake(fltWidth, y+225)];
    }
}

#pragma mark - UIScrollView Delegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if(svContainer.contentOffset.y >= 416)
    {
        [viewPriceDetail setFrame:CGRectMake(0, 108, fltWidth, 50)];
        [self.view addSubview:viewPriceDetail];
    }
    else
    {
        [viewPriceDetail setFrame:frmaeViewPriceDetail];
        [svContainer addSubview:viewPriceDetail];
    }
}

#pragma mark - UITable View Delegate Methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_productList.arrVariants count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UITableViewCell *cell;
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [cell setBackgroundColor:[UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0]];
    
    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(15, 0 , tblVariant.frame.size.width-55, 36)];
    [lblName setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [lblName setText:[[_productList.arrVariants objectAtIndex:indexPath.row] objectForKey:@"option_name"]];
    [cell.contentView addSubview:lblName];
    
    btnSelected = [[UIButton alloc]initWithFrame:CGRectMake(tblVariant.frame.size.width-40, 3, 30, 30)];
    if(selectedVariant == indexPath.row)
        [btnSelected setImage:[UIImage imageNamed:@"Img-Checked-Button.png"] forState:UIControlStateNormal];
    else
        [btnSelected setImage:[UIImage imageNamed:@"Img-Unchecked-Radio-Button.png"] forState:UIControlStateNormal];
    
    [btnSelected setUserInteractionEnabled:FALSE];
    [cell.contentView addSubview:btnSelected];

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedVariant = (int)indexPath.row;
    NSMutableDictionary *dicVariants = [[_productList.arrVariants objectAtIndex:selectedVariant]mutableCopy];
    [self setData:dicVariants];
    
    [tblVariant reloadData];
    
}

#pragma mark - IBAction Method -

-(IBAction)btnSearchPressed:(UIButton *)sender
{
    SearchViewController *searchViewController = [[SearchViewController alloc]initWithNibName:@"SearchViewController" bundle:nil];
    [self.navigationController pushViewController:searchViewController animated:NO];
}

-(IBAction)btnCartPressed:(UIButton *)sender
{
    CartViewController *cartViewController = [[CartViewController alloc]initWithNibName:@"CartViewController" bundle:nil];
    [self.navigationController pushViewController:cartViewController animated:YES];
}

-(IBAction)btnWishListPressed:(UIButton *)sender
{
    WishlistViewController *wishlistViewController = [[WishlistViewController alloc]initWithNibName:@"WishlistViewController" bundle:nil];
    wishlistViewController.back = TRUE;
    [self.navigationController pushViewController:wishlistViewController animated:YES];
}


-(IBAction)btnBarocdeScanPressed:(UIButton *)sender
{
    isScanned = TRUE;
    barcodeScannerViewController = [[BarcodeScannerViewController alloc]initWithNibName:@"BarcodeScannerViewController" bundle:nil];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:barcodeScannerViewController];
    [self presentViewController:navigationController animated:YES completion:^{}];
}

-(IBAction)btnSharePressed:(UIButton *)sender
{
    NSString *strShare = [NSString stringWithFormat:@"Hey, Look what I found on %@\n\n%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"],_productList.strProductShareLink];
    
    NSArray *objectsToShare = @[strShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

-(IBAction)btnStorePressed:(UIButton *)sender
{
    ProductListViewController *productListViewController = [[ProductListViewController alloc]initWithNibName:@"ProductListViewController" bundle:nil];
    productListViewController.strTitle = _productList.strStoreName;
    productListViewController.strStoreId = _productList.strStoreId;
    [self.navigationController pushViewController:productListViewController animated:YES];
}
-(IBAction)btnRatingPressed:(UIButton *)sender;
{
    RatingViewController *ratingViewController = [[RatingViewController alloc]initWithNibName:@"RatingViewController" bundle:nil];
    ratingViewController.strId = _productList.strId;
    [self.navigationController pushViewController:ratingViewController animated:YES];
}

-(IBAction)btnWriteReviewPressed:(UIButton *)sender;
{
    WriteReviewViewController *writeReviewViewController = [[WriteReviewViewController alloc]initWithNibName:@"WriteReviewViewController" bundle:nil];
    writeReviewViewController.strId = _productList.strId;
    writeReviewViewController.strName = _productList.strName;
    [self.navigationController pushViewController:writeReviewViewController animated:YES];
}
-(IBAction)btnPlusPressed:(UIButton *)sender
{
    if([tfQty.text intValue]>=[_productList.strTotalOnHand intValue])
        return;
    tfQty.text = [NSString stringWithFormat:@"%d",[tfQty.text intValue] + 1];
}

-(IBAction)btnMinusPressed:(UIButton *)sender
{
    if([tfQty.text intValue]<=[_productList.strMinimumQuantity intValue])
        return;
    tfQty.text = [NSString stringWithFormat:@"%d",[tfQty.text intValue] - 1];
}

-(IBAction)btnProductDescriptionPressed:(UIButton *)sender
{
    if([_productList.strDescription length])
    {
        WebPageViewController *webPageViewController = [[WebPageViewController alloc]initWithNibName:@"WebPageViewController" bundle:nil];
        
        webPageViewController.strTitle = @"Product Description";
        webPageViewController.strText = _productList.strDescription;
        [self.navigationController pushViewController:webPageViewController animated:YES];
    }
    else
    {
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:nil//NSLocalizedString(@"Whoa!", nil)
                                           subtitle:@"No Any Product Description"
                                              image:nil
                                               type:TSMessageNotificationTypeError
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionBottom
                               canBeDismissedByUser:YES];

    }
//    [self presentPopupViewController:webPageViewController animationType:0];

}

-(IBAction)btnWishPressed:(UIButton *)sender
{
    [SVProgressHUD show];
    
    if([_productList.strInWishlist intValue] == 1)
    {
        if([common checkInternetConnection:TRUE ViewController:self.navigationController])
        {
            NSString *strURL = [NSString stringWithFormat:@"%@%@/%@",WS_BaseUrl,WS_Wishlists,strMasterVariantId];
            

            NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
            
            [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
            [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
            [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
            [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
            
            
            [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Wishlists HTTPMethod:@"DELETE" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
        }
    }
    else
    {
        if([common checkInternetConnection:TRUE ViewController:self.navigationController])
        {
            NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Wishlists];
            
            
            NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
            
            NSMutableDictionary *dicWishlist = [[NSMutableDictionary alloc]init];
            [dicWishlist setObject:strMasterVariantId forKey:@"variant_id"];
            [dicPostData setObject:dicWishlist forKey:@"wishlist"];
            [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
            [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
            [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
            [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
            
            
            [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Wishlists HTTPMethod:@"POST" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
        }
    }
}

-(IBAction)btnAddToCartPressed:(UIButton *)sender
{
    
    if(![_productList.strStockStatus intValue])
    {
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:nil//NSLocalizedString(@"Whoa!", nil)
                                           subtitle:@"Sorry! This product is out of stock"
                                              image:nil
                                               type:TSMessageNotificationTypeError
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionBottom
                               canBeDismissedByUser:YES];
        return;
    }
    
//    NSString *strAlertTitle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Select Delivery Option"
                                                 message:@""
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Home Delivery",@"Pickup",nil];
    [alert setTag:1];
    [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertView class]]] setTintColor:RGB];
    [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]] setTintColor:RGB];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    
}

-(IBAction)btnProductPressed:(UIButton *)sender
{
    ProductDetailViewController *productDetailViewController = [[ProductDetailViewController alloc]initWithNibName:@"ProductDetailViewController" bundle:nil];
    productDetailViewController.dicaDetails = [[dicRelatedItemResponse objectForKey:@"details"] objectAtIndex:sender.tag];
    [self.navigationController pushViewController:productDetailViewController animated:YES];
}


#pragma mark - UIAlertView Delegate Methods -

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1 )
    {
        if(buttonIndex != 0)
        {
            NSString *strDeliveryType;
            if(buttonIndex == 1)
                strDeliveryType = @"home_delivery";
            else if(buttonIndex == 2)
                strDeliveryType = @"pickup";
            
            [SVProgressHUD show];
            
            if([common checkInternetConnection:TRUE ViewController:self.navigationController])
            {
                NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Order];
                
                NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
                NSMutableDictionary *dicOrder = [[NSMutableDictionary alloc]init];
                
                NSMutableArray *arrLineItems = [[NSMutableArray alloc]init];
                
                NSMutableDictionary *dicLineItems = [[NSMutableDictionary alloc]init];
                if(![_productList.arrVariants count])
                    [dicLineItems setObject:_productList.strMasterVariantId forKey:@"variant_id"];
                else
                    [dicLineItems setObject:_productList.strMasterVariantId forKey:@"variant_id"];
                [dicLineItems setObject:strDeliveryType forKey:@"delivery_type"];
                
                [dicLineItems setObject:tfQty.text forKey:@"quantity"];
                [arrLineItems addObject:dicLineItems];
                [dicOrder setObject:arrLineItems forKey:@"line_items"];
                
                [dicPostData setObject:dicOrder forKey:@"order"];
                [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
                [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
                [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
                [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
                
                
                [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Order HTTPMethod:@"POST" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
            }
        }
    }
}

#pragma mark - MWPhotoBrowser Delegate -


-(void)ShowPhotoBrowser:(NSArray *)arrImg{
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    //  MWPhoto photo, thumb;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    BOOL autoPlayOnAppear = YES;
    
    
    for (int i=0; i<[arrImg count]; i++) {
        [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[[arrImg objectAtIndex:i] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
        [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[[arrImg objectAtIndex:i] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    }
    
    //    startOnGrid = YES;
    displayNavArrows = YES;
    
    self.photos = photos;
    self.thumbs = thumbs;
    
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = NO;
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = YES;
    browser.autoPlayOnAppear = autoPlayOnAppear;
    
    NSLog(@"==>%ld",(long)pageControl.currentPage);
    
    [browser setCurrentPhotoIndex:pageControl.currentPage];
    
    [browser showNextPhotoAnimated:YES];
    [browser showPreviousPhotoAnimated:YES];
    
    [appDelegate.ncMain pushViewController:browser animated:YES];
    
    appDelegate.ncMain.interactivePopGestureRecognizer.enabled = NO;
}


- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

#pragma mark - UITextField Delegate Methods -


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([textField.text intValue]>[_productList.strTotalOnHand intValue])
        tfQty.text = _productList.strTotalOnHand;
    
    if([textField.text intValue]<[_productList.strMinimumQuantity intValue])
        tfQty.text = _productList.strMinimumQuantity;
    
}

#pragma mark - WebAPI Response -

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther
{
    switch (tag)
    {
        case 11:
            //Wishlists
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
               
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    if([_productList.strInWishlist intValue] == 1)
                    {
                        _productList.strInWishlist = @"0";
                        [btnWish setImage:[UIImage imageNamed:@"Img-Wish-List.png"] forState:UIControlStateNormal];
                    }
                    else
                    {
                        _productList.strInWishlist = @"1";
                        [btnWish setImage:[UIImage imageNamed:@"Img-Selected-Wish-List.png"] forState:UIControlStateNormal];
                    }
                }
                else
                {
                    NSString *strMessage = @"";
                    if(dicResponse)
                        strMessage = [dicResponse objectForKey:@"message"];
                    else
                        strMessage = @"Something is likely wrong!";
                    
                    [TSMessage showNotificationInViewController:self.navigationController
                                                          title:nil//NSLocalizedString(@"Whoa!", nil)
                                                       subtitle:strMessage
                                                          image:nil
                                                           type:TSMessageNotificationTypeError
                                                       duration:TSMessageNotificationDurationAutomatic
                                                       callback:nil
                                                    buttonTitle:nil
                                                 buttonCallback:nil
                                                     atPosition:TSMessageNotificationPositionBottom
                                           canBeDismissedByUser:YES];
                }
            }
            break;
            
        case 12:
            //Order
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    appDelegate.strCartCount = [dicResponse objectForKey:@"cart_count"];
                    [self setNavigationBar:appDelegate.strCartCount];
                    [TSMessage showNotificationInViewController:self.navigationController
                                                          title:nil//NSLocalizedString(@"Whoa!", nil)
                                                       subtitle:@"Product added to cart"
                                                          image:nil
                                                           type:TSMessageNotificationTypeSuccess
                                                       duration:TSMessageNotificationDurationAutomatic
                                                       callback:nil
                                                    buttonTitle:nil
                                                 buttonCallback:nil
                                                     atPosition:TSMessageNotificationPositionBottom
                                           canBeDismissedByUser:YES];
                }
                else
                {
                    NSString *strMessage = @"";
                    if(dicResponse)
                        strMessage = [dicResponse objectForKey:@"message"];
                    else
                        strMessage = @"Something is likely wrong!";
                    
                    [TSMessage showNotificationInViewController:self.navigationController
                                                          title:nil//NSLocalizedString(@"Whoa!", nil)
                                                       subtitle:strMessage
                                                          image:nil
                                                           type:TSMessageNotificationTypeError
                                                       duration:TSMessageNotificationDurationAutomatic
                                                       callback:nil
                                                    buttonTitle:nil
                                                 buttonCallback:nil
                                                     atPosition:TSMessageNotificationPositionBottom
                                           canBeDismissedByUser:YES];
                }
            }
            break;
            
        case 16:
            //RelatedProduct
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    y+=17;
                    dicRelatedItemResponse = [dicResponse mutableCopy];
                    [self addProductView:y Height:225 Data:dicRelatedItemResponse];
                }
            }
            break;

        case 7:
            //ProductDetail
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    NSMutableArray *arrDetails = [[dicResponse objectForKey:@"details"]mutableCopy];
                    if([arrDetails count])
                    {
                        NSMutableDictionary *dicaDetails = [[arrDetails objectAtIndex:0]mutableCopy];
                        [self parseData:dicaDetails];
                    }
                }
                else
                {
                    NSString *strMessage = @"";
                    if(dicResponse)
                        strMessage = [dicResponse objectForKey:@"message"];
                    else
                        strMessage = @"Something is likely wrong!";

                    [TSMessage showNotificationInViewController:self.navigationController
                                                          title:nil//NSLocalizedString(@"Whoa!", nil)
                                                       subtitle:strMessage
                                                          image:nil
                                                           type:TSMessageNotificationTypeError
                                                       duration:TSMessageNotificationDurationAutomatic
                                                       callback:nil
                                                    buttonTitle:nil
                                                 buttonCallback:nil
                                                     atPosition:TSMessageNotificationPositionBottom
                                           canBeDismissedByUser:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            break;
            
        default:
            break;
            
    }
}
@end
