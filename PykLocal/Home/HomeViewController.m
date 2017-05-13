//
//  HomeViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 21/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "HomeViewController.h"
#import "PowerfulBannerView.h"
#import "BannerList.h"
#import "ProductListViewController.h"
#import "ProductDetailViewController.h"

@interface HomeViewController ()<BarcodeScannerDelegate>
{
    AppDelegate *appDelegate;
    Common *common;
    WishList *wishList;
    BarcodeScannerViewController *barcodeScannerViewController;
    
    NSUserDefaults *prefs;
//    UIPageControl *pageControl;
    NSMutableArray *arrDetails;
    
    BOOL isScanned;
    BOOL isFirstTimeLoad;
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    
    if(appDelegate.isCart)
        [self btnCartPressed:nil];
    
    [svContainer setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [SVProgressHUD show];
    [self getHomeScreenDetail];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(appDelegate.isEmptyCart)
    {
        [SVProgressHUD show];
        [self getHomeScreenDetail];
        appDelegate.isEmptyCart = FALSE;
    }
    
    //Mange Slider
    appDelegate.isHandlePan = TRUE;
    
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
//    UINavigationItem *navigationItem = [self.navigationController.navigationBar.items objectAtIndex:1];
//    UIBarButtonItem *btnCart = [navigationItem.rightBarButtonItems objectAtIndex:0];
//    
//    [TSMessage dismissActiveNotification];
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
    self.navigationItem.titleView = logoView;
    
    UIBarButtonItem *btnLeft = [[UIBarButtonItem alloc]
                                initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
                                target:self action:@selector(leftSideMenuButtonPressed:)];
    [self.navigationItem setLeftBarButtonItem:btnLeft];
    
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

- (void)getHomeScreenDetail
{
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Home];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
//        strURL = @"http://54.186.114.27/ap1/v1/ratings_reviews";
//        [dicPostData setObject:@"313" forKey:@"product_id"];
    
        
        
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:Home HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }

}

