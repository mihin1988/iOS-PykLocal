    //
//  CartViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 11/09/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "CartViewController.h"
#import "ProductListViewController.h"
#import "CartlistTableViewCell.h"
#import "ProductDetailViewController.h"
#import "ProductList.h"
#import "MGSwipeButton.h"
#import "MGSwipeTableCell.h"
#import "LoginSignUpViewController.h"
#import "ReviewOrderViewController.h"


@interface CartViewController ()<MGSwipeTableCellDelegate,UITextFieldDelegate>
{
    AppDelegate *appDelegate;
    Common *common;
    BarcodeScannerViewController *barcodeScannerViewController;
    ProductList *productList;
    CartlistTableViewCell *cartListSelectedCell;
    
    NSUserDefaults *prefs;
    NSMutableArray *arrCartList;
    NSString *strOrderNumber;
    NSString *strOrderState;
    
    int selectedCell;
    
    double total;
    
    BOOL isScanned;
    BOOL isMoveToCart;
    BOOL isUpdate;
    BOOL isCheckout;
}
@end

@implementation CartViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    
    [SVProgressHUD show];
    [self getWishList];
    
    btnCheckOut.layer.cornerRadius = 5.0;
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(!isCheckout)
       [self checkoutPressed];
    else
        isCheckout = FALSE;
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
    self.navigationItem.title = @"Shopping Cart";

    UIImage *imgWish = [UIImage imageNamed:@"Img-TopWish.png"];
    UIButton *buttonWish = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonWish.frame = CGRectMake(0,0,imgWish.size.width, imgWish.size.height);
    [buttonWish addTarget:self action:@selector(btnWishListPressed:) forControlEvents:UIControlEventTouchDown];
    [buttonWish setBackgroundImage:imgWish forState:UIControlStateNormal];
    
    // Make BarButton Item
    UIBarButtonItem *btnWish = [[UIBarButtonItem alloc] initWithCustomView:buttonWish];
    //btnWish.badgeValue = strCartValue;
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnWish, nil]];
    
}

- (void)getWishList
{
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        NSString *strURL = [NSString stringWithFormat:@"%@users/%@/%@",WS_BaseUrl,[prefs objectForKey:@"token"],WS_Get_Cart];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:Get_Cart HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
    
}

