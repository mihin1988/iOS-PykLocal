//
//  AddressViewController.m
//  PykLocal
//
//  Created by Saket Singhi on 19/12/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "AddressViewController.h"

@interface AddressViewController ()
{
    AppDelegate *appDelegate;
    Common *common;
    
    NSUserDefaults *prefs;
    NSMutableArray *arrCountry;
    NSMutableArray *arrState;
    NSMutableArray *arrData;
    
    NSString *strCountryId;
    NSString *strStateId;
    
    BOOL isCountry;
    
}
@end

@implementation AddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    
    [btnSubmit.layer setBorderColor:[[RGB colorWithAlphaComponent:1.0] CGColor]];
    [btnSubmit.layer setBorderWidth:0.5];
    btnSubmit.layer.cornerRadius = 15;
    btnSubmit.clipsToBounds = YES;
    
    [tfCountry setInputView:pvSelect];
    [tfState setInputView:pvSelect];
    
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        [SVProgressHUD show];
        
        NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Countries];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:Countries HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
        
    }
    
    if(_addressList)
    {
        tfFirstName.text = _addressList.strFirstName;
        tfLastName.text = _addressList.strLastName;
        tfPhone.text = _addressList.strPhone;
        tfAddress1.text = _addressList.strAddress1;
        tfAddress2.text = _addressList.strAddress2;
        tfCountry.text = _addressList.strCountryName;
        strCountryId = _addressList.strCountryId;
        tfState.text = _addressList.strStateName;
        strStateId = _addressList.strStateId;
        tfCity.text = _addressList.strCity;
        tfZipcode.text = _addressList.strZipcode;
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
    self.navigationItem.title = _strTitle;
    
}

#pragma mark - IBAction Method -


- (IBAction)btnSubmitPressed:(UIButton *)sender
{
    [self.view endEditing:TRUE];
    
    NSString *strAlertMessage = @"";
    
    NSString *Regex = @"[0-9^]*";
    NSPredicate *TestResult = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    
    if(!([tfFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter First Name";
    }
    else if(!([tfLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter Last Name";
    }
    else if(!([tfPhone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter Phone";
    }
    else if(![TestResult evaluateWithObject:tfPhone.text])
    {
        strAlertMessage = @"Enter Correct Phone";
        tfPhone.text = @"";
    }
    else if(!([tfAddress1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter Address 1";
    }
    else if(!([tfCountry.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter Country";
    }
    else if(!([tfState.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter State";
    }
    else if(!([tfCity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter City";
    }
    else if(!([tfZipcode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter Zipcode";
    }
    else if(![TestResult evaluateWithObject:tfZipcode.text])
    {
        strAlertMessage = @"Enter Correct Zipcode";
        tfZipcode.text = @"";
    }
    
    if(![strAlertMessage length])
    {
        _addressList.strPhone = tfPhone.text;
        _addressList.strFirstName = tfFirstName.text;
        _addressList.strLastName = tfLastName.text;
        _addressList.strAddress1 = tfAddress1.text;
        _addressList.strAddress2 = tfAddress2.text;
        _addressList.strCountryId = strCountryId;
        _addressList.strCountryName = tfCountry.text;
        _addressList.strStateId = strStateId;
        _addressList.strStateName = tfState.text;
        _addressList.strCity = tfCity.text;
        _addressList.strZipcode = tfZipcode.text;
        
        [_delegate selectedAddress:_addressList];
        [_delegate moveAddressToDelivery];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:nil//NSLocalizedString(@"Whoa!", nil)
                                           subtitle:strAlertMessage
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

#pragma mark - UIPickerView Method -


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [arrData count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if(row == 0)
    {
        if(isCountry)
        {
            strCountryId = [[arrData objectAtIndex:row]objectForKey:@"id"];
            tfCountry.text = [[arrData objectAtIndex:row]objectForKey:@"name"];
        }
        else
        {
            strStateId = [[arrData objectAtIndex:row]objectForKey:@"id"];
            tfState.text = [[arrData objectAtIndex:row]objectForKey:@"name"];
        }
    }
    
    return [[arrData objectAtIndex:row]objectForKey:@"name"];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(isCountry)
    {
        strCountryId = [[arrData objectAtIndex:row]objectForKey:@"id"];
        tfCountry.text = [[arrData objectAtIndex:row]objectForKey:@"name"];
    }
    else
    {
        strStateId = [[arrData objectAtIndex:row]objectForKey:@"id"];
        tfState.text = [[arrData objectAtIndex:row]objectForKey:@"name"];
    }
}

#pragma mark - UITextField Delegate -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == tfCountry)
    {
        arrData = [arrCountry mutableCopy];
        isCountry = TRUE;
    }
    else if(textField == tfState)
    {
        arrData = [arrState mutableCopy];
        isCountry = FALSE;
        
        for(int i = 0 ; i<[arrData count] ; i++)
        {
            if([strStateId isEqualToString:[[arrData objectAtIndex:i]objectForKey:@"id"]])
            {
                [pvSelect selectRow:i inComponent:0 animated:YES];
                tfState.text = [[arrData objectAtIndex:i]objectForKey:@"name"];
                break;
            }
        }
    }
    [pvSelect reloadComponent:0];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    string = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(textField == tfPhone)
    {
        if([string length] > 16)
            return FALSE;
    }
    
    return TRUE;
}


#pragma mark - WebAPI Response -

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther
{
    switch (tag)
    {
        case 24:
            //Countries
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    arrCountry = [[dicResponse objectForKey:@"details"] mutableCopy];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(code LIKE[c] %@)",@"USA"];
                    NSArray *arrDetail = [arrCountry filteredArrayUsingPredicate:predicate];
                    
                    arrCountry = [arrDetail mutableCopy];
                    
                    
                    
                    if([common checkInternetConnection:TRUE ViewController:self.navigationController] && [arrCountry count])
                    {
                        
                        NSString *strURL = [NSString stringWithFormat:@"%@countries/%@/states",WS_BaseUrl,[[arrCountry objectAtIndex:0] objectForKey:@"id"]];
                        
                        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
                        
                        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
                        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
                        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
                        
                        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:States HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
                    }
                    
                }
            }
            break;
            
        case 25:
            //States
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    arrState = [[dicResponse objectForKey:@"details"] mutableCopy];
                }
            }
            break;
        default:
            break;
            
    }
}

@end
