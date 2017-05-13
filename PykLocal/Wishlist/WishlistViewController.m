//
//  WishlistViewController.m
//  PykLocal
//
//  Created by Saket Singhi on 05/11/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "WishlistViewController.h"
#import "ProductListViewController.h"
#import "WishlistTableViewCell.h"
#import "ProductDetailViewController.h"
#import "ProductList.h"
#import "MGSwipeButton.h"
#import "MGSwipeTableCell.h"

@interface WishlistViewController ()<MGSwipeTableCellDelegate>
{
    AppDelegate *appDelegate;
    Common *common;
    BarcodeScannerViewController *barcodeScannerViewController;
    ProductList *productList;
    
    NSUserDefaults *prefs;
    NSMutableArray *arrWishList;
    
    int selectedCell;
    
    BOOL isScanned;
    BOOL isMoveToCart;
}
@end

@implementation WishlistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Mange Slider
    appDelegate.isHandlePan = TRUE;
    
    //Mange NavigationBar With Cart Count
    [self setNavigationBar:appDelegate.strCartCount];
    
    [SVProgressHUD show];
    arrWishList = nil;
    [self getWishList];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helper Method -

- (void)setNavigationBar:(NSString *)strCartValue
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    
    [self.navigationController setNavigationBarHidden:FALSE];
    
    UIButton *logoView = [[UIButton alloc] initWithFrame:CGRectMake(0,0,60,60)];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,60,60)];
    image.contentMode = UIViewContentModeScaleAspectFit;
    [image setImage: [UIImage imageNamed:@"Img-Logo.png"]];
    [logoView addSubview:image];
    [logoView setUserInteractionEnabled:NO];
    //    self.navigationItem.titleView = logoView;
    self.navigationItem.title = @"Wishlist";
    
    if(!_back)
    {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        UIBarButtonItem *btnLeft = [[UIBarButtonItem alloc]
                                    initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
                                    target:self action:@selector(leftSideMenuButtonPressed:)];
        [self.navigationItem setLeftBarButtonItem:btnLeft];
    }
    
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
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnCart, nil]];
}

- (void)getWishList
{
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Wishlists];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        
        [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:Wishlists HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
    
}

#pragma mark - UIBarButtonItem Callbacks -

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
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

-(IBAction)btnBarocdeScanPressed:(UIButton *)sender
{
    isScanned = TRUE;
    barcodeScannerViewController = [[BarcodeScannerViewController alloc]initWithNibName:@"BarcodeScannerViewController" bundle:nil];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:barcodeScannerViewController];
    [self presentViewController:navigationController animated:YES completion:^{}];
}

-(IBAction)btnProductPressed:(UIButton *)sender
{
    NSLog(@"%ld",(long)sender.tag);
    
    productList = [arrWishList objectAtIndex:sender.tag];

    ProductDetailViewController *productDetailViewController = [[ProductDetailViewController alloc]initWithNibName:@"ProductDetailViewController" bundle:nil];
    productDetailViewController.productList = productList;
    [self.navigationController pushViewController:productDetailViewController animated:YES];
}

#pragma mark - UITable View Delegate Methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrWishList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *v = [UIView new];
//    [v setBackgroundColor:[UIColor clearColor]];
//    return v;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    MGSwipeTableCell *cell;
    if (cell == nil)
    {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
        cell.rightSwipeSettings.transition = MGSwipeTransitionStatic;
        cell.rightExpansion.buttonIndex = -1;
        cell.rightExpansion.fillOnTrigger = YES;
        cell.rightButtons = [self createRightButtons:2];
        cell.delegate = self;
    }
    
    
    static NSString *CellIdentifier = @"WishlistTableViewCell";
    
    WishlistTableViewCell *wishlistTableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (wishlistTableViewCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"WishlistTableViewCell" owner:self options:nil];
        wishlistTableViewCell = [nib objectAtIndex:0];
    }
    
    CGRect frame = wishlistTableViewCell.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = self.view.frame.size.width;
    wishlistTableViewCell.frame = frame;
    
    [wishlistTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    productList = [[ProductList alloc]init];
    productList = [arrWishList objectAtIndex:indexPath.section];


    [wishlistTableViewCell.ivImage sd_setImageWithURL:[NSURL URLWithString:([productList.arrProductImages count])?[productList.arrProductImages objectAtIndex:0]:@""] placeholderImage:[UIImage imageNamed:@"Img-Logo.png"] options:SDWebImageProgressiveDownload progress:nil completed:nil];
    wishlistTableViewCell.lblTitle.text = productList.strName;
    wishlistTableViewCell.lblPrice.text = [NSString stringWithFormat:@"%@",[appDelegate numberFormatter:productList.strPrice CurrencySymbol:appDelegate.strCurrencySymbol]];
    [wishlistTableViewCell.lblPrice sizeToFit];
    
    [wishlistTableViewCell.btnProduct addTarget:self action:@selector(btnProductPressed:) forControlEvents:UIControlEventTouchUpInside];
    [wishlistTableViewCell.btnProduct setTag:indexPath.section];
    
    if([productList.strDiscount floatValue])
    {
        for(UIView* view in [wishlistTableViewCell.viewOffer subviews])
            [view removeFromSuperview];
        
        [wishlistTableViewCell.lblPrice setText:[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",[productList.strSpecialPrice doubleValue]] CurrencySymbol:appDelegate.strCurrencySymbol]];
        [wishlistTableViewCell.lblPrice sizeToFit];
        
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
        frame.origin.y = wishlistTableViewCell.lblPrice.frame.origin.y+3;
        frame.size.width += lblDiscount.frame.size.width;
        frame.origin.x = wishlistTableViewCell.lblPrice.frame.origin.x + wishlistTableViewCell.lblPrice.frame.size.width + 5;
        frame.size.height = wishlistTableViewCell.lblPrice.frame.size.height;
        
        [wishlistTableViewCell.viewOffer setFrame:frame];
        
        [wishlistTableViewCell.viewOffer addSubview:lblPrice];
        [wishlistTableViewCell.viewOffer addSubview:lblDiscount];
        
        [wishlistTableViewCell.viewOffer setHidden:FALSE];
    }
    else
        [wishlistTableViewCell.viewOffer setHidden:TRUE];
    
    
    [cell.contentView addSubview:wishlistTableViewCell];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",[arrWishList objectAtIndex:indexPath.section]);
    
}

#pragma mark - Extra Swipe Methods -

#if TEST_USE_MG_DELEGATE

- (NSArray*)swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    swipeSettings.transition = MGSwipeTransitionStatic;
    
    if (direction == MGSwipeDirectionLeftToRight)
    {
        return nil;
    }
    else
    {
        expansionSettings.buttonIndex = -1;
        expansionSettings.fillOnTrigger = YES;
        return [self createRightButtons:2];
    }
}

#endif

- (NSArray *)createRightButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"0",@"1"};
    UIColor * colors[2] = {[UIColor colorWithRed:205.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0],[UIColor blackColor]};
