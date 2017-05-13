//
//  UserProfileViewController.m
//  PykLocal
//
//  Created by Saket Singhi on 08/12/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "UserProfileViewController.h"

@interface UserProfileViewController ()
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

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    
    [btnSubmit.layer setBorderColor:[[RGB colorWithAlphaComponent:1.0] CGColor]];
    [btnSubmit.layer setBorderWidth:0.5];
    btnSubmit.layer.cornerRadius = 15;
    btnSubmit.clipsToBounds = YES;
    
    [btnAddressSubmit.layer setBorderColor:[[RGB colorWithAlphaComponent:1.0] CGColor]];
    [btnAddressSubmit.layer setBorderWidth:0.5];
    btnAddressSubmit.layer.cornerRadius = 15;
    btnAddressSubmit.clipsToBounds = YES;
    
    [tfCountry setInputView:pvSelect];
    [tfState setInputView:pvSelect];
    
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        [SVProgressHUD show];
        
        NSString *strURL = [NSString stringWithFormat:@"%@users/%@/profile",WS_BaseUrl,[prefs objectForKey:@"token"]];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:Get_Profile HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
        
        strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Countries];
        
        dicPostData = [[NSMutableDictionary alloc]init];
        
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
    
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:Countries HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
        
        strURL = [NSString stringWithFormat:@"%@user_addresses/%@",WS_BaseUrl,[prefs objectForKey:@"token"]];
        
        dicPostData = [[NSMutableDictionary alloc]init];
        
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:User_Addresses HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
    [svContainer setAutoresizesSubviews:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect frame = svContainer.frame;
    frame.size.width = appDelegate.window.frame.size.width;
    
    [svContainer setFrame:frame];
    
    //Mange Slider
    appDelegate.isHandlePan = TRUE;
    
    //Mange NavigationBar With Cart Count
    [self setNavigationBar:appDelegate.strCartCount];
    
    [svContainer setContentSize:CGSizeMake(appDelegate.window.frame.size.width, btnAddressSubmit.frame.origin.y+60)];
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
    
    self.navigationItem.title = @"My Profile";
    
    UIBarButtonItem *btnLeft = [[UIBarButtonItem alloc]
                                initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
                                target:self action:@selector(leftSideMenuButtonPressed:)];
    
    [self.navigationItem setLeftBarButtonItem:btnLeft];
    
}

#pragma mark - UIBarButtonItem Callbacks -

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}

#pragma mark - IBAction Method -

- (IBAction)btnSubmitPressed:(UIButton *)sender
{
    [self.view endEditing:TRUE];
    
    NSString *strAlertMessage = @"";
    
    if(!([tfFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter First Name";
    }
    else if(!([tfLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter Last Name";
    }
    
    if(![strAlertMessage length])
    {
        if([common checkInternetConnection:TRUE ViewController:self.navigationController])
        {
            [SVProgressHUD show];

            NSString *strURL = [NSString stringWithFormat:@"%@/users/%@",WS_BaseUrl,[prefs objectForKey:@"token"]];

            NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *dicUser = [[NSMutableDictionary alloc]init];

            [dicUser setObject:tfEmail.text forKey:@"email"];
            [dicUser setObject:tfFirstName.text forKey:@"first_name"];
            [dicUser setObject:tfLastName.text forKey:@"last_name"];
            [dicPostData setObject:dicUser forKey:@"user"];
            [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
            [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
            [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];

            [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:Update_Profile HTTPMethod:@"PUT" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
        }
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

- (IBAction)btnAddressSubmitPressed:(UIButton *)sender
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
        if([common checkInternetConnection:TRUE ViewController:self.navigationController])
        {
            [SVProgressHUD show];
            
            NSString *strURL = [NSString stringWithFormat:@"%@user_addresses",WS_BaseUrl];
            
            NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *dicAddress = [[NSMutableDictionary alloc]init];
            

            [dicAddress setObject:tfFirstName.text forKey:@"firstname"];
            [dicAddress setObject:tfLastName.text forKey:@"lastname"];
            [dicAddress setObject:tfAddress1.text forKey:@"address1"];
            [dicAddress setObject:tfAddress2.text forKey:@"address2"];
            [dicAddress setObject:strCountryId forKey:@"country_id"];
            [dicAddress setObject:strStateId forKey:@"state_id"];
            [dicAddress setObject:tfState.text forKey:@"state_name"];
            [dicAddress setObject:tfCity.text forKey:@"city"];
            [dicAddress setObject:tfZipcode.text forKey:@"zipcode"];
            [dicAddress setObject:tfPhone.text forKey:@"phone"];
            
            [dicPostData setObject:dicAddress forKey:@"address"];
            [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
            [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
            [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
            [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
            
            [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Update_Address HTTPMethod:@"POST" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
        }
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
        case 20:
            //Get_Profile
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    NSMutableArray *arrDetails = [[dicResponse objectForKey:@"details"] mutableCopy];
                    if([arrDetails count])
                    {
                        NSMutableDictionary *dicDetails = [arrDetails objectAtIndex:0];
                        
                        tfEmail.text = [dicDetails objectForKey:@"email"];
                        tfFirstName.text = [dicDetails objectForKey:@"first_name"];
                        tfLastName.text = [dicDetails objectForKey:@"last_name"];
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
            
        case 21:
            //Update_Profile
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
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
        
        
        case 23:
            //User_Addresses
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    NSMutableArray *arrDetails = [[dicResponse objectForKey:@"details"] mutableCopy];
                    if([arrDetails count])
                    {
                        NSMutableDictionary *dicDetails = [arrDetails objectAtIndex:0];
                        
                        tfPhone.text = [dicDetails objectForKey:@"phone"];
                        tfFirstName.text = [dicDetails objectForKey:@"firstname"];
                        tfLastName.text = [dicDetails objectForKey:@"lastname"];
                        tfAddress1.text = [dicDetails objectForKey:@"address1"];
                        tfAddress2.text = [dicDetails objectForKey:@"address2"];
                        strCountryId = [dicDetails objectForKey:@"country_id"];
                        tfCountry.text = [dicDetails objectForKey:@"country_name"];
                        strStateId = [dicDetails objectForKey:@"state_id"];
                        tfState.text = [dicDetails objectForKey:@"state_name"];
                        tfCity.text = [dicDetails objectForKey:@"city"];
                        tfZipcode.text = [dicDetails objectForKey:@"zipcode"];
                    }
                }
            }
            break;
        
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
            
        case 26:
            //Update_Address
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
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