- (void)addBannerView:(int)y Height:(int)height Data:(NSMutableDictionary *)dicData
{
    
    PowerfulBannerView *bannerView = [[PowerfulBannerView alloc] initWithFrame:CGRectMake(10.f, y, appDelegate.window.bounds.size.width-20, height)];
    [bannerView setTag:1];
    [bannerView setBackgroundColor:[UIColor clearColor]];
    bannerView.loopingInterval = 10.f;
    bannerView.autoLooping = YES;

    UIPageControl *pageControl = [[UIPageControl alloc]init];
    bannerView.pageControl = pageControl;
    [pageControl setCurrentPageIndicatorTintColor:RGB];
    [pageControl setPageIndicatorTintColor:[UIColor colorWithWhite:0 alpha:.3]];
    [pageControl setUserInteractionEnabled:FALSE];
    [pageControl setFrame:CGRectMake(0, y+height-20, appDelegate.window.bounds.size.width, 15)];
    
    NSMutableArray *arrItemList = [[dicData objectForKey:@"item_list"]mutableCopy];
    
    
    if(arrItemList)
        bannerView.items = arrItemList;
    
    
    bannerView.bannerItemConfigurationBlock = ^UIView *(PowerfulBannerView *banner, id item, UIView *reusableView) {
        
        UIImageView *view = (UIImageView *)reusableView;
        if (!view) {
            view = [[UIImageView alloc] initWithFrame:CGRectZero];
            view.contentMode = UIViewContentModeScaleAspectFit;
            view.clipsToBounds = YES;
        }
        
        NSMutableDictionary *dicItemList = [item mutableCopy];
        
        [view sd_setImageWithURL:[NSURL URLWithString:[dicItemList objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"Img-Logo.png"] options:SDWebImageProgressiveDownload progress:nil completed:nil];
        
        return view;
    };
    
    bannerView.bannerDidSelectBlock = ^(PowerfulBannerView *banner, NSInteger index) {
        NSMutableDictionary *dicItemList = [[banner.items objectAtIndex:index] mutableCopy];
        
        if([[dicItemList objectForKey:@"category_id"] length])
        {
            ProductListViewController *productListViewController = [[ProductListViewController alloc]initWithNibName:@"ProductListViewController" bundle:nil];
            productListViewController.strTitle = @"Product List";
            productListViewController.strId = [dicItemList objectForKey:@"category_id"];
            [self.navigationController pushViewController:productListViewController animated:YES];
        }
        printf("banner did select index at: %zd \n", index);
    };
    
    //
    //        self.bannerView.bannerIndexChangeBlock = ^(PowerfulBannerView *banner, NSInteger fromIndex, NSInteger toIndex) {
    //            printf("banner changed index from %zd to %zd\n", fromIndex, toIndex);
    //        };
    //
    //        self.bannerView.longTapGestureHandler = ^(PowerfulBannerView *banner, NSInteger index, id item, UIView *view) {
    //            printf("banner long gesture recognized on index: %zd !\n", index);
    //        };
    
    [svContainer addSubview:bannerView];

    if([[dicData objectForKey:@"index"]intValue] == 0)
    {
        if ([bannerView.items count] <=1)
            [pageControl setHidden:TRUE];
        else
            [pageControl setHidden:FALSE];
        
        [svContainer addSubview:pageControl];
    }
    
}

- (void)addProductView:(int)y Height:(int)height Data:(NSMutableDictionary *)dicData
{
    
    NSMutableArray *arrItemList = [dicData objectForKey:@"item_list"];
    
    if([arrItemList count])
    {
        UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, y, appDelegate.window.bounds.size.width-80, 20)];
        [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [lblTitle setTextColor:[UIColor blackColor]];
        [lblTitle setText:[dicData objectForKey:@"title"]];
        [svContainer addSubview:lblTitle];
        
        
        UIButton *btnViewAll = [[UIButton alloc]initWithFrame:CGRectMake(appDelegate.window.bounds.size.width-70, y, 60, 20)];
        [btnViewAll.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
        [btnViewAll setTitle:@"View All" forState:UIControlStateNormal];
        [btnViewAll setTag:[[dicData objectForKey:@"index"]intValue]];
        
        if(![[dicData objectForKey:@"parent_category_id"] intValue])
            [btnViewAll setHidden:TRUE];
        
        [btnViewAll setBackgroundColor:[UIColor clearColor]];
        [btnViewAll setTitleColor:RGB forState:UIControlStateNormal];
        btnViewAll.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnViewAll addTarget:self action:@selector(btnViewAllPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        y +=23;
        
        
        UILabel *lblStrip = [[UILabel alloc]initWithFrame:CGRectMake(0, y, appDelegate.window.bounds.size.width, 1)];
        [lblStrip setBackgroundColor:[UIColor colorWithWhite:0 alpha:.1]];
        [svContainer addSubview:lblStrip];
        
        UIScrollView *svProductContainer = [[UIScrollView alloc]initWithFrame:CGRectMake(0, y, appDelegate.window.bounds.size.width, 205)];
        
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
            
            if([[dicProduct objectForKey:@"in_wishlist"] intValue] == 1)
            {
                [btnWishList setImage:[UIImage imageNamed:@"Img-Selected-Wish-List1.png"] forState:UIControlStateNormal];

                wishList = [[WishList alloc]init];
                
                wishList.strId = [dicProduct objectForKey:@"id"];
                wishList.strName = [dicProduct objectForKey:@"name"];
                wishList.strImage = ([[dicProduct objectForKey:@"product_images"]count])?[[dicProduct objectForKey:@"product_images"] objectAtIndex:0]:@"";
                
                //                [toOrderList insertRecordForProduct:toOrderList];
            }
            else
                [btnWishList setImage:[UIImage imageNamed:@"Img-Wish-List1.png"] forState:UIControlStateNormal];


            
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
            
            
            UILabel *lblPrice = [[UILabel alloc]initWithFrame:CGRectMake(5, 170, 140, 15)];
            [lblPrice setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12]];
            [lblPrice setTextAlignment:NSTextAlignmentCenter];
            [lblPrice setBackgroundColor:[UIColor clearColor]];
            [lblPrice setTextColor:[UIColor grayColor]];
            [lblPrice setText:[appDelegate numberFormatter:[dicProduct objectForKey:@"price"] CurrencySymbol:appDelegate.strCurrencySymbol]];
            
            [view addSubview:lblPrice];
            
            
            NSString *strTitle = [NSString stringWithFormat:@"%@+%d",[dicData objectForKey:@"index"],j];
//            [dicProduct objectForKey:@"id"]
            
            UIButton *btnProduct = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 150, 205)];
            [btnProduct setTitle:strTitle forState:UIControlStateNormal];
            [btnProduct setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [btnProduct addTarget:self action:@selector(btnProductPressed:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btnProduct];
//            [view addSubview:btnWishList];

            if([[dicProduct objectForKey:@"discount"] floatValue])
            {
            
                [lblPrice setText:[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",[[dicProduct objectForKey:@"special_price"]doubleValue]] CurrencySymbol:appDelegate.strCurrencySymbol]];
                
                UILabel *lblPrice = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 140, 15)];
                [lblPrice setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10]];
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[appDelegate numberFormatter:[dicProduct objectForKey:@"price"] CurrencySymbol:appDelegate.strCurrencySymbol]];
                
                [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                        value:@1
                                        range:NSMakeRange(0, [attributeString length])];
                
                lblPrice.attributedText = attributeString;
                [lblPrice sizeToFit];
                [lblPrice setBackgroundColor:[UIColor clearColor]];
                [lblPrice setTextColor:[UIColor grayColor]];
                
                
                UILabel *lblDiscount = [[UILabel alloc]initWithFrame:CGRectMake(lblPrice.frame.size.width+lblPrice.frame.origin.x+5, 0, 140, 15)];
                [lblDiscount setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:10]];
                [lblDiscount setBackgroundColor:[UIColor clearColor]];
                [lblDiscount setTextColor:RGB];
                
                if([[dicProduct objectForKey:@"discount"]doubleValue] - [[dicProduct objectForKey:@"discount"]intValue] == 0)
                    [lblDiscount setText:[NSString stringWithFormat:@"%d%% OFF",[[dicProduct objectForKey:@"discount"]intValue]]];
                else
                    [lblDiscount setText:[NSString stringWithFormat:@"%.2f%% OFF",[[dicProduct objectForKey:@"discount"]doubleValue]]];
                [lblDiscount sizeToFit];
                
                
                CGRect frame = lblPrice.frame;
                frame.origin.y = 185;
                frame.size.width += lblDiscount.frame.size.width;
                frame.origin.x = (view.frame.size.width/2) - (frame.size.width/2);
                
                UIView *viewOffer = [[UIView alloc]initWithFrame:frame];
                
                [viewOffer addSubview:lblPrice];
                [viewOffer addSubview:lblDiscount];
                
                [view addSubview:viewOffer];
                
            }
            
            [svContainer addSubview:btnViewAll];
        
            [svProductContainer addSubview:view];
            
            x += 150+space;
        }
        [svProductContainer setShowsHorizontalScrollIndicator:FALSE];
        [svContainer addSubview:svProductContainer];
        
    }
}

