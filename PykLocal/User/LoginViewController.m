//
//  LoginViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 06/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Google/SignIn.h>

@interface LoginViewController ()<GIDSignInDelegate,GIDSignInUIDelegate>
{
    AppDelegate *appDelegate;
    Common *common;
    FBSDKLoginManager *login;

    NSUserDefaults *prefs;
    NSString *userId,*idToken,*username,*useremail,*accessToken,*strVersionDetails,*strVersionNo;
    NSURL *urlProfileImage;
    NSString *strProvider;
    NSString *strUid;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    
    [btnLogin.layer setBorderColor:[[RGB colorWithAlphaComponent:1.0] CGColor]];
    [btnLogin.layer setBorderWidth:0.5];
    btnLogin.layer.cornerRadius = 15;
    btnLogin.clipsToBounds = YES;
    
    [btnFacebook addTarget:self action:@selector(actionFB:) forControlEvents:UIControlEventTouchUpInside];
    [btnGooglePlus addTarget:self action:@selector(actionGoogle:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Mange Slider
    appDelegate.isHandlePan = FALSE;

    int height = btnGooglePlus.frame.origin.y + btnGooglePlus.frame.size.height+62;
    [_svContainer setContentSize:CGSizeMake(self.view.frame.size.width, height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Method -

- (IBAction)btnSignUpPressed:(UIButton *)sender
{
    [self.view endEditing:TRUE];
    NSString *strAlertMessage = @"";
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate * regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if(!([tfEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter Email";
    }
    else if(![regextest evaluateWithObject:tfEmail.text])
    {
        strAlertMessage = @"Enter Valid Email";
    }
    else if(!([tfPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter Password";
    }
    
    if(![strAlertMessage length])
    {
        if([common checkInternetConnection:TRUE ViewController:self.navigationController])
        {
            [SVProgressHUD show];
            
            NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Sessions];
            
            NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
            
            tfEmail.text = [tfEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            [dicPostData setObject:@"false" forKey:@"is_guest"];
            [dicPostData setObject:tfEmail.text forKey:@"email"];
            [dicPostData setObject:tfPassword.text forKey:@"password"];
            [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
            [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
            [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
            if([[prefs objectForKey:@"is_guest"] intValue] == 1)
                [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
            
            [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Sessions HTTPMethod:@"POST" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
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


- (IBAction)btnForgotPasswordPressed:(UIButton *)sender
{
    [self.view endEditing:TRUE];
    NSString *strAlertMessage = @"";
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate * regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if(!([tfEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter Email";
    }
    else if(![regextest evaluateWithObject:tfEmail.text])
    {
        strAlertMessage = @"Enter Valid Email";
    }
    
    if(![strAlertMessage length])
    {
        if([common checkInternetConnection:TRUE ViewController:self.navigationController])
        {
            [SVProgressHUD show];
            
            NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Password];
            
            NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
            
            tfEmail.text = [tfEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            [dicPostData setObject:tfEmail.text forKey:@"email"];
            [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
            [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
            [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
            
            [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Password HTTPMethod:@"POST" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
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

#pragma mark - actionFacebook Method -

- (IBAction)actionFB:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    login = [[FBSDKLoginManager alloc] init];
    
    [login logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                if (error)
                                    NSLog(@"Process error");
                                else if (result.isCancelled)
                                    NSLog(@"Cancelled");
                                else {
                                    [SVProgressHUD show];
                                    [self fetchUserInfo];
                                }
                            }];
}

#pragma mark - fetchUserInfo -

-(void)fetchUserInfo{
    
    if ([FBSDKAccessToken currentAccessToken]){
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, link, first_name, last_name, gender, picture.type(large), email, birthday, bio , location , friends , hometown , friendlists"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             
             [SVProgressHUD dismiss];
             [login logOut];
             
             if (!error){
            
                 NSDictionary *userData = (NSDictionary *)result;
                 
                 strProvider = @"facebook";
                 strUid = [NSString stringWithFormat:@"%@",[userData valueForKey:@"id"]?:@""];
                 
                 if([common checkInternetConnection:TRUE ViewController:self.navigationController])
                 {
                     [SVProgressHUD show];
                     
                     NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Sessions];
                     
                     NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
                     
                     [dicPostData setObject:@"false" forKey:@"is_guest"];
                     [dicPostData setObject:[NSString stringWithFormat:@"%@",[userData valueForKey:@"email"]?:@""] forKey:@"email"];
                     [dicPostData setObject:[NSString stringWithFormat:@"%@",[userData valueForKey:@"first_name"]?:@""] forKey:@"first_name"];
                     [dicPostData setObject:[NSString stringWithFormat:@"%@",[userData valueForKey:@"last_name"]?:@""] forKey:@"last_name"];
                     [dicPostData setObject:strProvider forKey:@"provider"];
                     [dicPostData setObject:strUid forKey:@"uid"];
                     [dicPostData setObject:@"true" forKey:@"t_and_c_accepted"];
                     [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
                     [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
                     [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
                     if([[prefs objectForKey:@"is_guest"] intValue] == 1)
                         [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
                     
                     [prefs setObject:[dicPostData valueForKey:@"email"] forKey:@"email"];
                     [prefs synchronize];

                     
                     [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Sessions HTTPMethod:@"POST" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
                 }
             }
             else
             {
                 [TSMessage showNotificationInViewController:self.navigationController
                                                       title:nil//NSLocalizedString(@"Whoa!", nil)
                                                    subtitle:error.localizedDescription
                                                       image:nil
                                                        type:TSMessageNotificationTypeError
                                                    duration:TSMessageNotificationDurationAutomatic
                                                    callback:nil
                                                 buttonTitle:nil
                                              buttonCallback:nil
                                                  atPosition:TSMessageNotificationPositionBottom
                                        canBeDismissedByUser:YES];
                 
             }
         }];
    }
    else{
        [SVProgressHUD dismiss];
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:nil//NSLocalizedString(@"Whoa!", nil)
                                           subtitle:@"Unable to verify token. Login Failed."
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

#pragma mark - actionGoogle Method -


- (IBAction)actionGoogle:(UIButton *)sender {
    [self.view endEditing:YES];
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    
    [GIDSignIn sharedInstance].clientID = kGoogleClientId;
    
    [[GIDSignIn sharedInstance] setScopes:@[@"https://www.googleapis.com/auth/plus.login",@"https://www.googleapis.com/auth/plus.me",@"profile",@"https://www.googleapis.com/auth/userinfo.profile"]];
    
    [[GIDSignIn sharedInstance] signIn];
}

#pragma mark - GIDSignInDelegate -

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    userId = user.userID;
    idToken = user.authentication.idToken;
    username = user.profile.name;
    useremail = user.profile.email;
    accessToken = user.authentication.accessToken;
    
    if ([GIDSignIn sharedInstance].currentUser.profile.hasImage)
        urlProfileImage = [user.profile imageURLWithDimension:160];
    
    [[GIDSignIn sharedInstance] signOut];
    
    if ([userId isKindOfClass:[NSString class]]){
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager GET:[NSString stringWithFormat:@"%@%@",WS_GoogleSignIn,accessToken]
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 [SVProgressHUD dismiss];
                 
                 NSDictionary *userData = (NSDictionary *)responseObject;
                 
                 strUid = [NSString stringWithFormat:@"%@",[userData valueForKey:@"id"]?:@""];
                 strProvider = @"google";
                 
                 if([common checkInternetConnection:TRUE ViewController:self.navigationController])
                 {
                     [SVProgressHUD show];
                     
                     NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Sessions];
                     
                     NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
                     
                     [dicPostData setObject:@"false" forKey:@"is_guest"];
                     [dicPostData setObject:[NSString stringWithFormat:@"%@",[[[userData valueForKey:@"emails"] objectAtIndex:0] valueForKey:@"value"]?:@""] forKey:@"email"];
                     [dicPostData setObject:[NSString stringWithFormat:@"%@",[[userData valueForKey:@"name"] valueForKey:@"givenName"]?:@""] forKey:@"first_name"];
                     [dicPostData setObject:[NSString stringWithFormat:@"%@",[[userData valueForKey:@"name"] valueForKey:@"familyName"]?:@""] forKey:@"last_name"];
                     [dicPostData setObject:strProvider forKey:@"provider"];
                     [dicPostData setObject:strUid forKey:@"uid"];
                     [dicPostData setObject:@"true" forKey:@"t_and_c_accepted"];
                     [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
                     [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
                     [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
                     if([[prefs objectForKey:@"is_guest"] intValue] == 1)
                         [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
                     
                     [prefs setObject:[dicPostData valueForKey:@"email"] forKey:@"email"];
                     [prefs synchronize];
                     
                     [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Sessions HTTPMethod:@"POST" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
                 }
                 
                 //                 NSString *strGender = [NSString stringWithFormat:@"%@",[userData valueForKey:@"gender"]?:@""];
                 
                 //                 NSString *strImageUrl = [NSString stringWithFormat:@"%@",[[userData valueForKey:@"image"] valueForKey:@"url"]?:@""];
                 //                 NSString *strImageUrl1 = [NSString stringWithFormat:@"%@",urlProfileImage?:@""];
                 
             }
         
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [SVProgressHUD dismiss];
                 [TSMessage showNotificationInViewController:self.navigationController
                                                       title:nil//NSLocalizedString(@"Whoa!", nil)
                                                    subtitle:error.localizedDescription
                                                       image:nil
                                                        type:TSMessageNotificationTypeError
                                                    duration:TSMessageNotificationDurationAutomatic
                                                    callback:nil
                                                 buttonTitle:nil
                                              buttonCallback:nil
                                                  atPosition:TSMessageNotificationPositionBottom
                                        canBeDismissedByUser:YES];
             }];
    }
    else{
        [SVProgressHUD dismiss];
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:nil//NSLocalizedString(@"Whoa!", nil)
                                           subtitle:error.localizedDescription
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


//- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
//}

# pragma mark - GIDSignInUIDelegate -

- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error{
    
}

- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    [SVProgressHUD show];
}

#pragma mark - WebAPI Response -

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther
{
    switch (tag)
    {
        case 1:
            //Sessions
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    NSMutableDictionary *dicUser = [dicResponse valueForKey:@"user"];
                    [prefs setObject:[dicUser objectForKey:@"spree_api_key"] forKey:@"spree_api_key"];
                    [prefs setObject:[dicUser objectForKey:@"token"] forKey:@"token"];
                    [prefs setObject:tfEmail.text forKey:@"email"];
                    [prefs setObject:@"0" forKey:@"is_guest"];
                    [prefs synchronize];
                    
                    [appDelegate.leftMenuViewController setSliderList];
                    
                    HomeViewController *homeViewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
                    [self.navigationController pushViewController:homeViewController animated:YES];
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
            
        case 6:
            //Password
            
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
