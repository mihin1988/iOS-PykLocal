//
//  ProductListViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 11/09/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "ProductListViewController.h"
#import "CategoryListCellController.h"
#import "CategoryGridCellController.h"
#import "ProductList.h"
#import "FilterViewController.h"
#import "ProductDetailViewController.h"

@interface ProductListViewController ()<UIActionSheetDelegate,FilterViewDelegate>
{
    AppDelegate *appDelegate;
    Common *common;
    ProductList *productList;
    BarcodeScannerViewController *barcodeScannerViewController;

    NSUserDefaults *prefs;
    NSMutableArray *arrProductList;
    NSMutableArray *arrFilterDetails;
    NSMutableArray *arrAttribute;
    NSMutableArray *arrFilteredAttribute;
    
    NSString *strPerPage;
    NSString *strSortType;
    
    int page;
    int filterApply;
    int numberofpages;
    int selectedIndex;
    
    BOOL blnSelectedView;
    BOOL blnReset;
    BOOL isScanned;
    BOOL isLoadingMoreData;
    
}
@end

@implementation ProductListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];

    arrProductList = [[NSMutableArray alloc]init];
    arrFilterDetails = [[NSMutableArray alloc]init];
    
    strPerPage = @"10";
    strSortType = @"0";
    page = 1;
    filterApply = 0;
    blnSelectedView = FALSE;
    
    [btnSort setEnabled:FALSE];
    [btnFilter setEnabled:FALSE];
    
    UINib *nib = [UINib nibWithNibName:@"CategoryGridCellController" bundle: nil];
    [cvProductList registerNib:nib forCellWithReuseIdentifier:@"CategoryGridCellController"];
    
    [lblTotal setText:[NSString stringWithFormat:@"0 product"]];
    
    [SVProgressHUD show];
//    [self getFilters];
    [self getProductList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.navigationItem.title = _strTitle;
    
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

- (void)getProductList
{
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Search];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        
        NSMutableDictionary *dicQ = [[NSMutableDictionary alloc]init];
        
        [dicQ setObject:[prefs objectForKey:@"token"] forKey:@"token"];
        [dicQ setObject:[_strStoreId length]?_strStoreId:@"" forKey:@"store_id"];
        [dicQ setObject:[_strId length]?_strId:@"" forKey:@"id"];
        [dicQ setObject:[_strParentCategoryId length]?_strParentCategoryId:@"" forKey:@"parent_category_id"];
        [dicQ setObject:[_strSearch length]?_strSearch:@"" forKey:@"search"];
        [dicQ setObject:strPerPage forKey:@"per_page"];
        
        
        if([strSortType intValue] == 2)
            [dicQ setObject:@"1" forKey:@"sort_type"];
        else if([strSortType intValue] == 1)
            [dicQ setObject:@"2" forKey:@"sort_type"];
        else
            [dicQ setObject:strSortType forKey:@"sort_type"];
        
        for(int i = 0 ; i<[arrFilteredAttribute count] ; i++)
        {
            NSMutableDictionary *dicAttribute = [[arrAttribute objectAtIndex:i]mutableCopy];
            NSMutableDictionary *dicFilteredAttribut = [[arrFilteredAttribute objectAtIndex:i]mutableCopy];
            NSMutableArray *arrData = [[NSMutableArray alloc]init];
            
            for(int j = 0 ; j < [[dicFilteredAttribut objectForKey:@"list"] count] ; j++)
            {
                if([[[dicFilteredAttribut objectForKey:@"list"] objectAtIndex:j] isEqualToString:@"1"])
                {
                    [arrData addObject:[[dicAttribute objectForKey:@"list"] objectAtIndex:j]];
                }
            }
            if([arrData count])
                [dicQ setObject:arrData forKey:[[dicAttribute objectForKey:@"name"] lowercaseString]];
        }
        
        [dicPostData setObject:dicQ forKey:@"q"];
        [dicPostData setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
        [dicPostData setObject:[NSString stringWithFormat:@"%d",filterApply] forKey:@"filter_apply"];
        
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];

        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:Search HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
}

- (void)getFilters
{
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        [SVProgressHUD show];
        
        NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Filters];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:Filters HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
    
}