- (void)searchProduct:(NSString *)strCode;
{
    sqlite3_stmt *statement;
    
    NSString *insertSQL = [NSString stringWithFormat:@"insert or replace into search values(\"%@\")",strCode];
    
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
    productListViewController.strTitle = @"Search Result";
    productListViewController.strId = @"";
    productListViewController.strSearch = strCode;
    [self.navigationController pushViewController:productListViewController animated:YES];
}

#pragma mark - IBAction Method -

-(IBAction)btnSearchPressed:(UIButton *)sender
{
    SearchViewController *searchViewController = [[SearchViewController alloc]initWithNibName:@"SearchViewController" bundle:nil];
    [self.navigationController pushViewController:searchViewController animated:NO];
}

-(IBAction)btnBarocdeScanPressed:(UIButton *)sender
{
    isScanned = TRUE;
    barcodeScannerViewController = [[BarcodeScannerViewController alloc]initWithNibName:@"BarcodeScannerViewController" bundle:nil];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:barcodeScannerViewController];
    [self presentViewController:navigationController animated:YES completion:^{}];
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


-(IBAction)btnViewAllPressed:(UIButton *)sender
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(index LIKE[c] %@)",[NSString stringWithFormat:@"%ld",(long)sender.tag]];
    NSArray *arrDetail = [arrDetails filteredArrayUsingPredicate:predicate];
    
    if([arrDetail count])
    {
        NSMutableDictionary *dicDetails = [arrDetail objectAtIndex:0];
        
        ProductListViewController *productListViewController = [[ProductListViewController alloc]initWithNibName:@"ProductListViewController" bundle:nil];
        productListViewController.strTitle = [dicDetails objectForKey:@"title"];
        productListViewController.strParentCategoryId = [dicDetails objectForKey:@"parent_category_id"];
        [self.navigationController pushViewController:productListViewController animated:YES];
    }
}

