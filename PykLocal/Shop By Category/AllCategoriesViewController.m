//
//  AllCategoriesViewController.m
//  QuickeSelling
//
//  Created by Saket Singhi on 27/11/15.
//  Copyright © 2015 JVSGroup. All rights reserved.
//

#import "AllCategoriesViewController.h"
#import "ProductListViewController.h"
#import "ProductListViewController.h"

//#import <SVProgressHUD.h>
//#import <Google/Analytics.h>

#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)

@interface AllCategoriesViewController ()
{
    AppDelegate *appDelegate;
    Common *common;
    BarcodeScannerViewController *barcodeScannerViewController;

    NSUserDefaults *prefs;
    NSString *strScreenTitle;
    
    BOOL isScanned;
}
@end

@implementation AllCategoriesViewController

@synthesize tblList;

@synthesize firstArray;
@synthesize firstForTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [tblList.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:1.0] CGColor]];
    [tblList.layer setBorderWidth:1.0];
    tblList.layer.cornerRadius = 5.0;
    tblList.clipsToBounds = YES;
    
    tblList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        [SVProgressHUD show];
        
        NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Categories];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Categories HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Mange Slider
    appDelegate.isHandlePan = TRUE;
    
    //Mange NavigationBar With Cart Count
    [self setNavigationBar:appDelegate.strCartCount];
    
    if(isScanned && [[prefs objectForKey:@"scanCode"] length])
    {
        sqlite3_stmt *statement;
        
        NSString *insertSQL = [NSString stringWithFormat:@"insert or replace into search values(\"%@\")",[prefs objectForKey:@"scanCode"]];
        
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(appDelegate.dbPykLocal, insert_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            sqlite3_bind_text(statement, 1, [insertSQL UTF8String], -1, SQLITE_TRANSIENT);
            NSLog(@"Search Inserted Successfully.");
            
        }
        else
        {
            NSLog(@"Error while Insert Search :- '%s'", sqlite3_errmsg(appDelegate.dbPykLocal));
        }
        sqlite3_finalize(statement);
        
        ProductListViewController *productListViewController = [[ProductListViewController alloc]initWithNibName:@"ProductListViewController" bundle:nil];
        productListViewController.strTitle = @"Search Product";
        productListViewController.strId = @"";
        productListViewController.strSearch = [prefs objectForKey:@"scanCode"];
        [self.navigationController pushViewController:productListViewController animated:YES];
        
        [prefs setObject:@"" forKey:@"scanCode"];
        [prefs synchronize];
        isScanned = FALSE;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    self.navigationItem.titleView = logoView;
    
    UIImage *img;
    UIButton *button;
    
    UIBarButtonItem *btnLeft = [[UIBarButtonItem alloc]
                                initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
                                target:self action:@selector(leftSideMenuButtonPressed:)];
    
//    img = [UIImage imageNamed:@"Img-Logo.png"];
//    button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake(0,0,65, 44);
//    [button setBackgroundImage:img forState:UIControlStateNormal];
//
//    UIBarButtonItem *btnLogo = [[UIBarButtonItem alloc] initWithCustomView:button];
//    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:btnLeft, btnLogo, nil]];

    
    [self.navigationItem setLeftBarButtonItem:btnLeft];

    UIImage *imgWish = [UIImage imageNamed:@"Img-TopWish.png"];
    UIButton *buttonWish = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonWish.frame = CGRectMake(0,0,imgWish.size.width, imgWish.size.height);
    [buttonWish addTarget:self action:@selector(btnWishListPressed:) forControlEvents:UIControlEventTouchDown];
    [buttonWish setBackgroundImage:imgWish forState:UIControlStateNormal];
    
    // Make BarButton Item
    UIBarButtonItem *btnWish = [[UIBarButtonItem alloc] initWithCustomView:buttonWish];
    //btnWish.badgeValue = strCartValue;

    
    img = [UIImage imageNamed:@"Img-Cart.png"];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,img.size.width, img.size.height);
    [button addTarget:self action:@selector(btnCartPressed:) forControlEvents:UIControlEventTouchDown];
    [button setBackgroundImage:img forState:UIControlStateNormal];
    
    // Make BarButton Item
    UIBarButtonItem *btnCart = [[UIBarButtonItem alloc] initWithCustomView:button];
    btnCart.badgeValue = strCartValue;
    
    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(btnSearchPressed:)];
    btnSearch.imageInsets = UIEdgeInsetsMake(0, 8, 0, -10);

    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnCart,btnWish, nil]];
}

