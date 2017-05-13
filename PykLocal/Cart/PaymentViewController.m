//
//  PaymentViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 25/12/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "PaymentViewController.h"
#import "CardIO.h"
#import "ThankYouViewController.h"

#import "BraintreeCore.h"
#import "BraintreeDropIn.h"

@interface PaymentViewController ()<CardIOPaymentViewControllerDelegate>
{
    AppDelegate *appDelegate;
    Common *common;
    CardIOCreditCardInfo *cardIOCreditCardInfo;
    
    NSUserDefaults *prefs;
}
@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    
    btnPay.layer.cornerRadius = 5.0;
    
    [lblTotalCount setText:_strTotalCount];
    [lblTotalAmount setText:_strTotalAmount];
    
    [BTAppSwitch setReturnURLScheme:@"com.AppMasonStudiosInc.PykLocal.payments"];
    
//    _strClientToken = @"eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJkNmRiZTRkYjA5ZDMzYTczZTZlNTE2NjVmYmIxZjM3NjBmNDVkMjY5YWQ5NDFiZjk5OTdmZmVhM2FkMTQ2ZDNlfGNyZWF0ZWRfYXQ9MjAxNi0xMi0yNlQxMDozMzo1Mi4wMDQ2MjI2NTQrMDAwMFx1MDAyNm1lcmNoYW50X2lkPTM0OHBrOWNnZjNiZ3l3MmJcdTAwMjZwdWJsaWNfa2V5PTJuMjQ3ZHY4OWJxOXZtcHIiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzLzM0OHBrOWNnZjNiZ3l3MmIvY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tLzM0OHBrOWNnZjNiZ3l3MmIifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6dHJ1ZSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjp0cnVlLCJtZXJjaGFudEFjY291bnRJZCI6ImFjbWV3aWRnZXRzbHRkc2FuZGJveCIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJjb2luYmFzZUVuYWJsZWQiOmZhbHNlLCJtZXJjaGFudElkIjoiMzQ4cGs5Y2dmM2JneXcyYiIsInZlbm1vIjoib2ZmIn0=";

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Mange Slider
    appDelegate.isHandlePan = FALSE;
    
    //Mange NavigationBar With Cart Count
    [self setNavigationBar:appDelegate.strCartCount];
    
    [CardIOUtilities preload];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showDropIn:(NSString *)clientTokenOrTokenizationKey {
    BTDropInRequest *request = [[BTDropInRequest alloc] init];
    BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:clientTokenOrTokenizationKey request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"ERROR");
        } else if (result.cancelled) {
            NSLog(@"CANCELLED");
            [self dismissViewControllerAnimated:YES completion:nil];
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

            [dicPostData setObject:_strOrderState forKey:@"order_state"];
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


#pragma mark - Helper Method -

- (void)setNavigationBar:(NSString *)strCartValue
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController setNavigationBarHidden:FALSE];
    self.navigationItem.title = @"Payment Information";
    
}

- (void)pay
{
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        [SVProgressHUD show];
        
        NSString *strURL = [NSString stringWithFormat:@"%@checkouts/%@",WS_BaseUrl,_strOrderNumber];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *dicOrder = [[NSMutableDictionary alloc]init];
        
        NSMutableArray *arrPaymentsAttributes = [[NSMutableArray alloc]init];
        NSMutableDictionary *dicPaymentsAttributes = [[NSMutableDictionary alloc]init];
        [dicPaymentsAttributes setObject:@"3" forKey:@"payment_method_id"];
        [arrPaymentsAttributes addObject:dicPaymentsAttributes];
        
        [dicOrder setObject:arrPaymentsAttributes forKey:@"payments_attributes"];
        
        NSMutableDictionary *dicPaymentSource = [[NSMutableDictionary alloc]init];
        
        NSMutableDictionary *dic1 = [[NSMutableDictionary alloc]init];
        [dic1 setObject:cardIOCreditCardInfo.cardNumber forKey:@"number"];
        [dic1 setObject:[NSString stringWithFormat:@"%lu",(unsigned long)cardIOCreditCardInfo.expiryMonth] forKey:@"month"];
        [dic1 setObject:[NSString stringWithFormat:@"%lu",(unsigned long)cardIOCreditCardInfo.expiryYear] forKey:@"year"];
        [dic1 setObject:cardIOCreditCardInfo.cvv forKey:@"verification_value"];
        [dic1 setObject:@"" forKey:@"name"];
        
        [dicPaymentSource setObject:dic1 forKey:@"1"];
        
        
        //        [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
        [dicPostData setObject:dicOrder forKey:@"order"];
        [dicPostData setObject:dicPaymentSource forKey:@"payment_source"];
        [dicPostData setObject:_strOrderState forKey:@"order_state"];
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:PaymentToConfirm HTTPMethod:@"PUT" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
}

#pragma mark - IBAction Method -

-(IBAction)btnScanCardPressed:(UIButton *)sender
{
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.hideCardIOLogo=YES;
    scanViewController.guideColor = RGB;
    scanViewController.navigationBarStyle = UIBarStyleDefault;
    
    scanViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:scanViewController animated:YES completion:nil];
}

-(IBAction)btnPayPressed:(UIButton *)sender
{
    [self showDropIn:_strClientToken];
}

#pragma mark - CardIOPaymentViewControllerDelegate

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    
    cardIOCreditCardInfo = info;
    NSLog(@"Scan succeeded with info: %@", info);
    // Do whatever needs to be done to deliver the purchased items.
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"%@",[NSString stringWithFormat:@"Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@.", info.redactedCardNumber, (unsigned long)info.expiryMonth, (unsigned long)info.expiryYear, info.cvv]);
    
    [self pay];
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    NSLog(@"User cancelled scan");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WebAPI Response -

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther
{
    switch (tag)
    {
        case 30:
            //PaymentToConfirm
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    if([[dicResponse objectForKey:@"order_detail"] count])
                    {
                        NSMutableDictionary *dicOrderDetails = [[dicResponse objectForKey:@"order_detail"] objectAtIndex:0];
                        
                        _strOrderState = [dicOrderDetails objectForKey:@"state"];
                        
                        if([common checkInternetConnection:TRUE ViewController:self.navigationController])
                        {
                            [SVProgressHUD show];
                            
                            NSString *strURL = [NSString stringWithFormat:@"%@checkouts/%@/next.json",WS_BaseUrl,_strOrderNumber];
                            
                            NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
                            
                            //        [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
                            [dicPostData setObject:_strOrderState forKey:@"order_state"];
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
                        
                        _strOrderState = [dicOrderDetails objectForKey:@"state"];
                    
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
