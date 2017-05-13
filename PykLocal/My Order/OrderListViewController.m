//
//  OrderListViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 03/01/17.
//  Copyright © 2017 Mihin  Patel. All rights reserved.
//

#import "OrderListViewController.h"
#import "OrderListTableViewCell.h"
#import "OrderDetailViewController.h"

@interface OrderListViewController ()<OrderDetailViewDelegate>
{
    AppDelegate *appDelegate;
    Common *common;
    
    NSUserDefaults *prefs;
    NSMutableArray *arrOrderList;
    
    int selectedIndex;
}
@end

@implementation OrderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    arrOrderList = [[NSMutableArray alloc]init];
    
    [SVProgressHUD show];
    [self getOrderList];
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
    self.navigationItem.title = @"My Order";
    
    UIBarButtonItem *btnLeft = [[UIBarButtonItem alloc]
                                initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
                                target:self action:@selector(leftSideMenuButtonPressed:)];
    [self.navigationItem setLeftBarButtonItem:btnLeft];
}

- (void)getOrderList
{
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        NSString *strURL = [NSString stringWithFormat:@"%@users/%@/get_orders",WS_BaseUrl,[prefs objectForKey:@"token"]];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:GetOrders HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
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
    return arrOrderList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    static NSString *CellIdentifier = @"OrderListTableViewCell";
    
    OrderListTableViewCell *orderListTableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (orderListTableViewCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OrderListTableViewCell" owner:self options:nil];
        orderListTableViewCell = [nib objectAtIndex:0];
    }
    
    [orderListTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
  
    NSMutableDictionary *dicOrder = [arrOrderList objectAtIndex:indexPath.row];
    
    [orderListTableViewCell.lblDate setText:[dicOrder objectForKey:@"order_date"]];
    [orderListTableViewCell.lblNumber setText:[dicOrder objectForKey:@"order_number"]];
    [orderListTableViewCell.lblTotal setText:[NSString stringWithFormat:@"%@",[appDelegate numberFormatter:[NSString stringWithFormat:@"%.2f",([[[[dicOrder objectForKey:@"adjustments"] objectAtIndex:0] objectForKey:@"subtotal"] doubleValue])] CurrencySymbol:appDelegate.strCurrencySymbol]]];

    
    return orderListTableViewCell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderDetailViewController *orderDetailViewController = [[OrderDetailViewController alloc]initWithNibName:@"OrderDetailViewController" bundle:nil];
    [orderDetailViewController setDelegate:self];
    orderDetailViewController.dicOrderDetails = [[arrOrderList objectAtIndex:indexPath.row]mutableCopy];
    selectedIndex = (int)indexPath.row;
    [self.navigationController pushViewController:orderDetailViewController animated:YES];
}

#pragma mark - OrderDetailViewDelegate Method -

- (void)cancelOrder:(NSMutableDictionary *)dicOrderDetail
{
    [arrOrderList replaceObjectAtIndex:selectedIndex withObject:dicOrderDetail];
    [tblOrderList reloadData];
}

#pragma mark - WebAPI Response -

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther
{
    switch (tag)
    {
        case 34:
            //GetOrders
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    arrOrderList = [[dicResponse objectForKey:@"detail"]mutableCopy];
                    [tblOrderList setHidden:FALSE];
                    [tblOrderList reloadData];
                }
            }
            break;
            
        default:
            break;
            
    }
}

@end