- (void)filteredData:(NSMutableArray *)arrFilteredattribute ISReset:(BOOL)isReset
{
    blnReset = isReset;
    arrFilteredAttribute = [arrFilteredattribute mutableCopy];
    page = 1;
    [common.manager.operationQueue cancelAllOperations];
    [SVProgressHUD show];
    [self getProductList];
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

-(IBAction)btnSortPressed:(UIButton *)sender
{
    
    NSMutableArray *arrSortType = [[NSMutableArray alloc]initWithObjects:@"Newest First",@"Price -- Low to High",@"Price -- High to Low", nil];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    for (NSString *username in arrSortType) {
        [actionSheet addButtonWithTitle:username];
    }
    
    actionSheet.tintColor = RGB;
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    
    [actionSheet showInView:[[[[[UIApplication sharedApplication] delegate] window] rootViewController] view]];
}

-(IBAction)btnFilterPressed:(UIButton *)sender
{
    if([arrAttribute count])
    {
        FilterViewController *filterViewController = [[FilterViewController alloc]initWithNibName:@"FilterViewController" bundle:nil];
        
        [filterViewController setDelegate:self];
        filterViewController.arrAttributes = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:arrAttribute]];
        filterViewController.arrFilteredAttribute = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:arrFilteredAttribute]];
        
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:filterViewController];
        
        //now present this navigation controller modally
        [self presentViewController:navigationController animated:YES completion:^{}];
    }
    else
    {
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:nil//NSLocalizedString(@"Whoa!", nil)
                                           subtitle:@"All products in this list are of same attribute"
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

-(IBAction)btnChangeViewPressed:(UIButton *)sender
{
    blnSelectedView = !blnSelectedView;
    
    if(blnSelectedView)
    {
        UINib *nib = [UINib nibWithNibName:@"CategoryListCellController" bundle: nil];
        [cvProductList registerNib:nib forCellWithReuseIdentifier:@"CategoryListCellController"];
        
        [btnChangeView setImage:[UIImage imageNamed:@"Img-Grid-View.png"] forState:UIControlStateNormal];
    }
    else
    {
        UINib *nib = [UINib nibWithNibName:@"CategoryGridCellController" bundle: nil];
        [cvProductList registerNib:nib forCellWithReuseIdentifier:@"CategoryGridCellController"];
        
        [btnChangeView setImage:[UIImage imageNamed:@"Img-List-View.png"] forState:UIControlStateNormal];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [cvProductList setAlpha:0.0];
    }completion:^(BOOL finished) {
        [cvProductList reloadData];
        [UIView animateWithDuration:0.2 animations:^{
            [cvProductList setAlpha:1.0];
        }];
    }];
    
//    NSMutableArray *arrIndexPath = [[NSMutableArray alloc]init];
//    for (int i = 0; i < [arrProductList count]; i++)
//    {
//        NSIndexPath *myIP = [NSIndexPath indexPathForRow:i inSection:0] ;
//        [arrIndexPath addObject:myIP];
//    }
//    
//    
//    [cvProductList performBatchUpdates:^{
//        [cvProductList reloadItemsAtIndexPaths:arrIndexPath];
//    } completion:^(BOOL finished) {
//        [cvProductList reloadData];
//    }];
}