#pragma mark - UIBarButtonItem Callbacks -

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}

#pragma mark - IBAction Method -

-(IBAction)btnSearchPressed:(UIButton *)sender
{
    SearchViewController *searchViewController = [[SearchViewController alloc]initWithNibName:@"SearchViewController" bundle:nil];
    [self.navigationController pushViewController:searchViewController animated:NO];
}

-(IBAction)btnCartPressed:(UIButton *)sender
{
    CartViewController *cartViewController = [[CartViewController alloc]initWithNibName:@"CartViewController" bundle:nil];
    [self.navigationController pushViewController:cartViewController animated:YES];
}

-(IBAction)btnWishListPressed:(UIButton *)sender
{
    WishlistViewController *wishlistViewController = [[WishlistViewController alloc]initWithNibName:@"WishlistViewController" bundle:nil];
    wishlistViewController.back = TRUE;
    [self.navigationController pushViewController:wishlistViewController animated:YES];
}


-(IBAction)btnBarocdeScanPressed:(UIButton *)sender
{
    isScanned = TRUE;
    barcodeScannerViewController = [[BarcodeScannerViewController alloc]initWithNibName:@"BarcodeScannerViewController" bundle:nil];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:barcodeScannerViewController];
    [self presentViewController:navigationController animated:YES completion:^{}];
}

#pragma mark - UITable View Delegate Methods -

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}


// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.firstForTable count];
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 46.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"All Categories";
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
    [viewHeader  setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]];
    
    
    UIButton *btnIcon = [[UIButton alloc]initWithFrame:CGRectMake(10, 13, 20, 20)];
    [btnIcon setImage:[UIImage imageNamed:@"Img-Menu-Categories.png"] forState:UIControlStateNormal];
    [viewHeader addSubview:btnIcon];
    
    UILabel * sectionHeader = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.view.frame.size.width-15, 46)];
    sectionHeader.backgroundColor = [UIColor clearColor];
    sectionHeader.font = [UIFont boldSystemFontOfSize:16];
    sectionHeader.text = @"All Categories";
    [viewHeader addSubview:sectionHeader];
    
    UILabel * lblStrip = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, tblList.frame.size.width, 1)];
    lblStrip.backgroundColor = [UIColor lightGrayColor];
    [viewHeader addSubview:lblStrip];
    
    return viewHeader;
    
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
 