//    [UIColor colorWithRed:241.0/255.0 green:58.0/255.0 blue:48.0/255.0 alpha:1.0]
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton *button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender)
                                 {
                                     //NSLog(@"Convenience callback received (right).");
                                     return YES;
                                 }];
        
        [result addObject:button];
    }
    return result;
}

- (BOOL)swipeTableCell:(MGSwipeTableCell*)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    if (direction == MGSwipeDirectionRightToLeft)
    {
        NSIndexPath *cellIndexPath = [tblWishList indexPathForCell:cell];
        
        productList = [arrWishList objectAtIndex:cellIndexPath.section];
        selectedCell = (int)cellIndexPath.section;
        
        if(index == 0)
        {
            // Delete button was pressed
            
            if([common checkInternetConnection:TRUE ViewController:self.navigationController])
            {
                [SVProgressHUD show];

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
            // Move To Cart button was pressed
            if([common checkInternetConnection:TRUE ViewController:self.navigationController])
            {
                if(![productList.arrVariants count])
                {
                    if([productList.strStockStatus intValue] == 1)
                    {
                        [SVProgressHUD show];

                        NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Order];
                        
                        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
                        NSMutableDictionary *dicOrder = [[NSMutableDictionary alloc]init];

                        NSMutableArray *arrLineItems = [[NSMutableArray alloc]init];
                        
                        NSMutableDictionary *dicLineItems = [[NSMutableDictionary alloc]init];
                        
                        [dicLineItems setObject:productList.strMasterVariantId forKey:@"variant_id"];
                        
                        [dicLineItems setObject:@"1" forKey:@"quantity"];
                        [arrLineItems addObject:dicLineItems];
                        [dicOrder setObject:arrLineItems forKey:@"line_items"];
                        
                        [dicPostData setObject:dicOrder forKey:@"order"];
                        [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
                        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
                        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
                        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
                        
                        
                        [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Order HTTPMethod:@"POST" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
                    }
                    else
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
                    }
                }
                else
                {
                    [SVProgressHUD dismiss];
                    ProductDetailViewController *productDetailViewController = [[ProductDetailViewController alloc]initWithNibName:@"ProductDetailViewController" bundle:nil];
                    productDetailViewController.strMessage = @"Please select veriant";
                    productDetailViewController.productList = productList;
                    [self.navigationController pushViewController:productDetailViewController animated:YES];
                }
            }
        }
    }
    
    return YES;
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
                    if(!arrWishList)
                    {
                        arrWishList = [[NSMutableArray alloc]init];
                        NSMutableArray *arrDetails = [[dicResponse objectForKey:@"details"]mutableCopy];

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

                            [arrWishList addObject:productList];
                        }
                    }
                    else
                    {
                        [TSMessage showNotificationInViewController:self.navigationController
                                                              title:nil//NSLocalizedString(@"Whoa!", nil)
                                                           subtitle:[dicResponse objectForKey:@"message"]
                                                              image:nil
                                                               type:TSMessageNotificationTypeSuccess
                                                           duration:TSMessageNotificationDurationAutomatic
                                                           callback:nil
                                                        buttonTitle:nil
                                                     buttonCallback:nil
                                                         atPosition:TSMessageNotificationPositionBottom
                                               canBeDismissedByUser:YES];
                        [arrWishList removeObjectAtIndex:selectedCell];
                    }
                    
                    if(![arrWishList count])
                        [tblWishList setHidden:TRUE];
                    else
                        [tblWishList setHidden:FALSE];
                    [tblWishList reloadData];

                }
                else
                {
                    if(![arrWishList count])
                        [tblWishList setHidden:TRUE];
                    
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
                [lblMessage setHidden:FALSE];
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

                    
                    [arrWishList removeObjectAtIndex:selectedCell];
                    if(![arrWishList count])
                        [tblWishList setHidden:TRUE];

                    [tblWishList reloadData];
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