-(IBAction)btnWishPressed:(UIButton *)sender
{
    productList = (ProductList *)[arrProductList objectAtIndex:sender.tag];
    selectedIndex = (int)sender.tag;
    
    [SVProgressHUD show];
    
    if([productList.strInWishlist intValue] == 1)
    {
        if([common checkInternetConnection:TRUE ViewController:self.navigationController])
        {
            NSString *strURL = [NSString stringWithFormat:@"%@%@/%@",WS_BaseUrl,WS_Wishlists,productList.strMasterVariantId];
            
    
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
            [dicWishlist setObject:productList.strMasterVariantId forKey:@"variant_id"];
            [dicPostData setObject:dicWishlist forKey:@"wishlist"];
            [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
            [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
            [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
            [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
            
            
            [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Wishlists HTTPMethod:@"POST" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
        }
    }
}

#pragma mark - UIActionSheet Method -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    

        if([strSortType integerValue] != buttonIndex && buttonIndex != 3)
        {
            [viewLoadMore setHidden:TRUE];
            strSortType = [NSString stringWithFormat:@"%ld",(long)buttonIndex];
            page = 1;
            [common.manager.operationQueue cancelAllOperations];
            [SVProgressHUD show];
            [self getProductList];
        }
    
}

#pragma mark - CollectionView DataSource -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return arrProductList.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Adjust cell size for orientation
    if (blnSelectedView)
        return CGSizeMake(self.view.frame.size.width-20, 112.0f);
    else
        return CGSizeMake((self.view.frame.size.width/2)-15, 220.f);
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    //    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    CategoryListCellController *cellList;
    CategoryGridCellController *cellGrid;
    
    productList = [[ProductList alloc]init];
    productList = (ProductList *)[arrProductList objectAtIndex:indexPath.row];
    
    
    if (blnSelectedView)
    {
        cellList = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryListCellController" forIndexPath:indexPath];
        
        [cellList setBackgroundColor:[UIColor whiteColor]];
        
        [cellList.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
        [cellList.layer setBorderWidth:1.0];
        cellList.layer.cornerRadius = 2.0;
        cellList.clipsToBounds = YES;
        
        
        [cellList.ivImage sd_setImageWithURL:[NSURL URLWithString:([productList.arrProductImages count])?[productList.arrProductImages objectAtIndex:0]:@""] placeholderImage:[UIImage imageNamed:@"Img-Logo.png"] options:SDWebImageProgressiveDownload progress:nil completed:nil];
        cellList.lblTitle.text = productList.strName;
        cellList.lblPrice.text = [NSString stringWithFormat:@"%@",[appDelegate numberFormatter:productList.strPrice CurrencySymbol:appDelegate.strCurrencySymbol]];
        [cellList.lblPrice sizeToFit];
        
        
        [cellList.btnAddToWish addTarget:self action:@selector(btnWishPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cellList.btnAddToWish setTag:indexPath.row];
        
        
        if([productList.strInWishlist intValue] == 1)
            [cellList.btnAddToWish setImage:[UIImage imageNamed:@"Img-Selected-Wish-List1.png"] forState:UIControlStateNormal];
        else
            [cellList.btnAddToWish setImage:[UIImage imageNamed:@"Img-Wish-List1.png"] forState:UIControlStateNormal];
        
        if([productList.strDiscount floatValue])
        {
            for(UIView* view in [cellList.viewOffer subviews])
                [view removeFromSuperview];

            [cellList.lblPrice setText:[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",[productList.strSpecialPrice doubleValue]] CurrencySymbol:appDelegate.strCurrencySymbol]];
            [cellList.lblPrice sizeToFit];

            UILabel *lblPrice = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 140, 15)];
            [lblPrice setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10]];
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[appDelegate numberFormatter:productList.strPrice CurrencySymbol:appDelegate.strCurrencySymbol]];
            
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
            
            if([productList.strDiscount floatValue] - [productList.strDiscount intValue] == 0)
                [lblDiscount setText:[NSString stringWithFormat:@"%d%% OFF",[productList.strDiscount intValue]]];
            else
                [lblDiscount setText:[NSString stringWithFormat:@"%.2f%% OFF",[productList.strDiscount doubleValue]]];
            [lblDiscount sizeToFit];
            
            
            
            CGRect frame = lblPrice.frame;
            frame.origin.y = cellList.lblPrice.frame.origin.y+3;
            frame.size.width += lblDiscount.frame.size.width;
            frame.origin.x = cellList.lblPrice.frame.origin.x + cellList.lblPrice.frame.size.width + 5;
            frame.size.height = cellList.lblPrice.frame.size.height;
            
            [cellList.viewOffer setFrame:frame];
            
            [cellList.viewOffer addSubview:lblPrice];
            [cellList.viewOffer addSubview:lblDiscount];
            
            [cellList.viewOffer setHidden:FALSE];
        }
        else
            [cellList.viewOffer setHidden:TRUE];
        
        return cellList;
    }
    else
    {
        cellGrid = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryGridCellController" forIndexPath:indexPath];
        
        [cellGrid setBackgroundColor:[UIColor whiteColor]];
        
        [cellGrid.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
        [cellGrid.layer setBorderWidth:1.0];
        cellGrid.layer.cornerRadius = 2.0;
        cellGrid.clipsToBounds = YES;
        
        [cellGrid.ivImage sd_setImageWithURL:[NSURL URLWithString:([productList.arrProductImages count])?[productList.arrProductImages objectAtIndex:0]:@""] placeholderImage:[UIImage imageNamed:@"Img-Logo.png"] options:SDWebImageProgressiveDownload progress:nil completed:nil];
        cellGrid.lblTitle.text = productList.strName;
        cellGrid.lblPrice.text = [NSString stringWithFormat:@"%@",[appDelegate numberFormatter:productList.strPrice CurrencySymbol:appDelegate.strCurrencySymbol]];
        
        [cellGrid.btnAddToWish addTarget:self action:@selector(btnWishPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cellGrid.btnAddToWish setTag:indexPath.row];
        
        if([productList.strInWishlist intValue] == 1)
            [cellGrid.btnAddToWish setImage:[UIImage imageNamed:@"Img-Selected-Wish-List1.png"] forState:UIControlStateNormal];
        else
            [cellGrid.btnAddToWish setImage:[UIImage imageNamed:@"Img-Wish-List1.png"] forState:UIControlStateNormal];
        
        if([productList.strDiscount floatValue])
        {
            for(UIView* view in [cellGrid.viewOffer subviews])
                [view removeFromSuperview];

            [cellGrid.lblPrice setText:[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",[productList.strSpecialPrice doubleValue]] CurrencySymbol:appDelegate.strCurrencySymbol]];
            
            UILabel *lblPrice = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 140, 15)];
            [lblPrice setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10]];
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[appDelegate numberFormatter:productList.strPrice CurrencySymbol:appDelegate.strCurrencySymbol]];
            
            [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                    value:@1
                                    range:NSMakeRange(0, [attributeString length])];
            
            lblPrice.attributedText = attributeString;
            [lblPrice sizeToFit];
            [lblPrice setBackgroundColor:[UIColor whiteColor]];
            [lblPrice setTextColor:[UIColor grayColor]];

            UILabel *lblDiscount = [[UILabel alloc]initWithFrame:CGRectMake(lblPrice.frame.size.width+lblPrice.frame.origin.x+5, 0, 140, 15)];
            [lblDiscount setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:10]];
            [lblDiscount setBackgroundColor:[UIColor clearColor]];
            [lblDiscount setTextColor:[UIColor redColor]];
            
            if([productList.strDiscount floatValue] - [productList.strDiscount intValue] == 0)
                [lblDiscount setText:[NSString stringWithFormat:@"%d%% OFF",[productList.strDiscount intValue]]];
            else
                [lblDiscount setText:[NSString stringWithFormat:@"%.2f%% OFF",[productList.strDiscount doubleValue]]];
            [lblDiscount sizeToFit];
            
            
            CGRect frame = lblPrice.frame;
            frame.origin.y = 180;
            frame.size.width += lblDiscount.frame.size.width;
            frame.origin.x = (cellGrid.frame.size.width/2) - (frame.size.width/2);
            frame.size.height = cellGrid.lblPrice.frame.size.height;
            
            [cellGrid.viewOffer setFrame:frame];
            
            [cellGrid.viewOffer addSubview:lblPrice];
            [cellGrid.viewOffer addSubview:lblDiscount];
            
            [cellGrid.viewOffer setHidden:FALSE];
        }
        else
            [cellGrid.viewOffer setHidden:TRUE];
        
        return cellGrid;
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 30);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
    {
        if (!isLoadingMoreData)
        {
            if(numberofpages>page)
            {
                isLoadingMoreData = TRUE;
                [viewLoadMore setHidden:FALSE];
                page++;
                [self getProductList];
            }
        }
    }
}


#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    productList = (ProductList *)[arrProductList objectAtIndex:indexPath.row];

    ProductDetailViewController *productDetailViewController = [[ProductDetailViewController alloc]initWithNibName:@"ProductDetailViewController" bundle:nil];
    productDetailViewController.productList = productList;
    [self.navigationController pushViewController:productDetailViewController animated:YES];
}

#pragma mark - WebAPI Response -

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther
{
    switch (tag)
    {
        case 9:
            //Search
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    [btnSort setEnabled:TRUE];
                    [btnFilter setEnabled:TRUE];

                    if(page == 1 && filterApply == 0)
                    {
                        filterApply = 1;
                        arrAttribute = [[dicResponse objectForKey:@"attributes"]mutableCopy];
                        arrFilteredAttribute = [[dicResponse objectForKey:@"attributes"]mutableCopy];
                    }
                    
                    if([[dicResponse objectForKey:@"total_product"] intValue] >1)
                        [lblTotal setText:[NSString stringWithFormat:@"%@ products",[dicResponse objectForKey:@"total_product"]]];
                    else
                        [lblTotal setText:[NSString stringWithFormat:@"%@ product",[dicResponse objectForKey:@"total_product"]]];

                    numberofpages = [[dicResponse objectForKey:@"number_of_pages"] intValue];
                    
                    NSMutableArray *arrDetails = [[dicResponse objectForKey:@"details"]mutableCopy];
                    
                    if(page==1)
                    {
                        arrProductList = [[NSMutableArray alloc]init];
                        [cvProductList setContentOffset:CGPointMake(0, 0)];
                    }
                    
                    for(int i = 0 ; i<[arrDetails count] ; i++)
                    {
                        NSMutableDictionary *dicaDetails = [[arrDetails objectAtIndex:i]mutableCopy];
                        
                        productList = [[ProductList alloc]init];
                        
                        productList.strId = [dicaDetails objectForKey:@"id"];
                        productList.strDescription = [dicaDetails objectForKey:@"description"];
                        productList.strDiscount = [dicaDetails objectForKey:@"discount"];
                        productList.strReview = [dicaDetails objectForKey:@"review"];
                        productList.strTotalOnHand = [dicaDetails objectForKey:@"total_on_hand"];
                        productList.strMinimumQuantity = [dicaDetails objectForKey:@"minimum_quantity"];
                        productList.strAverageRatings = [dicaDetails objectForKey:@"average_ratings"];
                        productList.strTotalRating = [dicaDetails objectForKey:@"total_rating"];
                        productList.strPrice = [dicaDetails objectForKey:@"price"];
                        productList.strStockStatus = [dicaDetails objectForKey:@"stock_status"];
                        productList.strInWishlist = [dicaDetails objectForKey:@"in_wishlist"];
                        productList.strName = [dicaDetails objectForKey:@"name"];
                        productList.strSpecialPrice = [dicaDetails objectForKey:@"special_price"];
                        productList.arrProductImages = [dicaDetails objectForKey:@"product_images"];
                        productList.arrVariants = [dicaDetails objectForKey:@"variants"];
                        productList.strMasterVariantId = [dicaDetails objectForKey:@"master_variant_id"];
                        productList.strStoreId = [dicaDetails objectForKey:@"store_id"];
                        productList.strStoreName = [dicaDetails objectForKey:@"store_name"];
                        productList.strProductShareLink = [dicaDetails objectForKey:@"product_share_link"];

                        [arrProductList addObject:productList];
                    }
                    [cvProductList reloadData];
                    [cvProductList setHidden:FALSE];
                }
                else
                {
                    [btnSort setEnabled:FALSE];
                    
                    [lblTotal setText:[NSString stringWithFormat:@"0 product"]];
                    
                    if(![[dicOther objectForKey:@"Code"]isEqualToString:@"-999"])
                    {
                        [cvProductList setHidden:TRUE];
                        
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
                    else
                        [SVProgressHUD show];
                }
                isLoadingMoreData = FALSE;
                [viewLoadMore setHidden:TRUE];
            }
            break;
            
        case 10:
            //Filters
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    arrAttribute = [[dicResponse objectForKey:@"attribute"]mutableCopy];
                    arrFilteredAttribute = [[dicResponse objectForKey:@"attribute"]mutableCopy];
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
     
        case 11:
            //Wishlists
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    productList = (ProductList *)[arrProductList objectAtIndex:selectedIndex];
                    if([productList.strInWishlist intValue] == 1)
                        productList.strInWishlist = @"0";
                    else
                        productList.strInWishlist = @"1";
                    [arrProductList replaceObjectAtIndex:selectedIndex withObject:productList];
                    [cvProductList reloadData];
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
            
            
        default:
            break;
            
    }
}
@end
