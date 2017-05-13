//
//  ReviewOrderViewController.m
//  PykLocal
//
//  Created by Saket Singhi on 20/12/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "ReviewOrderViewController.h"
#import "AddressList.h"
#import "AddressViewController.h"
#import "ProductList.h"
#import "CartlistTableViewCell.h"
#import "MGSwipeTableCell.h"
#import "PaymentViewController.h"

#import "CardIO.h"
#import "ThankYouViewController.h"

#import "BraintreeCore.h"
#import "BraintreeDropIn.h"

@interface ReviewOrderViewController ()<AddressViewDelegate,MGSwipeTableCellDelegate,CardIOPaymentViewControllerDelegate>
{
    AppDelegate *appDelegate;
    Common *common;
    AddressList *billingAddress;
    AddressList *shippingAddress;
    ProductList *productList;
    CardIOCreditCardInfo *cardIOCreditCardInfo;

    NSUserDefaults *prefs;
    NSString *strOrderState;
    NSString *strShipmentMinimumPrice;
    NSString *strClientToken;
    NSMutableDictionary *dicAdjustments;
    
    double total;
    
    BOOL isUse;
    BOOL isBillingAddress;
    BOOL isLoad;
    
}
@end

@implementation ReviewOrderViewController
@synthesize arrCartList;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    billingAddress = [[AddressList alloc]init];
    shippingAddress = [[AddressList alloc]init];
    
    isUse = TRUE;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"strDeliveryType LIKE[c] %@",@"home_delivery"];
    NSMutableArray *arrFilterdData = [[arrCartList filteredArrayUsingPredicate:predicate] mutableCopy];
    if([arrFilterdData count])
        [btnUse setHidden:FALSE];
    else
        [btnUse setHidden:TRUE];
    
    
    [BTAppSwitch setReturnURLScheme:@"com.AppMasonStudiosInc.PykLocal.payments"];

    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        [SVProgressHUD show];
        
        NSString *strURL = [NSString stringWithFormat:@"%@checkouts/%@/next.json",WS_BaseUrl,_strOrderNumber];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        
        //            [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:Next HTTPMethod:@"PUT" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
    
    [svContainer setAutoresizesSubviews:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Mange Slider
    appDelegate.isHandlePan = FALSE;
    
    //Mange NavigationBar With Cart Count
    [self setNavigationBar:appDelegate.strCartCount];
    
    [CardIOUtilities preload];

    [lblCartList.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
    [lblCartList.layer setBorderWidth:1.0];
    lblCartList.layer.cornerRadius = 4;
    lblCartList.clipsToBounds = YES;
    
    [btnAddBillingAddress.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
    [btnAddBillingAddress.layer setBorderWidth:1.0];
    btnAddBillingAddress.layer.cornerRadius = 4;
    btnAddBillingAddress.clipsToBounds = YES;
    
    [btnAddShippingAddress.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
    [btnAddShippingAddress.layer setBorderWidth:1.0];
    btnAddShippingAddress.layer.cornerRadius = 4;
    btnAddShippingAddress.clipsToBounds = YES;
    
    [tfCouponCode.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
    [tfCouponCode.layer setBorderWidth:1.0];
    tfCouponCode.layer.cornerRadius = 4;
    tfCouponCode.clipsToBounds = YES;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    tfCouponCode.leftView = paddingView;
    tfCouponCode.leftViewMode = UITextFieldViewModeAlways;
    
    [viewPrice.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
    [viewPrice.layer setBorderWidth:1.0];
    viewPrice.layer.cornerRadius = 4;
    viewPrice.clipsToBounds = YES;
    
    btnCheckOut.layer.cornerRadius = 5.0;
    
    if(!isLoad)
    {
        CGRect frame = tblCartList.frame;
        frame.size.height = [arrCartList count] * 145;
        tblCartList.frame = frame;
        
        [lblCartList setFrame:frame];
        CGRect frameViewPriceCouponCode = viewPriceCouponCode.frame;
        frameViewPriceCouponCode.origin.y = lblCartList.frame.origin.y + lblCartList.frame.size.height;
        viewPriceCouponCode.frame = frameViewPriceCouponCode;
        
        frame = viewShoppingCart.frame;
        frame.size.height = lblCartList.frame.size.height + viewPriceCouponCode.frame.size.height + 40;
        viewShoppingCart.frame = frame;
        
        [svContainer setContentSize:CGSizeMake(svContainer.frame.size.width, (viewShoppingCart.frame.origin.y + viewShoppingCart.frame.size.height))];
        isLoad = TRUE;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Method -

-(IBAction)btnUsePressed:(UIButton *)sender
{
    CGRect frame = viewShippingAddress.frame;
    
    CGRect frameViewShoppingCart = viewShoppingCart.frame;
    
    if(isUse)
    {
        [viewShippingAddress setHidden:FALSE];
        
        frame.origin.y = 169;
        frameViewShoppingCart.origin.y = 318;
        
        [UIView animateWithDuration:0.3 animations:^{
            [viewShippingAddress setFrame:frame];
            [viewShoppingCart setFrame:frameViewShoppingCart];
            
            [viewShippingAddress setAlpha:1];
        }completion:^(BOOL finished) {
            //            [sender setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [sender setImage:[UIImage imageNamed:@"Img-Unselected.png"] forState:UIControlStateNormal];
            isUse = FALSE;
            [svContainer setContentSize:CGSizeMake(svContainer.frame.size.width, (viewShoppingCart.frame.origin.y + viewShoppingCart.frame.size.height))];
        }];
    }
    else
    {
        frame.origin.y = 0;
        frameViewShoppingCart.origin.y = 174;
        
        [UIView animateWithDuration:0.3 animations:^{
            [viewShippingAddress setFrame:frame];
            [viewShoppingCart setFrame:frameViewShoppingCart];
            
            [viewShippingAddress setAlpha:0];
        }completion:^(BOOL finished) {
            //            [sender setTitleColor:RGB forState:UIControlStateNormal];
            [sender setImage:[UIImage imageNamed:@"Img-Selected.png"] forState:UIControlStateNormal];
            
            [viewShippingAddress setHidden:TRUE];
            isUse = TRUE;
            [svContainer setContentSize:CGSizeMake(svContainer.frame.size.width, (viewShoppingCart.frame.origin.y + viewShoppingCart.frame.size.height))];
        }];
    }
    
}

-(IBAction)btnAddBillingAddressPressed:(UIButton *)sender
{
    isBillingAddress = TRUE;
    AddressViewController *addressViewController = [[AddressViewController alloc]initWithNibName:@"AddressViewController" bundle:nil];
    [addressViewController setDelegate:self];
    addressViewController.addressList = billingAddress;
    addressViewController.strTitle = @"Billing Address";
    [self.navigationController pushViewController:addressViewController animated:YES];
}

-(IBAction)btnAddShippingAddressPressed:(UIButton *)sender
{
    isBillingAddress = FALSE;
    AddressViewController *addressViewController = [[AddressViewController alloc]initWithNibName:@"AddressViewController" bundle:nil];
    [addressViewController setDelegate:self];
    addressViewController.addressList = shippingAddress;
    addressViewController.strTitle = @"Shipping Address";
    [self.navigationController pushViewController:addressViewController animated:YES];
}

-(IBAction)btnProceedToPayPressed:(UIButton *)sender
{
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        [SVProgressHUD show];
        
        NSString *strURL = [NSString stringWithFormat:@"%@checkouts/%@/next.json",WS_BaseUrl,_strOrderNumber];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        
        //        [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
        [dicPostData setObject:strOrderState forKey:@"order_state"];
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:DeliveryToPayment HTTPMethod:@"PUT" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
    
}

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

-(IBAction)btnApplyPressed:(UIButton *)sender
{
    [self.view endEditing:TRUE];
}

#pragma mark - Helper Method -

- (void)setNavigationBar:(NSString *)strCartValue
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController setNavigationBarHidden:FALSE];
    self.navigationItem.title = @"Review Order";
    
}

- (void)getAddress
{
    
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        [SVProgressHUD show];
        
        NSString *strURL = [NSString stringWithFormat:@"%@user_addresses/%@",WS_BaseUrl,[prefs objectForKey:@"token"]];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:User_Addresses HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
    
}


-(void)manageBottomView
{
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
    
    [lblSubTotal setText:[NSString stringWithFormat:@"%@",[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",total] CurrencySymbol:appDelegate.strCurrencySymbol]]];
    [lblTotalAmount setText:[NSString stringWithFormat:@"%@",[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",total] CurrencySymbol:appDelegate.strCurrencySymbol]]];
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

-(void)managePriceView:(NSMutableDictionary *)dicadjustments
{
    for(UIView* view in [viewPrice subviews])
    {
        if(view.tag != 100 && view.tag != 200 )
            [view removeFromSuperview];
    }
    
    [lblSubTotal setText:[NSString stringWithFormat:@"%@",[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",([[dicadjustments objectForKey:@"subtotal"] doubleValue])-([[dicadjustments objectForKey:@"adjustment_total"] doubleValue])] CurrencySymbol:appDelegate.strCurrencySymbol]]];
    
    [lblTotalAmount setText:[NSString stringWithFormat:@"%@",[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",([[dicadjustments objectForKey:@"subtotal"] doubleValue])] CurrencySymbol:appDelegate.strCurrencySymbol]]];
    
    
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
            
            
            NSRange r1 = [[dicTax objectForKey:@"title"] rangeOfString:@"("];
            NSRange r2 = [[dicTax objectForKey:@"title"] rangeOfString:@")"];
            NSRange rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
            
            tfCouponCode.text = [[dicTax objectForKey:@"title"] substringWithRange:rSub];
            
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
    
    CGRect frameViewPriceCouponCode = viewPriceCouponCode.frame;
    frameViewPriceCouponCode.size.height = viewPrice.frame.origin.y + viewPrice.frame.size.height;
    viewPriceCouponCode.frame = frameViewPriceCouponCode;
    
    CGRect frame = viewShoppingCart.frame;
    frame.size.height = viewPriceCouponCode.frame.origin.y + viewPriceCouponCode.frame.size.height + 20;
    viewShoppingCart.frame = frame;
    
    [svContainer setContentSize:CGSizeMake(svContainer.frame.size.width, (viewShoppingCart.frame.origin.y + viewShoppingCart.frame.size.height))];
    
}

-(UILabel *)createUILable:(CGRect)frameOfLable
{
    UILabel *lbl = [[UILabel alloc]initWithFrame:frameOfLable];
    [lbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
    [lbl setTextColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
    return lbl;
}

- (void)showDropIn:(NSString *)clientTokenOrTokenizationKey {
    BTDropInRequest *request = [[BTDropInRequest alloc] init];
    BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:clientTokenOrTokenizationKey request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"ERROR");
            [self dismissViewControllerAnimated:YES completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else if (result.cancelled) {
            NSLog(@"CANCELLED");
            [self dismissViewControllerAnimated:YES completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            // Use the BTDropInResult properties to update your UI
            // result.paymentOptionType
            // result.paymentMethod
            // result.paymentIcon
            // result.paymentDescription
            
            
            [SVProgressHUD show];
            
            NSString *strURL = [NSString stringWithFormat:@"%@checkouts/%@",WS_BaseUrl,_strOrderNumber];
            
            NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
            
            NSMutableDictionary *dicOrder = [[NSMutableDictionary alloc]init];
            
            NSMutableArray *arrPaymentsAttributes = [[NSMutableArray alloc]init];
            NSMutableDictionary *dicPaymentsAttributes = [[NSMutableDictionary alloc]init];
            [dicPaymentsAttributes setObject:@"4" forKey:@"payment_method_id"];
            [dicPaymentsAttributes setObject:result.paymentMethod.nonce forKey:@"braintree_nonce"];
            [arrPaymentsAttributes addObject:dicPaymentsAttributes];
            [dicOrder setObject:arrPaymentsAttributes forKey:@"payments_attributes"];
            
            
            NSMutableDictionary *dicPaymentSource = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *dic4 = [[NSMutableDictionary alloc]init];
            [dic4 setObject:result.paymentMethod.localizedDescription forKey:@"paypal_email"];
            [dic4 setObject:result.paymentMethod.nonce forKey:@"braintree_nonce"];
            [dicPaymentSource setObject:dic4 forKey:@"4"];
            
            [dicPostData setObject:strOrderState forKey:@"order_state"];
            [dicPostData setObject:dicOrder forKey:@"order"];
            [dicPostData setObject:dicPaymentSource forKey:@"payment_source"];
            [dicPostData setObject:result.paymentMethod.localizedDescription forKey:@"paypal_email"];
            [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
            [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
            [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
            [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
            
            [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:PaymentToConfirm HTTPMethod:@"PUT" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
    }];
    [self presentViewController:dropIn animated:YES completion:nil];
}

#pragma mark - Delegate Method -

-(void)selectedAddress:(AddressList *)selectedAddress
{
    if(isBillingAddress)
    {
        billingAddress = selectedAddress;
        [lblBillingName setText:[NSString stringWithFormat:@"%@ %@",selectedAddress.strFirstName,selectedAddress.strLastName]];
        [btnBillingPhone setTitle:selectedAddress.strPhone forState:UIControlStateNormal];
        
        btnBillingAddress.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [btnBillingAddress setTitle:[NSString stringWithFormat:@"%@, %@\n%@, %@, %@ - %@",selectedAddress.strAddress1,selectedAddress.strAddress2,selectedAddress.strCountryName,selectedAddress.strStateName,selectedAddress.strCity,selectedAddress.strZipcode] forState:UIControlStateNormal];
        
        [btnAddBillingAddress setBackgroundColor:[UIColor clearColor]];
        [btnAddBillingAddress setTitle:@"" forState:UIControlStateNormal];
    }
    else
    {
        shippingAddress = selectedAddress;
        [lblShippingName setText:[NSString stringWithFormat:@"%@ %@",selectedAddress.strFirstName,selectedAddress.strLastName]];
        [btnShippingPhone setTitle:selectedAddress.strPhone forState:UIControlStateNormal];
        
        btnShippingAddress.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [btnShippingAddress setTitle:[NSString stringWithFormat:@"%@, %@\n%@, %@, %@ - %@",selectedAddress.strAddress1,selectedAddress.strAddress2,selectedAddress.strCountryName,selectedAddress.strStateName,selectedAddress.strCity,selectedAddress.strZipcode] forState:UIControlStateNormal];
        
        [btnAddShippingAddress setBackgroundColor:[UIColor clearColor]];
        [btnAddShippingAddress setTitle:@"" forState:UIControlStateNormal];
    }
}

-(void)moveAddressToDelivery
{
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        [SVProgressHUD show];
        
        NSString *strURL = [NSString stringWithFormat:@"%@checkouts/%@",WS_BaseUrl,_strOrderNumber];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *dicOrder = [[NSMutableDictionary alloc]init];
        
        NSMutableDictionary *dicBillAddressAttributes = [[NSMutableDictionary alloc]init];
        [dicBillAddressAttributes setObject:billingAddress.strFirstName forKey:@"firstname"];
        [dicBillAddressAttributes setObject:billingAddress.strLastName forKey:@"lastname"];
        [dicBillAddressAttributes setObject:billingAddress.strAddress1 forKey:@"address1"];
        [dicBillAddressAttributes setObject:billingAddress.strCity forKey:@"city"];
        [dicBillAddressAttributes setObject:billingAddress.strPhone forKey:@"phone"];
        [dicBillAddressAttributes setObject:billingAddress.strZipcode forKey:@"zipcode"];
        [dicBillAddressAttributes setObject:billingAddress.strStateId forKey:@"state_id"];
        [dicBillAddressAttributes setObject:billingAddress.strCountryId forKey:@"country_id"];
        
        if(isUse)
            shippingAddress = billingAddress;
        
        NSMutableDictionary *dicShipAddressAttributes = [[NSMutableDictionary alloc]init];
        [dicShipAddressAttributes setObject:shippingAddress.strFirstName forKey:@"firstname"];
        [dicShipAddressAttributes setObject:shippingAddress.strLastName forKey:@"lastname"];
        [dicShipAddressAttributes setObject:shippingAddress.strAddress1 forKey:@"address1"];
        [dicShipAddressAttributes setObject:shippingAddress.strCity forKey:@"city"];
        [dicShipAddressAttributes setObject:shippingAddress.strPhone forKey:@"phone"];
        [dicShipAddressAttributes setObject:shippingAddress.strZipcode forKey:@"zipcode"];
        [dicShipAddressAttributes setObject:shippingAddress.strStateId forKey:@"state_id"];
        [dicShipAddressAttributes setObject:shippingAddress.strCountryId forKey:@"country_id"];
        
        [dicOrder setObject:dicBillAddressAttributes forKey:@"bill_address_attributes"];
        [dicOrder setObject:dicShipAddressAttributes forKey:@"ship_address_attributes"];
        
        //        [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
        [dicPostData setObject:dicOrder forKey:@"order"];
        [dicPostData setObject:strOrderState forKey:@"order_state"];
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:AddressToDelivery HTTPMethod:@"PUT" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
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
    frame.size.width = tblCartList.frame.size.width;
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
    
    [cartlistTableViewCell.tfQty setText:productList.strQuantity];
    
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
    [cell.contentView addSubview:cartlistTableViewCell];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",[arrCartList objectAtIndex:indexPath.section]);
}

#pragma mark - UITextField Delegate Methods -

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        [SVProgressHUD show];
        
        NSString *strURL = [NSString stringWithFormat:@"%@orders/%@/cancel_coupon_code",WS_BaseUrl,_strOrderNumber];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        
        [dicPostData setObject:tfCouponCode.text forKey:@"coupon_code"];
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:CancelCouponCode HTTPMethod:@"PUT" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
    
    return TRUE;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([tfCouponCode.text length])
    {
        if([common checkInternetConnection:TRUE ViewController:self.navigationController])
        {
            [SVProgressHUD show];
            
            NSString *strURL = [NSString stringWithFormat:@"%@orders/%@/apply_coupon_code",WS_BaseUrl,_strOrderNumber];
            
            NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
            
            [dicPostData setObject:tfCouponCode.text forKey:@"coupon_code"];
            [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
            [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
            [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
            
            [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:ApplyCouponCode HTTPMethod:@"PUT" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
        }
    }
}

#pragma mark - WebAPI Response -

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther
{
    switch (tag)
    {
            
        case 22:
            //Next
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    strShipmentMinimumPrice = [dicResponse objectForKey:@"shipment_minimum_price"];
                    if([[dicResponse objectForKey:@"order_detail"] count])
                    {
                        NSMutableDictionary *dicOrderDetails = [[dicResponse objectForKey:@"order_detail"] objectAtIndex:0];
                        
                        strOrderState = [dicOrderDetails objectForKey:@"state"];
                        
                        dicAdjustments = [[[dicOrderDetails objectForKey:@"adjustments"] objectAtIndex:0] mutableCopy];
                        [self managePriceView:dicAdjustments];
                        
                        
                        if(![[[dicOrderDetails objectForKey:@"bill_address"] allKeys] count])
                        {
                            [self getAddress];
                        }
                        else
                        {
                            NSMutableDictionary *dicAddress = [dicOrderDetails objectForKey:@"bill_address"];
                            
                            billingAddress.strPhone = [dicAddress objectForKey:@"phone"];
                            billingAddress.strFirstName = [dicAddress objectForKey:@"firstname"];
                            billingAddress.strLastName = [dicAddress objectForKey:@"lastname"];
                            billingAddress.strAddress1 = [dicAddress objectForKey:@"address1"];
                            billingAddress.strAddress2 = [dicAddress objectForKey:@"address2"];
                            billingAddress.strCountryId = [dicAddress objectForKey:@"country_id"];
                            billingAddress.strCountryName = [[dicAddress objectForKey:@"country"] objectForKey:@"name"];
                            billingAddress.strStateId = [dicAddress objectForKey:@"state_id"];
                            billingAddress.strStateName = [[dicAddress objectForKey:@"state"] objectForKey:@"name"];
                            billingAddress.strCity = [dicAddress objectForKey:@"city"];
                            billingAddress.strZipcode = [dicAddress objectForKey:@"zipcode"];
                            
                            isBillingAddress = TRUE;
                            [self selectedAddress:billingAddress];
                            
                            dicAddress = [dicOrderDetails objectForKey:@"ship_address"];
                            
                            shippingAddress.strPhone = [dicAddress objectForKey:@"phone"];
                            shippingAddress.strFirstName = [dicAddress objectForKey:@"firstname"];
                            shippingAddress.strLastName = [dicAddress objectForKey:@"lastname"];
                            shippingAddress.strAddress1 = [dicAddress objectForKey:@"address1"];
                            shippingAddress.strAddress2 = [dicAddress objectForKey:@"address2"];
                            shippingAddress.strCountryId = [dicAddress objectForKey:@"country_id"];
                            shippingAddress.strCountryName = [[dicAddress objectForKey:@"country"] objectForKey:@"name"];
                            shippingAddress.strStateId = [dicAddress objectForKey:@"state_id"];
                            shippingAddress.strStateName = [[dicAddress objectForKey:@"state"] objectForKey:@"name"];
                            shippingAddress.strCity = [dicAddress objectForKey:@"city"];
                            shippingAddress.strZipcode = [dicAddress objectForKey:@"zipcode"];
                            
                            isBillingAddress = FALSE;
                            [self selectedAddress:shippingAddress];
                            
                            if([billingAddress.strPhone isEqualToString:billingAddress.strPhone] && [billingAddress.strFirstName isEqualToString:billingAddress.strFirstName] && [billingAddress.strLastName isEqualToString:billingAddress.strLastName] && [billingAddress.strAddress1 isEqualToString:billingAddress.strAddress1] && [billingAddress.strAddress2 isEqualToString:billingAddress.strAddress2] && [billingAddress.strCountryId isEqualToString:billingAddress.strCountryId] && [billingAddress.strStateId isEqualToString:billingAddress.strStateId] && [billingAddress.strCity isEqualToString:billingAddress.strCity] && [billingAddress.strZipcode isEqualToString:billingAddress.strZipcode] )
                            {
                                isUse = FALSE;
                                [self btnUsePressed:nil];
                            }
                            else{
                                isUse = TRUE;
                                [self btnUsePressed:nil];
                            }
                            
                            [self moveAddressToDelivery];
                        }
                    }
                    //                    appDelegate.strCartCount = [dicResponse objectForKey:@"cart_count"];
                    //                    [self setNavigationBar:appDelegate.strCartCount];
                }
                else
                    [self displayErrorMessage:dicResponse];
            }
            break;
            
        case 23:
            //User_Addresses
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                [btnCheckOut setUserInteractionEnabled:TRUE];
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    NSMutableArray *arrDetails = [[dicResponse objectForKey:@"details"] mutableCopy];
                    if([arrDetails count])
                    {
                        
                        NSMutableDictionary *dicDetails = [arrDetails objectAtIndex:0];
                        
                        billingAddress.strPhone = [dicDetails objectForKey:@"phone"];
                        billingAddress.strFirstName = [dicDetails objectForKey:@"firstname"];
                        billingAddress.strLastName = [dicDetails objectForKey:@"lastname"];
                        billingAddress.strAddress1 = [dicDetails objectForKey:@"address1"];
                        billingAddress.strAddress2 = [dicDetails objectForKey:@"address2"];
                        billingAddress.strCountryId = [dicDetails objectForKey:@"country_id"];
                        billingAddress.strCountryName = [dicDetails objectForKey:@"country_name"];
                        billingAddress.strStateId = [dicDetails objectForKey:@"state_id"];
                        billingAddress.strStateName = [dicDetails objectForKey:@"state_name"];
                        billingAddress.strCity = [dicDetails objectForKey:@"city"];
                        billingAddress.strZipcode = [dicDetails objectForKey:@"zipcode"];
                        
                        isBillingAddress = TRUE;
                        [self selectedAddress:billingAddress];
                        
                        isBillingAddress = FALSE;
                        [self selectedAddress:billingAddress];
                        
                        [self moveAddressToDelivery];
                        
                    }
                }
                else
                    [self displayErrorMessage:dicResponse];
            }
            break;
            
            
        case 28:
            //AddressToDelivery
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    if([[dicResponse objectForKey:@"order_detail"] count])
                    {
                        NSMutableDictionary *dicOrderDetails = [[dicResponse objectForKey:@"order_detail"] objectAtIndex:0];
                        
                        strOrderState = [dicOrderDetails objectForKey:@"state"];
                        
                        [btnCheckOut setUserInteractionEnabled:TRUE];
                    }
                }
                else
                    [self displayErrorMessage:dicResponse];
            }
            break;
            
            
        case 29:
            //DeliveryToPayment
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    if([[dicResponse objectForKey:@"order_detail"] count])
                    {
                        NSMutableDictionary *dicOrderDetails = [[dicResponse objectForKey:@"order_detail"] objectAtIndex:0];
                        
                        strOrderState = [dicOrderDetails objectForKey:@"state"];
                        strClientToken = [dicOrderDetails objectForKey:@"client_token"];
                        if([strClientToken length])
                            [self showDropIn:strClientToken];

//                        PaymentViewController *paymentViewController = [[PaymentViewController alloc]initWithNibName:@"PaymentViewController" bundle:nil];
//                        paymentViewController.strOrderNumber = _strOrderNumber;
//                        paymentViewController.strOrderState = strOrderState;
//                        paymentViewController.strTotalCount = lblTotalCount.text;
//                        paymentViewController.strTotalAmount = lblTotalAmount.text;
//                        paymentViewController.strClientToken = strClientToken;
//                        
//                        [self.navigationController pushViewController:paymentViewController animated:YES];
                    }
                }
                else
                    [self displayErrorMessage:dicResponse];
            }
            break;
            
            
        case 32:
            //ApplyCouponCode
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    dicAdjustments = [[[dicResponse objectForKey:@"details"] objectAtIndex:0] mutableCopy];
                    [self managePriceView:dicAdjustments];
                    
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
                else
                    [self displayErrorMessage:dicResponse];
            }
            break;
            
        case 33:
            //CancelCouponCode
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    dicAdjustments = [[[dicResponse objectForKey:@"details"] objectAtIndex:0] mutableCopy];
                    [self managePriceView:dicAdjustments];
                    [self.view endEditing:TRUE];
                }
                else
                    [self displayErrorMessage:dicResponse];
            }
            break;
            
        case 30:
            //PaymentToConfirm
            
//            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    if([[dicResponse objectForKey:@"order_detail"] count])
                    {
                        NSMutableDictionary *dicOrderDetails = [[dicResponse objectForKey:@"order_detail"] objectAtIndex:0];
                        
                        strOrderState = [dicOrderDetails objectForKey:@"state"];
                        
                        if([common checkInternetConnection:TRUE ViewController:self.navigationController])
                        {
                            [SVProgressHUD show];
                            
                            NSString *strURL = [NSString stringWithFormat:@"%@checkouts/%@/next.json",WS_BaseUrl,_strOrderNumber];
                            
                            NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
                            
                            //        [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
                            [dicPostData setObject:strOrderState forKey:@"order_state"];
                            [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
                            [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
                            [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
                            
                            [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:ConfirmToComplete HTTPMethod:@"PUT" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
                        }
                        
                    }
                }
            }
            break;
            
        case 31:
            //ConfirmToComplete
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    if([[dicResponse objectForKey:@"order_detail"] count])
                    {
                        NSMutableDictionary *dicOrderDetails = [[dicResponse objectForKey:@"order_detail"] objectAtIndex:0];
                        
                        strOrderState = [dicOrderDetails objectForKey:@"state"];
                        
                        ThankYouViewController *thankYouViewController = [[ThankYouViewController alloc]initWithNibName:@"ThankYouViewController" bundle:nil];
                        thankYouViewController.strOrderNumber = _strOrderNumber;
                        [self.navigationController pushViewController:thankYouViewController animated:YES];
                    }
                }
            }
            break;

        default:
            break;
            
    }
}
@end