- (void)setBorder:(UIButton *)btn
{
    [btn.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
    [btn.layer setBorderWidth:1.0];
    btn.layer.cornerRadius = 4;
    btn.clipsToBounds = YES;
}

-(void)setTotalPrice:(NSString *)strQTY
{
    NSString *strTotalPrice = [NSString stringWithFormat:@"%.2f",[productList.strPrice doubleValue] * [strQTY doubleValue]];
    
    if([productList.strDiscount floatValue])
        strTotalPrice = [NSString stringWithFormat:@"%.2f",[productList.strSpecialPrice doubleValue] * [strQTY doubleValue]];
        
    [cartListSelectedCell.lblTotalPrice setText:[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",[strTotalPrice doubleValue]] CurrencySymbol:appDelegate.strCurrencySymbol]];
    
    productList.strQuantity = strQTY;
    [arrCartList replaceObjectAtIndex:selectedCell withObject:productList];

    isUpdate = TRUE;
    [self manageBottomView];
}

-(void)manageBottomView
{
    if([arrCartList count])
    {
        [lblMessage setHidden:TRUE];
        [viewBottom setHidden:FALSE];
    }
    else
    {
        [lblMessage setHidden:FALSE];
        [viewBottom setHidden:TRUE];
    }
    
    [lblTotalCount setText:[NSString stringWithFormat:@"Total (%@)",appDelegate.strCartCount]];
    
    total = 0;
    for(int i = 0 ; i < [arrCartList count] ; i++)
    {
        productList = [arrCartList objectAtIndex:i];
        
        NSString *strTotalPrice = [NSString stringWithFormat:@"%.2f",[productList.strPrice doubleValue] * [productList.strQuantity doubleValue]];
        
        if([productList.strDiscount floatValue])
            strTotalPrice = [NSString stringWithFormat:@"%.2f",[productList.strSpecialPrice doubleValue] * [productList.strQuantity doubleValue]];
        
        total += [strTotalPrice doubleValue];
    }
    
    [lblTotalAmount setText:[NSString stringWithFormat:@"%@",[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",total] CurrencySymbol:appDelegate.strCurrencySymbol]]];
}

-(void)checkoutPressed
{
        [SVProgressHUD show];
        
        NSString *strURL = [NSString stringWithFormat:@"%@%@/%@",WS_BaseUrl,WS_Order,strOrderNumber];
        
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        
        NSMutableArray *arrLineItems = [[NSMutableArray alloc]init];
        
        for(int i = 0 ; i < [arrCartList count] ; i++)
        {
            productList = [arrCartList objectAtIndex:i];
            NSMutableDictionary *dicLineItems = [[NSMutableDictionary alloc]init];
            [dicLineItems setObject:productList.strLineItemId forKey:@"id"];
            [dicLineItems setObject:productList.strQuantity forKey:@"quantity"];
            [dicLineItems setObject:productList.strDeliveryType forKey:@"delivery_type"];
            [arrLineItems addObject:dicLineItems];
        }
        
        
        NSMutableDictionary *dicOrder = [[NSMutableDictionary alloc]init];
        [dicOrder setObject:arrLineItems forKey:@"line_items_attributes"];
        
        [dicPostData setObject:dicOrder forKey:@"order"];
        [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
        
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:Update_Cart HTTPMethod:@"PUT" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
}

- (void)checkLoginStatus
{
    if([[prefs objectForKey:@"is_guest"] intValue] == 1)
    {
        appDelegate.isCart = TRUE;
        
        LoginSignUpViewController *loginSignUpViewController = [[LoginSignUpViewController alloc] initWithNibName:@"LoginSignUpViewController" bundle:nil];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:loginSignUpViewController];
        navigationController.viewControllers = controllers;
    }
    else
    {
        ReviewOrderViewController *reviewOrderViewController = [[ReviewOrderViewController alloc]initWithNibName:@"ReviewOrderViewController" bundle:nil];
        reviewOrderViewController.arrCartList = arrCartList;
        reviewOrderViewController.strOrderNumber = strOrderNumber;
        [self.navigationController pushViewController:reviewOrderViewController animated:YES];
    }
}

-(void)displayErrorMessage:(NSDictionary *)dicResponse
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

-(IBAction)btnProductPressed:(UIButton *)sender
{
    NSLog(@"%ld",(long)sender.tag);
    
    productList = [arrCartList objectAtIndex:sender.tag];
    
    ProductDetailViewController *productDetailViewController = [[ProductDetailViewController alloc]initWithNibName:@"ProductDetailViewController" bundle:nil];
    productDetailViewController.strId = productList.strId;
    [self.navigationController pushViewController:productDetailViewController animated:YES];
}

-(IBAction)btnDeliveryTypePressed:(UIButton *)sender
{
    productList = [arrCartList objectAtIndex:sender.tag];
    [self getShoppingCartCell:(int)sender.tag];
    
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

- (void)getShoppingCartCell:(int)index
{
    NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    
    MGSwipeTableCell *cell = (MGSwipeTableCell *)[tblCartList cellForRowAtIndexPath:myIndexPath];
    
    selectedCell = index;
    
    for(UIView* view in cell.contentView.subviews)
    {
        if([view isKindOfClass: [CartlistTableViewCell class]])
        {
            cartListSelectedCell = (CartlistTableViewCell *)view;
            break;
        }
    }
}

-(IBAction)btnPlusPressed:(UIButton *)sender
{
    [self.view endEditing:TRUE];
    
    productList = [arrCartList objectAtIndex:sender.tag];
    [self getShoppingCartCell:(int)sender.tag];
    
    if([cartListSelectedCell.tfQty.text intValue]>=[productList.strTotalOnHand intValue])
        return;
    
    cartListSelectedCell.tfQty.text = [NSString stringWithFormat:@"%d",[cartListSelectedCell.tfQty.text intValue]+1];
    appDelegate.strCartCount = [NSString stringWithFormat:@"%d",[appDelegate.strCartCount intValue]+1];
    
    [self setTotalPrice:cartListSelectedCell.tfQty.text];
//    [self updateRecordForCart:(int)sender.tag];
}

-(IBAction)btnMinusPressed:(UIButton *)sender
{
    [self.view endEditing:TRUE];
    
    productList = [arrCartList objectAtIndex:sender.tag];
    [self getShoppingCartCell:(int)sender.tag];
    
    if([cartListSelectedCell.tfQty.text intValue]<=[productList.strMinimumQuantity intValue])
        return;
    cartListSelectedCell.tfQty.text = [NSString stringWithFormat:@"%d",[cartListSelectedCell.tfQty.text intValue] - 1];
    appDelegate.strCartCount = [NSString stringWithFormat:@"%d",[appDelegate.strCartCount intValue]-1];

    [self setTotalPrice:cartListSelectedCell.tfQty.text];
//    [self updateRecordForCart:(int)sender.tag];
}

-(IBAction)btnCheckoutPressed:(UIButton *)sender
{
    [SVProgressHUD show];

//    if([strOrderState isEqualToString:@"cart"])
//    {
//        NSString *strURL = [NSString stringWithFormat:@"%@checkouts/%@/next.json",WS_BaseUrl,strOrderNumber];
//        
//        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
//        
////            [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
//        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
//        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
//        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
//        
//        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:Next HTTPMethod:@"PUT" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
//    }
//    else // if(![strOrderState isEqualToString:@"address"])
    
    isCheckout = TRUE;
    [self checkoutPressed];
}


#pragma mark - UITable View Delegate Methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self manageBottomView];
    return arrCartList.count;
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
        cell.rightButtons = [self createRightButtons:1];
        cell.delegate = self;
    }
    
    
    static NSString *CellIdentifier = @"CartlistTableViewCell";
    
    CartlistTableViewCell *cartlistTableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cartlistTableViewCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CartlistTableViewCell" owner:self options:nil];
        cartlistTableViewCell = [nib objectAtIndex:0];
    }
    
    CGRect frame = cartlistTableViewCell.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = appDelegate.window.frame.size.width;
    cartlistTableViewCell.frame = frame;
    cell.frame = frame;
    
    [cartlistTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    productList = [[ProductList alloc]init];
    productList = [arrCartList objectAtIndex:indexPath.section];

    
    [cartlistTableViewCell.ivImage sd_setImageWithURL:[NSURL URLWithString:([productList.arrProductImages count])?[productList.arrProductImages objectAtIndex:0]:@""] placeholderImage:[UIImage imageNamed:@"Img-Logo.png"] options:SDWebImageProgressiveDownload progress:nil completed:nil];
    cartlistTableViewCell.lblTitle.text = productList.strName;
    cartlistTableViewCell.lblPrice.text = [NSString stringWithFormat:@"%@",[appDelegate numberFormatter:productList.strPrice CurrencySymbol:appDelegate.strCurrencySymbol]];
    [cartlistTableViewCell.lblPrice sizeToFit];
    cartlistTableViewCell.lblOptionName.text = productList.strOptionName;
    
    NSString *strDeliveryType = [productList.strDeliveryType isEqualToString:@"home_delivery"]?@"Home Delivery":@"Pickup";
    
    [cartlistTableViewCell.btnDeliveryType setTitle:strDeliveryType forState:UIControlStateNormal];
    
    [cartlistTableViewCell.btnDeliveryType addTarget:self action:@selector(btnDeliveryTypePressed:) forControlEvents:UIControlEventTouchUpInside];
    [cartlistTableViewCell.btnDeliveryType setTag:indexPath.section];
    
    [cartlistTableViewCell.btnProduct addTarget:self action:@selector(btnProductPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cartlistTableViewCell.btnProduct setTag:indexPath.section];
    
    [self setBorder:cartlistTableViewCell.btnMinus];
    [self setBorder:cartlistTableViewCell.btnQty];
    [self setBorder:cartlistTableViewCell.btnPlus];
    
    [cartlistTableViewCell.btnMinus setTag:indexPath.section];
    [cartlistTableViewCell.btnPlus setTag:indexPath.section];
    [cartlistTableViewCell.tfQty setTag:indexPath.section];
    
    [cartlistTableViewCell.btnMinus addTarget:self action:@selector(btnMinusPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cartlistTableViewCell.btnPlus addTarget:self action:@selector(btnPlusPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cartlistTableViewCell setTag:indexPath.section];
    
    [cartlistTableViewCell.tfQty setText:productList.strQuantity];
    [cartlistTableViewCell.tfQty setDelegate:self];
    
    NSString *strTotalPrice = [NSString stringWithFormat:@"%.2f",[productList.strPrice doubleValue] * [productList.strQuantity doubleValue]];
    
    if([productList.strDiscount floatValue])
    {
        for(UIView* view in [cartlistTableViewCell.viewOffer subviews])
        [view removeFromSuperview];
        
        strTotalPrice = [NSString stringWithFormat:@"%.2f",[productList.strSpecialPrice doubleValue] * [productList.strQuantity doubleValue]];
        
        [cartlistTableViewCell.lblPrice setText:[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",[productList.strSpecialPrice doubleValue]] CurrencySymbol:appDelegate.strCurrencySymbol]];
        [cartlistTableViewCell.lblPrice sizeToFit];
        
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
        
        if([productList.strDiscount doubleValue] - [productList.strDiscount intValue] == 0)
        [lblDiscount setText:[NSString stringWithFormat:@"%d%% OFF",[productList.strDiscount intValue]]];
        else
        [lblDiscount setText:[NSString stringWithFormat:@"%.2f%% OFF",[productList.strDiscount doubleValue]]];
        [lblDiscount sizeToFit];
        
        
        
        CGRect frame = lblPrice.frame;
        frame.origin.y = cartlistTableViewCell.lblPrice.frame.origin.y+3;
        frame.size.width += lblDiscount.frame.size.width;
        frame.origin.x = cartlistTableViewCell.lblPrice.frame.origin.x + cartlistTableViewCell.lblPrice.frame.size.width + 5;
        frame.size.height = cartlistTableViewCell.lblPrice.frame.size.height;
        
        [cartlistTableViewCell.viewOffer setFrame:frame];
        
        [cartlistTableViewCell.viewOffer addSubview:lblPrice];
        [cartlistTableViewCell.viewOffer addSubview:lblDiscount];
        
        [cartlistTableViewCell.viewOffer setHidden:FALSE];
    }
    else
    {

        [cartlistTableViewCell.viewOffer setHidden:TRUE];
    }
    
    [cartlistTableViewCell.lblTotalPrice setText:[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",[strTotalPrice doubleValue]] CurrencySymbol:appDelegate.strCurrencySymbol]];
    
    [cell.contentView addSubview:cartlistTableViewCell];
    cell.contentView.frame = frame;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",[arrCartList objectAtIndex:indexPath.section]);
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
        return [self createRightButtons:1];
    }
}

#endif

- (NSArray *)createRightButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"0"};
    UIColor * colors[2] = {[UIColor colorWithRed:205.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]};
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
        NSIndexPath *cellIndexPath = [tblCartList indexPathForCell:cell];
        
        productList = [arrCartList objectAtIndex:cellIndexPath.section];
        selectedCell = (int)cellIndexPath.section;
        [SVProgressHUD show];
        
        if(index == 0)
        {
            // Delete button was pressed
            
            if([common checkInternetConnection:TRUE ViewController:self.navigationController])
            {
                NSString *strURL = [NSString stringWithFormat:@"%@%@/%@/line_items/%@",WS_BaseUrl,WS_Order,strOrderNumber,productList.strLineItemId];

                
                NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
                [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
                [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
                [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
                
                
                [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Delete_Cart HTTPMethod:@"DELETE" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
            }
        }
        else
        {
            // Move To Cart button was pressed
            if([common checkInternetConnection:TRUE ViewController:self.navigationController])
            {
                if(![productList.arrVariants count])
                {
                    NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Order];
                    
                    NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
                    NSMutableDictionary *dicOrder = [[NSMutableDictionary alloc]init];
                    
                    NSMutableArray *arrLineItems = [[NSMutableArray alloc]init];
                    
                    NSMutableDictionary *dicLineItems = [[NSMutableDictionary alloc]init];
                    if(![productList.arrVariants count])
                    [dicLineItems setObject:productList.strId forKey:@"variant_id"];
                    else
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

#pragma mark - UIAlertView Delegate Methods -

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1 )
    {
        if(buttonIndex != 0)
        {
            if(buttonIndex == 1)
                productList.strDeliveryType = @"home_delivery";
            else if(buttonIndex == 2)
                productList.strDeliveryType = @"pickup";
            
            isUpdate = TRUE;
            [arrCartList replaceObjectAtIndex:selectedCell withObject:productList];
            [tblCartList reloadData];
        }
    }
}

#pragma mark - UITextField Delegate Methods -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    productList = [arrCartList objectAtIndex:textField.tag];
    [self getShoppingCartCell:(int)textField.tag];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(textField == cartListSelectedCell.tfQty)
    {
        cartListSelectedCell.tfQty.text = [NSString stringWithFormat:@"%d",[textField.text intValue]];
        
        if([textField.text intValue]>[productList.strTotalOnHand intValue])
        {
            cartListSelectedCell.tfQty.text = productList.strTotalOnHand;
        }
        
        if([textField.text intValue]<[productList.strMinimumQuantity intValue])
        {
            cartListSelectedCell.tfQty.text = productList.strMinimumQuantity;
        }
    }
    
    [self setTotalPrice:cartListSelectedCell.tfQty.text];
//    [self updateRecordForCart:(int)textField.tag];
    
    return TRUE;
}

#pragma mark - WebAPI Response -

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther
{
    switch (tag)
    {
        case 17:
        //Get_Cart
        
            [SVProgressHUD dismiss];
        
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    
                    arrCartList = [[NSMutableArray alloc]init];
                    NSMutableArray *arrDetails = [[dicResponse objectForKey:@"details"]mutableCopy];
                    strOrderNumber = [dicResponse objectForKey:@"order_number"];
                    appDelegate.strOrderToken = [dicResponse objectForKey:@"order_token"];
                    strOrderState = [dicResponse objectForKey:@"order_state"];
                    
                    for(int i = 0 ; i<[arrDetails count] ; i++)
                    {
                        NSMutableDictionary *dicaDetails = [[arrDetails objectAtIndex:i]mutableCopy];
                        
                        productList = [[ProductList alloc]init];
                        
                        productList.strId = [dicaDetails objectForKey:@"product_id"];
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
                        productList.strName = [dicaDetails objectForKey:@"product_name"];
                        productList.strSpecialPrice = [dicaDetails objectForKey:@"special_price"];
                        productList.arrProductImages = [dicaDetails objectForKey:@"product_images"];
                        productList.arrVariants = [dicaDetails objectForKey:@"variants"];
                        productList.strMasterVariantId = [dicaDetails objectForKey:@"master_variant_id"];
                        productList.strStoreId = [dicaDetails objectForKey:@"store_id"];
                        productList.strStoreAddress = [dicaDetails objectForKey:@"store_address"];
                        productList.strStoreName = [dicaDetails objectForKey:@"store_name"];
                        productList.strOptionName = [dicaDetails objectForKey:@"option_name"];
                        productList.strDeliveryType = [dicaDetails objectForKey:@"delivery_type"];
                        productList.strQuantity = [dicaDetails objectForKey:@"quantity"];
                        productList.strLineItemId = [dicaDetails objectForKey:@"line_item_id"];
                        productList.strProductShareLink = [dicaDetails objectForKey:@"product_share_link"];
                        
                        [arrCartList addObject:productList];
                    }
                    
                    if(![arrDetails count])
                        [tblCartList setHidden:TRUE];
                    else
                        [tblCartList setHidden:FALSE];
                    
                    [tblCartList reloadData];
                    
                    if(appDelegate.isCart)
                    {
                        appDelegate.isCart = FALSE;
//                        [self checkLoginStatus];
                    }
                }
                else
                {
                    [tblCartList setHidden:TRUE];
                    [self displayErrorMessage:dicResponse];
                }
                [lblMessage setHidden:FALSE];
            }
            break;
        
        case 18:
        //Delete_Cart
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    appDelegate.strCartCount = [dicResponse objectForKey:@"cart_count"];

                    [arrCartList removeObjectAtIndex:selectedCell];
                    [tblCartList reloadData];
                    if(![arrCartList count])
                    {
                        [tblCartList setHidden:TRUE];
                        appDelegate.strCartCount = @"0";
                    }
                    else
                        appDelegate.strCartCount = [NSString stringWithFormat:@"%d",[appDelegate.strCartCount intValue]-1];
                    
                    [self setNavigationBar:appDelegate.strCartCount];
                }
                else
                {
                    if(![arrCartList count])
                        [tblCartList setHidden:TRUE];
                    
                    [self displayErrorMessage:dicResponse];
                }
                [lblMessage setHidden:FALSE];
            }
            break;
            
        case 15:
            //Update_Cart
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    appDelegate.strCartCount = [dicResponse objectForKey:@"cart_count"];
                    [self setNavigationBar:appDelegate.strCartCount];
                    
                    arrCartList = [[NSMutableArray alloc]init];
                    NSMutableArray *arrDetails = [[dicResponse objectForKey:@"details"]mutableCopy];
                    
                    for(int i = 0 ; i<[arrDetails count] ; i++)
                    {
                        NSMutableDictionary *dicaDetails = [[arrDetails objectAtIndex:i]mutableCopy];
                        
                        productList = [[ProductList alloc]init];
                        
                        productList.strId = [dicaDetails objectForKey:@"product_id"];
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
                        productList.strName = [dicaDetails objectForKey:@"product_name"];
                        productList.strSpecialPrice = [dicaDetails objectForKey:@"special_price"];
                        productList.arrProductImages = [dicaDetails objectForKey:@"product_images"];
                        productList.arrVariants = [dicaDetails objectForKey:@"variants"];
                        productList.strMasterVariantId = [dicaDetails objectForKey:@"master_variant_id"];
                        productList.strStoreId = [dicaDetails objectForKey:@"store_id"];
                        productList.strStoreAddress = [dicaDetails objectForKey:@"store_address"];
                        productList.strStoreName = [dicaDetails objectForKey:@"store_name"];
                        productList.strOptionName = [dicaDetails objectForKey:@"option_name"];
                        productList.strDeliveryType = [dicaDetails objectForKey:@"delivery_type"];
                        productList.strQuantity = [dicaDetails objectForKey:@"quantity"];
                        productList.strLineItemId = [dicaDetails objectForKey:@"line_item_id"];
                        productList.strProductShareLink = [dicaDetails objectForKey:@"product_share_link"];
                        
                        [arrCartList addObject:productList];
                    }
                    
                    if(![arrDetails count])
                        [tblCartList setHidden:TRUE];
                    else
                        [tblCartList setHidden:FALSE];
                    
                    [tblCartList reloadData];

                    
                    if(isCheckout)
                        [self checkLoginStatus];
                }
                else
                    [self displayErrorMessage:dicResponse];
            }
            break;
    
        case 22:
            //Next
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    strOrderState = [dicResponse objectForKey:@"order_state"];

                    appDelegate.strCartCount = [dicResponse objectForKey:@"cart_count"];
                    [self setNavigationBar:appDelegate.strCartCount];
                    [self btnCheckoutPressed:nil];
                }
                else
                    [self displayErrorMessage:dicResponse];
            }
            break;
            
        default:
            break;
        
    }
}
@end
