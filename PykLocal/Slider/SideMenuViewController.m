//
//  SideMenuViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 21/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "SideMenuViewController.h"
#import "HomeViewController.h"
#import "AllCategoriesViewController.h"
#import "WishlistViewController.h"
#import "UserProfileViewController.h"
#import "ChangePasswordViewController.h"
#import "LoginSignUpViewController.h"
#import "AbouViewController.h"
#import "OrderListViewController.h"

@interface SideMenuViewController ()
{
    AppDelegate *appDelegate;
    Common *common;

    NSUserDefaults *prefs;
    NSMutableArray *arrSliderList;
}
@end

@implementation SideMenuViewController
@synthesize index;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    
    self.title = @"Slider";
    index = 0;
    [self.navigationController setNavigationBarHidden:FALSE];
    
    UIButton *logoView = [[UIButton alloc] initWithFrame:CGRectMake(0,0,60,60)];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,60,60)];
    image.contentMode = UIViewContentModeScaleAspectFit;
    [image setImage: [UIImage imageNamed:@"Img-Logo.png"]];
    [logoView addSubview:image];
    [logoView setUserInteractionEnabled:NO];
    self.navigationItem.titleView = logoView;
    
    [self setSliderList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSliderList
{
    if([[prefs objectForKey:@"is_guest"] intValue] == 1)
        arrSliderList = [[NSMutableArray alloc] initWithObjects: @"Home" , @"Shop By Category" , @"Wish List" , @"About PykLocal" , @"Login" , nil];
    else
        arrSliderList = [[NSMutableArray alloc] initWithObjects: @"Home" , @"Shop By Category" , @"Wish List" , @"My Profile" , @"My Orders" , @"Change Password" , @"About PykLocal" , @"Logout" , nil];
    
//    arrSliderList = [[NSMutableArray alloc] initWithObjects: @"Home" , @"Shop By Category" , @"Wish List" , @"My Profile" , @"My Orders" , @"Change Password" , @"About Us" , @"FAQ" , @"Shipping" , @"Return Policy" , @"Warranty" , @"Contact Us" , @"Terms & Conditions" , @"Logout" , nil];

    [tblSliderList reloadData];
}

#pragma mark - UITableView Method -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrSliderList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    UITableViewCell *cell;
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    [cell setSelectedBackgroundView:bgColorView];

    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [cell.textLabel setText:[arrSliderList objectAtIndex:indexPath.row]];
    
//    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 13, self.view.frame.size.width-85, 22)];
//    lblTitle.text = [arrSliderList objectAtIndex:indexPath.row];
//    [lblTitle setTextColor:[UIColor grayColor]];
//    [lblTitle setFont:[UIFont systemFontOfSize:15.0]];
//    [cell.contentView addSubview:lblTitle];
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(index != indexPath.row)
    {
        NSString *strSelectRow = [arrSliderList objectAtIndex:indexPath.row];
        
        UIViewController *viewController;
        if([strSelectRow isEqualToString:@"Home"])
        {
            HomeViewController *homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
            viewController = homeViewController;
        }
        else if([strSelectRow isEqualToString:@"Shop By Category"])
        {
            AllCategoriesViewController *allCategoriesViewController = [[AllCategoriesViewController alloc] initWithNibName:@"AllCategoriesViewController" bundle:nil];
            viewController = allCategoriesViewController;
        }
        else if([strSelectRow isEqualToString:@"Wish List"])
        {
            WishlistViewController *wishlistViewController = [[WishlistViewController alloc] initWithNibName:@"WishlistViewController" bundle:nil];
            viewController = wishlistViewController;
        }
        else if([strSelectRow isEqualToString:@"My Profile"])
        {
            UserProfileViewController *userProfileViewController = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
            viewController = userProfileViewController;
        }
        else if([strSelectRow isEqualToString:@"My Orders"])
        {
            OrderListViewController *orderListViewController = [[OrderListViewController alloc] initWithNibName:@"OrderListViewController" bundle:nil];
            viewController = orderListViewController;
        }
        else if([strSelectRow isEqualToString:@"Change Password"])
        {
            ChangePasswordViewController *changePasswordViewController = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordViewController" bundle:nil];
            viewController = changePasswordViewController;
        }
        else if([strSelectRow isEqualToString:@"About PykLocal"])
        {
            AbouViewController *abouViewController = [[AbouViewController alloc] initWithNibName:@"AbouViewController" bundle:nil];
            viewController = abouViewController;
        }
        else if([strSelectRow isEqualToString:@"Login"])
        {
            LoginSignUpViewController *loginSignUpViewController = [[LoginSignUpViewController alloc] initWithNibName:@"LoginSignUpViewController" bundle:nil];
            viewController = loginSignUpViewController;
        }
        else if([strSelectRow isEqualToString:@"Logout"])
        {
            NSString *strAlertTitle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:strAlertTitle
                                                         message:@"Are you sure you want to logout?"
                                                        delegate:self
                                               cancelButtonTitle:@"No"
                                               otherButtonTitles:@"Yes",nil];
            [alert setTag:1];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            return;
        }
        else
        {
            ComingSoonViewController *comingSoonViewController = [[ComingSoonViewController alloc] initWithNibName:@"ComingSoonViewController" bundle:nil];
            viewController = comingSoonViewController;
        }
        
        
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:viewController];
        navigationController.viewControllers = controllers;
        
        index = (int)indexPath.row;
    }
    [tblSliderList setContentOffset:CGPointMake(0, -64) animated:YES];
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}


#pragma mark - UIAlertView Delegate Methods -

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1 )
    {
        if(buttonIndex == 1)
        {
            if([common checkInternetConnection:TRUE ViewController:self.navigationController])
            {
                [SVProgressHUD show];
                
                NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Sessions];
                
                NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
                [dicPostData setObject:@"true" forKey:@"is_guest"];
                [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
                [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
                [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
                
                [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Sessions HTTPMethod:@"POST" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
            }
        }
    }
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
                    [prefs setObject:@"" forKey:@"email"];
                    [prefs setObject:@"1" forKey:@"is_guest"];
                    [prefs synchronize];
                                        
                    HomeViewController *homeViewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
                    
                    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                    NSArray *controllers = [NSArray arrayWithObject:homeViewController];
                    navigationController.viewControllers = controllers;
                    
                    index = 0;
                    
                    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
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
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            break;
        default:
            break;
            
    }
}

@end