//    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    cell.textLabel.text=[[self.firstForTable objectAtIndex:indexPath.row] valueForKey:@"name"];
    [cell setIndentationLevel:[[[self.firstForTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue]-1];

    
    UIButton *btnIcon = [[UIButton alloc]initWithFrame:CGRectMake(tableView.frame.size.width-37, 4, 36, 36)];
    [btnIcon setUserInteractionEnabled:FALSE];
    [btnIcon setTag:100];

    if([[[self.firstForTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue]-1 >= 1)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]];
    }
    
    NSDictionary *d=[self.firstForTable objectAtIndex:indexPath.row];
    NSMutableArray *arr = [[d valueForKey:@"sub_category"] mutableCopy];

    if([[d valueForKey:@"status"] isEqualToString:@"T"])
        [btnIcon setImage:[UIImage imageNamed:@"Img-Accessory-Down.png"] forState:UIControlStateNormal];
    else
        [btnIcon setImage:[UIImage imageNamed:@"Img-Accessory-Right.png"] forState:UIControlStateNormal];
    
    if([arr count])
        [cell.contentView addSubview:btnIcon];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tblList cellForRowAtIndexPath:indexPath];
    
    UIButton *btnIcon = (UIButton *)[cell viewWithTag:100];

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __block NSDictionary *d=[self.firstForTable objectAtIndex:indexPath.row];

    if([[d valueForKey:@"sub_category"] count]) {
        NSArray *ar=[d valueForKey:@"sub_category"];
        
        BOOL isAlreadyInserted=NO;
        
        for(NSDictionary *dInner in ar ){
            NSInteger index=[self.firstForTable indexOfObjectIdenticalTo:dInner];
            isAlreadyInserted=(index>0 && index!=NSIntegerMax);
            if(isAlreadyInserted) break;
        }
        
        if(isAlreadyInserted)
        {
//            dispatch_async(dispatch_get_main_queue(), ^{
            
                [UIView animateWithDuration:0.2 animations:^{
                    btnIcon.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
                }completion:^(BOOL finished) {
                    
                    d = [self changeStatus:d];
                    
                    [d setValue:@"F" forKey:@"status"];
                    [self.firstForTable replaceObjectAtIndex:indexPath.row withObject:d];
                    [self miniMizeFirstsRows:ar];
                }];
            
//            });
        
        } else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 animations:^{
                    btnIcon.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
                }completion:^(BOOL finished) {
                    [d setValue:@"T" forKey:@"status"];
                    [self.firstForTable replaceObjectAtIndex:indexPath.row withObject:d];
                }];
            });
            
            
            NSUInteger count=indexPath.row+1;
            NSMutableArray *arCells=[NSMutableArray array];
            for(NSDictionary *dInner in ar ) {
                [arCells addObject:[NSIndexPath indexPathForRow:count inSection:0]];
                [self.firstForTable insertObject:dInner atIndex:count++];
            }
            
            [tableView insertRowsAtIndexPaths:arCells withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }else
    {
        ProductListViewController *productListViewController = [[ProductListViewController alloc]initWithNibName:@"ProductListViewController" bundle:nil];
        productListViewController.strTitle = [d valueForKey:@"name"];
        productListViewController.strId = [d valueForKey:@"id"];
        productListViewController.strSearch = @"";
        [self.navigationController pushViewController:productListViewController animated:YES];

        NSLog(@"Leave Element:::%@",[d valueForKey:@"name"]);
    }
}

#pragma mark - Helper Method -

- (NSDictionary *)changeStatus:(NSDictionary *)dic
{
    NSMutableArray *arr = [[dic valueForKey:@"sub_category"] mutableCopy];
    if([arr count])
    {
        for(int i = 0 ; i < [arr count] ; i++)
        {
            NSDictionary *d = [arr objectAtIndex:i];
            [d setValue:@"F" forKey:@"status"];
            [self changeStatus:d];
        }
    }
    else
        [dic setValue:@"F" forKey:@"status"];

    return dic;
}

- (void)miniMizeFirstsRows:(NSArray*)ar{
    
    for(NSDictionary *dInner in ar ) {
        
        NSUInteger indexToRemove=[self.firstForTable indexOfObjectIdenticalTo:dInner];
        NSArray *arInner=[dInner valueForKey:@"sub_category"];
        if(arInner && [arInner count]>0){
            [self miniMizeFirstsRows:arInner];
        }
        
        if([self.firstForTable indexOfObjectIdenticalTo:dInner]!=NSNotFound) {
            [self.firstForTable removeObjectIdenticalTo:dInner];
            
            
            [UIView animateWithDuration:0.2 animations:^{
                [tblList beginUpdates];
                
                [tblList deleteRowsAtIndexPaths:[NSArray arrayWithObject:
                                                 [NSIndexPath indexPathForRow:indexToRemove inSection:0]
                                                 ]
                               withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [tblList endUpdates];
            } completion:^(BOOL finished) {
                [tblList reloadData];
            }];
            
            
            
        }
    }
}

#pragma mark - WebAPI Response -

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther
{
    switch (tag)
    {
        case 4:
            //Categories
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    self.firstArray = [dicResponse valueForKey:@"details"];
                    
                    self.firstForTable = [[NSMutableArray alloc] init] ;
                    [self.firstForTable addObjectsFromArray:self.firstArray];
                    
                    [tblList reloadData];
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
