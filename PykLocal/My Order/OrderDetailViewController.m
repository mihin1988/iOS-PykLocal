//
//  OrderDetailViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 06/01/17.
//  Copyright © 2017 Mihin  Patel. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "AddressList.h"
#import "CartlistTableViewCell.h"
#import "ProductList.h"

@interface OrderDetailViewController ()
{
    AppDelegate *appDelegate;
    Common *common;
    AddressList *billingAddress;
    AddressList *shippingAddress;
    ProductList *productList;
    
    NSUserDefaults *prefs;
    NSMutableArray *arrCartList;
}
@end

@implementation OrderDetailViewController
@synthesize dicOrderDetails;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    arrCartList = [[NSMutableArray alloc]init];
    
    [lblDate setText:[dicOrderDetails objectForKey:@"order_date"]];
    [lblNumber setText:[dicOrderDetails objectForKey:@"order_number"]];
    [lblTotal setText:[NSString stringWithFormat:@"%@",[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",([[[[dicOrderDetails objectForKey:@"adjustments"] objectAtIndex:0] objectForKey:@"subtotal"] doubleValue])] CurrencySymbol:appDelegate.strCurrencySymbol]]];
    
    [btnReturn.layer setBorderColor:[[RGB colorWithAlphaComponent:1.0] CGColor]];
    [btnReturn.layer setBorderWidth:0.5];
    btnReturn.layer.cornerRadius = 5;
    btnReturn.clipsToBounds = YES;
    
    [btnCancel.layer setBorderColor:[[RGB colorWithAlphaComponent:1.0] CGColor]];
    [btnCancel.layer setBorderWidth:0.5];
    btnCancel.layer.cornerRadius = 5;
    btnCancel.clipsToBounds = YES;
    
    if([[dicOrderDetails objectForKey:@"shipment"] length])
        [lblShipments setText:[dicOrderDetails objectForKey:@"shipment"]];
    else
    {
        [viewShipments setHidden:TRUE];
        CGRect frame = svContainer.frame;
        frame.origin.y -=69;
        frame.size.height += 69;
        svContainer.frame = frame;
    }
    [lblPaymentInformation setText:[dicOrderDetails objectForKey:@"payment"]];
    
    if([[dicOrderDetails objectForKey:@"shipped"] intValue] == 2)
        [btnCancel setHidden:TRUE];
    
    NSMutableDictionary *dicBillingAddress = [dicOrderDetails objectForKey:@"bill_address"];
    billingAddress = [[AddressList alloc]init];
    
    billingAddress.strPhone = [dicBillingAddress objectForKey:@"phone"];
    billingAddress.strFirstName = [dicBillingAddress objectForKey:@"firstname"];
    billingAddress.strLastName = [dicBillingAddress objectForKey:@"lastname"];
    billingAddress.strAddress1 = [dicBillingAddress objectForKey:@"address1"];
    billingAddress.strAddress2 = [dicBillingAddress objectForKey:@"address2"];
    billingAddress.strCountryId = [dicBillingAddress objectForKey:@"country_id"];
    billingAddress.strCountryName = [[dicBillingAddress objectForKey:@"country"] objectForKey:@"name"];
    billingAddress.strStateId = [dicBillingAddress objectForKey:@"state_id"];
    billingAddress.strStateName = [[dicBillingAddress objectForKey:@"state"] objectForKey:@"name"];
    billingAddress.strCity = [dicBillingAddress objectForKey:@"city"];
    billingAddress.strZipcode = [dicBillingAddress objectForKey:@"zipcode"];
    
    
    [lblBillingName setText:[NSString stringWithFormat:@"%@ %@",billingAddress.strFirstName,billingAddress.strLastName]];
    [btnBillingPhone setTitle:billingAddress.strPhone forState:UIControlStateNormal];
    
    btnBillingAddress.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [btnBillingAddress setTitle:[NSString stringWithFormat:@"%@, %@\n%@, %@, %@ - %@",billingAddress.strAddress1,billingAddress.strAddress1,billingAddress.strCountryName,billingAddress.strStateName,billingAddress.strCity,billingAddress.strZipcode] forState:UIControlStateNormal];

    
    NSMutableDictionary *dicShippingAddress = [dicOrderDetails objectForKey:@"shipping_address"];
    shippingAddress = [[AddressList alloc]init];
    
    shippingAddress.strPhone = [dicShippingAddress objectForKey:@"phone"];
    shippingAddress.strFirstName = [dicShippingAddress objectForKey:@"firstname"];
    shippingAddress.strLastName = [dicShippingAddress objectForKey:@"lastname"];
    shippingAddress.strAddress1 = [dicShippingAddress objectForKey:@"address1"];
    shippingAddress.strAddress2 = [dicShippingAddress objectForKey:@"address2"];
    shippingAddress.strCountryId = [dicShippingAddress objectForKey:@"country_id"];
    shippingAddress.strCountryName = [[dicShippingAddress objectForKey:@"country"] objectForKey:@"name"];
    shippingAddress.strStateId = [dicShippingAddress objectForKey:@"state_id"];
    shippingAddress.strStateName = [[dicShippingAddress objectForKey:@"state"] objectForKey:@"name"];
    shippingAddress.strCity = [dicShippingAddress objectForKey:@"city"];
    shippingAddress.strZipcode = [dicShippingAddress objectForKey:@"zipcode"];
    
    [lblShippingName setText:[NSString stringWithFormat:@"%@ %@",shippingAddress.strFirstName,shippingAddress.strLastName]];
    [btnShippingPhone setTitle:shippingAddress.strPhone forState:UIControlStateNormal];
    
    btnShippingAddress.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [btnShippingAddress setTitle:[NSString stringWithFormat:@"%@, %@\n%@, %@, %@ - %@",shippingAddress.strAddress1,shippingAddress.strAddress1,shippingAddress.strCountryName,shippingAddress.strStateName,shippingAddress.strCity,shippingAddress.strZipcode] forState:UIControlStateNormal];
    
    [btnAddBillingAddress.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
    [btnAddBillingAddress.layer setBorderWidth:1.0];
    btnAddBillingAddress.layer.cornerRadius = 4;
    btnAddBillingAddress.clipsToBounds = YES;
    
    [btnAddShippingAddress.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
    [btnAddShippingAddress.layer setBorderWidth:1.0];
    btnAddShippingAddress.layer.cornerRadius = 4;
    btnAddShippingAddress.clipsToBounds = YES;

    for(int i = 0 ; i<[[dicOrderDetails objectForKey:@"line_items"] count] ; i++)
    {
        NSMutableDictionary *dicaDetails = [[[dicOrderDetails objectForKey:@"line_items"] objectAtIndex:i]mutableCopy];
        
        productList = [[ProductList alloc]init];
        
        productList.strId = [dicaDetails objectForKey:@"id"];
        productList.strLineItemId = [dicaDetails objectForKey:@"product_id"];
        productList.strPrice = [dicaDetails objectForKey:@"price"];
        productList.strName = [dicaDetails objectForKey:@"product_name"];
        productList.arrProductImages = [dicaDetails objectForKey:@"images"];
        productList.strMasterVariantId = [dicaDetails objectForKey:@"variant_id"];
        productList.strStoreId = [dicaDetails objectForKey:@"store_id"];
        productList.strStoreAddress = [dicaDetails objectForKey:@"store_address"];
        productList.strStoreName = [dicaDetails objectForKey:@"store_name"];
        productList.strOptionName = [dicaDetails objectForKey:@"option_name"];
        productList.strDeliveryType = [dicaDetails objectForKey:@"delivery_type"];
        productList.strQuantity = [dicaDetails objectForKey:@"quantity"];
        
        [arrCartList addObject:productList];
    }
    
    CGRect frame = tblCartList.frame;
    frame.size.height = [arrCartList count] * 145;
    tblCartList.frame = frame;
    
    [lblCartList setFrame:frame];
    [lblCartList.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
    [lblCartList.layer setBorderWidth:1.0];
    lblCartList.layer.cornerRadius = 4;
    lblCartList.clipsToBounds = YES;
    
    [svContainer setAutoresizesSubviews:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //Mange Slider
    appDelegate.isHandlePan = FALSE;
    
    //Mange NavigationBar With Cart Count
    [self setNavigationBar:appDelegate.strCartCount];
    
    [viewPrice.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
    [viewPrice.layer setBorderWidth:1.0];
    viewPrice.layer.cornerRadius = 4;
    viewPrice.clipsToBounds = YES;
    
    [viewPrice setFrame:CGRectMake(viewPrice.frame.origin.x, tblCartList.frame.origin.y+tblCartList.frame.size.height+20, viewPrice.frame.size.width, viewPrice.frame.size.height)];
    
    [self managePriceView:[[dicOrderDetails objectForKey:@"adjustments"] objectAtIndex:0]];

    [svContainer setContentSize:CGSizeMake(svContainer.frame.size.width, (viewPrice.frame.origin.y + viewPrice.frame.size.height)+20)];

}

- (void)viewDidLayoutSubviews
{
    [self managePriceView:[[dicOrderDetails objectForKey:@"adjustments"] objectAtIndex:0]];
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
    
    self.navigationItem.title = @"Order Details";
}

-(void)managePriceView:(NSMutableDictionary *)dicadjustments
{
    for(UIView* view in [viewPrice subviews])
    {
        if(view.tag != 100 && view.tag != 200 )
            [view removeFromSuperview];
    }
    
    [lblSubTotal setText:[NSString stringWithFormat:@"%@",[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",([[dicadjustments objectForKey:@"subtotal"] doubleValue])-([[dicadjustments objectForKey:@"adjustment_total"] doubleValue])] CurrencySymbol:appDelegate.strCurrencySymbol]]];
    
    
    CGRect frameTitle = lblSubTotalTitle.frame;
    frameTitle.origin.y +=20;
    CGRect framePrice = lblSubTotal.frame;
    framePrice.origin.y +=20;
    
    if([[dicadjustments objectForKey:@"shipping"] isKindOfClass:[NSDictionary class]])
    {
        if([[[dicadjustments objectForKey:@"shipping"] allKeys] count])
        {
            UILabel *lblTile = [self createUILable:frameTitle];
            [lblTile setText:[[dicadjustments objectForKey:@"shipping"] objectForKey:@"title"]];
            [viewPrice addSubview:lblTile];
            
            UILabel *lblPrice = [self createUILable:framePrice];
            [lblPrice setTextAlignment:NSTextAlignmentRight];
            [lblPrice setText:[NSString stringWithFormat:@"%@",[appDelegate numberFormatter:[[dicadjustments objectForKey:@"shipping"] objectForKey:@"value"] CurrencySymbol:appDelegate.strCurrencySymbol]]];
            [viewPrice addSubview:lblPrice];
            
            frameTitle = lblTile.frame;
            frameTitle.origin.y +=20;
            framePrice = lblPrice.frame;
            framePrice.origin.y +=20;
        }
    }
    
    if([[dicadjustments objectForKey:@"tax"] count])
    {
        for(int i = 0 ; i < [[dicadjustments objectForKey:@"tax"] count] ; i++)
        {
            NSMutableDictionary *dicTax = [[dicadjustments objectForKey:@"tax"] objectAtIndex:i];
            
            UILabel *lblTile = [self createUILable:frameTitle];
            [lblTile setText:[dicTax objectForKey:@"title"]];
            [viewPrice addSubview:lblTile];
            
            UILabel *lblPrice = [self createUILable:framePrice];
            [lblPrice setTextAlignment:NSTextAlignmentRight];
            [lblPrice setText:[NSString stringWithFormat:@"%@",[appDelegate numberFormatter:[dicTax objectForKey:@"value"] CurrencySymbol:appDelegate.strCurrencySymbol]]];
            [viewPrice addSubview:lblPrice];
            
            frameTitle = lblTile.frame;
            frameTitle.origin.y +=20;
            framePrice = lblPrice.frame;
            framePrice.origin.y +=20;
        }
        
    }
    
    if([[dicadjustments objectForKey:@"discount"] count])
    {
        for(int i = 0 ; i < [[dicadjustments objectForKey:@"discount"] count] ; i++)
        {
            NSMutableDictionary *dicTax = [[dicadjustments objectForKey:@"discount"] objectAtIndex:i];
            
            UILabel *lblTile = [self createUILable:frameTitle];
            [lblTile setText:[dicTax objectForKey:@"title"]];
            [viewPrice addSubview:lblTile];
            
            UILabel *lblPrice = [self createUILable:framePrice];
            [lblPrice setTextAlignment:NSTextAlignmentRight];
            [lblPrice setText:[NSString stringWithFormat:@"%@",[appDelegate numberFormatter:[dicTax objectForKey:@"value"] CurrencySymbol:appDelegate.strCurrencySymbol]]];
            [viewPrice addSubview:lblPrice];
            
            frameTitle = lblTile.frame;
            frameTitle.origin.y +=20;
            framePrice = lblPrice.frame;
            framePrice.origin.y +=20;
        }
    }
    frameTitle.origin.y +=10;
    framePrice.origin.y +=10;
    
    
    [viewPrice setFrame:CGRectMake(viewPrice.frame.origin.x, viewPrice.frame.origin.y, viewPrice.frame.size.width, frameTitle.origin.y)];
    
}

-(UILabel *)createUILable:(CGRect)frameOfLable
{
    UILabel *lbl = [[UILabel alloc]initWithFrame:frameOfLable];
    [lbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
    [lbl setTextColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
    return lbl;
}

#pragma mark - UITable View Delegate Methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrCartList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
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
    frame.size.width = tblCartList.frame.size.width;
    cartlistTableViewCell.frame = frame;
    
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
    CGRect framebtn  = cartlistTableViewCell.btnDeliveryType.frame;
    framebtn.size.width = 400;
    cartlistTableViewCell.btnDeliveryType.frame = framebtn;
    
    [cartlistTableViewCell.btnDeliveryType setTag:indexPath.section];
    
    CGRect frameBtnMore = cartlistTableViewCell.btnMore.frame;
    frameBtnMore.origin.y = cartlistTableViewCell.btnDeliveryType.frame.origin.y;
    cartlistTableViewCell.btnMore.frame = frameBtnMore;
    
    if([strDeliveryType isEqualToString:@"Pickup"])
    {
        [cartlistTableViewCell.btnDeliveryType setEnabled:TRUE];
        [cartlistTableViewCell.btnMore setHidden:FALSE];
        [cartlistTableViewCell.btnDeliveryType addTarget:self action:@selector(btnDeliveryTypePressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [cartlistTableViewCell.btnDeliveryType setEnabled:FALSE];
        [cartlistTableViewCell.btnMore setHidden:TRUE];
    }
    
    //    [cartlistTableViewCell.btnProduct addTarget:self action:@selector(btnProductPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cartlistTableViewCell.btnProduct setTag:indexPath.section];
    
    [cartlistTableViewCell.btnMinus setHidden:TRUE];
    [cartlistTableViewCell.btnQty setHidden:TRUE];
    [cartlistTableViewCell.btnPlus setHidden:TRUE];
    [cartlistTableViewCell.lblQty setHidden:FALSE];
    [cartlistTableViewCell.tfQty setUserInteractionEnabled:FALSE];
    
    [cartlistTableViewCell setTag:indexPath.section];
    
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
    
    [cartlistTableViewCell setBackgroundColor:[UIColor clearColor]];

    return cartlistTableViewCell;
    
}

#pragma mark - IBAction Method -


-(IBAction)btnDeliveryTypePressed:(UIButton *)sender
{
    productList = [arrCartList objectAtIndex:sender.tag];
    
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Pickup From : %@",productList.strStoreName]
                                                 message:[NSString stringWithFormat:@"%@",productList.strStoreAddress]
                                                delegate:self
                                       cancelButtonTitle:nil
                                       otherButtonTitles:@"Ok",nil];
    [alert setTag:1];
    [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertView class]]] setTintColor:RGB];
    [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]] setTintColor:RGB];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}


-(IBAction)btnCancelPressed:(UIButton *)sender
{
    [SVProgressHUD show];
    
    NSString *strURL = [NSString stringWithFormat:@"%@%@/%@/cancel",WS_BaseUrl,WS_Order,lblNumber.text];
    

    NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
    

    [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
    
    [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
    [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
    [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
    
    [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:CancelOrders HTTPMethod:@"PUT" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
}

#pragma mark - WebAPI Response -

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther
{
    switch (tag)
    {
        case 35:
            //CancelOrders
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    [btnCancel setHidden:TRUE];
                    [dicOrderDetails setObject:@"2" forKey:@"shipped"];
                    [_delegate cancelOrder:dicOrderDetails];
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
                }
                else{
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
