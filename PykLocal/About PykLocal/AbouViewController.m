//
//  AbouViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 22/12/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "AbouViewController.h"
#import "WebPageViewController.h"

@interface AbouViewController ()
{
    AppDelegate *appDelegate;
    Common *common;
    
    NSUserDefaults *prefs;
    
    NSMutableArray *arrPages;
    
}
@end

@implementation AbouViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    
    arrPages = [[NSMutableArray alloc]init];
    [self getAboutPykLocal];
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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    [self.navigationController setNavigationBarHidden:FALSE];
    
    UIButton *logoView = [[UIButton alloc] initWithFrame:CGRectMake(0,0,60,60)];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,60,60)];
    image.contentMode = UIViewContentModeScaleAspectFit;
    [image setImage: [UIImage imageNamed:@"Img-Logo.png"]];
    [logoView addSubview:image];
    [logoView setUserInteractionEnabled:NO];
    //    self.navigationItem.titleView = logoView;
    self.navigationItem.title = @"About PykLocal";
    
    UIBarButtonItem *btnLeft = [[UIBarButtonItem alloc]
                                initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
                                target:self action:@selector(leftSideMenuButtonPressed:)];
    [self.navigationItem setLeftBarButtonItem:btnLeft];
    
}

- (void)getAboutPykLocal
{
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        [SVProgressHUD show];
        NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Pages];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        
        [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:Pages HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
    
}

#pragma mark - UIBarButtonItem Callbacks -

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}

#pragma mark - UITableView Method -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrPages.count;
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
    
    NSMutableDictionary *dicPages = [arrPages objectAtIndex:indexPath.row];
    [cell.textLabel setText:[dicPages objectForKey:@"title"]];
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSMutableDictionary *dicPages = [arrPages objectAtIndex:indexPath.row];
    
    WebPageViewController *webPageViewController = [[WebPageViewController alloc]initWithNibName:@"WebPageViewController" bundle:nil];
    
    webPageViewController.strTitle = [dicPages objectForKey:@"title"];
    webPageViewController.strText = [dicPages objectForKey:@"body"];
    [self.navigationController pushViewController:webPageViewController animated:YES];
}

#pragma mark - WebAPI Response -

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther
{
    switch (tag)
    {
        case 27:
            //Pages
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    arrPages = [[dicResponse objectForKey:@"details"] mutableCopy];
                    [tblList setHidden:FALSE];
                    [tblList reloadData];
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