-(IBAction)btnWishPressed:(UIButton *)sender
{
    if ([sender.titleLabel.text intValue] == 1 )
    {
        [sender setImage:[UIImage imageNamed:@"Img-Wish-List1.png"] forState:UIControlStateNormal];
        [sender setTitle:@"0" forState:UIControlStateNormal];
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"Img-Selected-Wish-List1.png"] forState:UIControlStateNormal];
        [sender setTitle:@"1" forState:UIControlStateNormal];
    }
}

-(IBAction)btnProductPressed:(UIButton *)sender
{
    NSLog(@"%@",sender.titleLabel.text);
    
    NSArray *arrIndex = [sender.titleLabel.text componentsSeparatedByString:@"+"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(index LIKE[c] %@)",[arrIndex objectAtIndex:0]];
    NSArray *arrDetail = [arrDetails filteredArrayUsingPredicate:predicate];
    
    NSMutableArray *arrItemList;
    if([arrDetail count])
    {
        NSMutableDictionary *dicDetails = [arrDetail objectAtIndex:0];
        arrItemList = [[dicDetails objectForKey:@"item_list"]mutableCopy];
    }
    
    ProductDetailViewController *productDetailViewController = [[ProductDetailViewController alloc]initWithNibName:@"ProductDetailViewController" bundle:nil];
    productDetailViewController.dicaDetails = [arrItemList objectAtIndex:[[arrIndex objectAtIndex:1] intValue]];
    [self.navigationController pushViewController:productDetailViewController animated:YES];
}


#pragma mark - UIBarButtonItem Callbacks -

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    
    [appDelegate.leftMenuViewController setSliderList];
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}

#pragma mark - UIScrollView Delegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(svContainer.contentOffset.y <= -200)
    {
        [SVProgressHUD show];
        [self getHomeScreenDetail];
    }

}
#pragma mark - WebAPI Response -

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther
{
    switch (tag)
    {
        case 8:
            //Home
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    for(UIView* view in [svContainer subviews])
                        [view removeFromSuperview];
                    
                    arrDetails = [[dicResponse objectForKey:@"details"]mutableCopy];
                    
                    appDelegate.strCartCount = [dicResponse objectForKey:@"cart_count"];
                    [self setNavigationBar:appDelegate.strCartCount];
                    
                    int y = 45;
                    int height = 0;
                    
                    for(int i = 0 ; i<=[arrDetails count] ; i++)
                    {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(index LIKE[c] %@)",[NSString stringWithFormat:@"%d",i]];
                        NSArray *arrDetail = [arrDetails filteredArrayUsingPredicate:predicate];
                        
                        if([arrDetail count])
                        {
                            NSMutableDictionary *dicDetails = [arrDetail objectAtIndex:0];
                            if([[dicDetails objectForKey:@"item_list"] count])
                            {
                                if([[dicDetails objectForKey:@"view_type"]intValue] == 0)//Banner
                                {
                                    height = (160 * appDelegate.window.bounds.size.width)/320 ;
                                    [self addBannerView:y Height:height Data:dicDetails];
                                }
                                else
                                {
                                    height = 225;
                                    [self addProductView:y Height:height Data:dicDetails];
                                }
                                
                                y += height+15;
                            }
                        }
                    }
                    [svContainer setContentSize:CGSizeMake(appDelegate.window.bounds.size.width, y)];
                    isFirstTimeLoad = TRUE;
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
//                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            [SVProgressHUD dismiss];
            break;
        default:
            break;
            
    }
}


@end
