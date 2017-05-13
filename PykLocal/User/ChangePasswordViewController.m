//
//  ChangePasswordViewController.m
//  PykLocal
//
//  Created by Saket Singhi on 03/12/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "HomeViewController.h"

@interface ChangePasswordViewController ()
{
    AppDelegate *appDelegate;
    Common *common;
    
    NSUserDefaults *prefs;
}
@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];

    [btnSubmit.layer setBorderColor:[[RGB colorWithAlphaComponent:1.0] CGColor]];
    [btnSubmit.layer setBorderWidth:0.5];
    btnSubmit.layer.cornerRadius = 15;
    btnSubmit.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Mange Slider
    appDelegate.isHandlePan = TRUE;
    
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
    
    [self.navigationController setNavigationBarHidden:FALSE];
    
    UIButton *logoView = [[UIButton alloc] initWithFrame:CGRectMake(0,0,60,60)];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,60,60)];
    image.contentMode = UIViewContentModeScaleAspectFit;
    [image setImage: [UIImage imageNamed:@"Img-Logo.png"]];
    [logoView addSubview:image];
    [logoView setUserInteractionEnabled:NO];
//    self.navigationItem.titleView = logoView;

    self.navigationItem.title = @"Change Password";
    
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
    
    if(!([tfOldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter Old Password";
    }
    else if(!([tfNewPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter New Password";
    }
    else if(!([tfReTypePassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)
    {
        strAlertMessage = @"Enter Re-Type Password";
    }
    else if((([tfNewPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length)<6)
    {
        strAlertMessage = @"Enter Minimum 6 Characters Password";
    }
    else if(![tfNewPassword.text isEqualToString:tfReTypePassword.text])
    {
        strAlertMessage = @"Password does not match";
    }
    
    
    if(![strAlertMessage length])
    {
        if([common checkInternetConnection:TRUE ViewController:self.navigationController])
        {
            [SVProgressHUD show];
            
            NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Change_Password];
            
            NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
            [dicPostData setObject:[prefs objectForKey:@"email"] forKey:@"email"];
            [dicPostData setObject:tfOldPassword.text forKey:@"old_password"];
            [dicPostData setObject:tfNewPassword.text forKey:@"new_password"];
            [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
            [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
            [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
            
            [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Change_Password HTTPMethod:@"POST" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
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

#pragma mark - WebAPI Response -

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther
{
    switch (tag)
    {
        case 19:
            //Change_Password
            
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
//                    tfOldPassword.text = @"";
//                    tfNewPassword.text = @"";
//                    tfReTypePassword.text = @"";
                    
                    HomeViewController *homeViewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
                    
                    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                    NSArray *controllers = [NSArray arrayWithObject:homeViewController];
                    navigationController.viewControllers = controllers;
                }
                else
                {
                    [TSMessage showNotificationInViewController:self.navigationController
                                                          title:nil//NSLocalizedString(@"Whoa!", nil)
                                                       subtitle:[dicResponse objectForKey:@"message"]
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
