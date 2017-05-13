//
//  SearchViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 11/09/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "SearchViewController.h"
#import "ProductListViewController.h"

@interface SearchViewController ()<UINavigationBarDelegate>
{
    AppDelegate *appDelegate;
    Common *common;
    BarcodeScannerViewController *barcodeScannerViewController;

    NSUserDefaults *prefs;
    NSMutableArray *arrSearchList;
    
    BOOL isScanned;
    BOOL isLoad;
}
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Mange Slider
    appDelegate.isHandlePan = FALSE;
    
    //Mange NavigationBar With Cart Count
    [self setNavigationBar:appDelegate.strCartCount];
    
//    if(!isLoad)
//    {
        [tfSearch becomeFirstResponder];
//        isLoad = TRUE;
//    }
    
    [self getAllRecordForSearch];
    
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
    self.navigationItem.title = @"Search";

    
    UIImage *imgBack = [UIImage imageNamed:@"Img-Back.png"];
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonBack.frame = CGRectMake(0,0,imgBack.size.width+50, imgBack.size.height);
    [buttonBack addTarget:self action:@selector(performBackNavigation:) forControlEvents:UIControlEventTouchDown];
    [buttonBack setImage:imgBack forState:UIControlStateNormal];
    [buttonBack setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];

    // Make BarButton Item
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:btnBack, nil]];
    
    
    UIImage *imgWish = [UIImage imageNamed:@"Img-TopWish.png"];
    UIButton *buttonWish = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonWish.frame = CGRectMake(0,0,imgWish.size.width, imgWish.size.height);
    [buttonWish addTarget:self action:@selector(btnWishListPressed:) forControlEvents:UIControlEventTouchDown];
    [buttonWish setBackgroundImage:imgWish forState:UIControlStateNormal];
    
    // Make BarButton Item
    UIBarButtonItem *btnWish = [[UIBarButtonItem alloc] initWithCustomView:buttonWish];
    //btnWish.badgeValue = strCartValue;
    
    UIImage *img = [UIImage imageNamed:@"Img-Cart.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,img.size.width, img.size.height);
    [button addTarget:self action:@selector(btnCartPressed:) forControlEvents:UIControlEventTouchDown];
    [button setBackgroundImage:img forState:UIControlStateNormal];
    
    // Make BarButton Item
    UIBarButtonItem *btnCart = [[UIBarButtonItem alloc] initWithCustomView:button];
    btnCart.badgeValue = strCartValue;
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnCart,btnWish, nil]];
}

#pragma mark - UIBarButtonItem Callbacks -

- (void)leftSideMenuButtonPressed:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view endEditing:TRUE];
    }completion:^(BOOL finished) {
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

#pragma mark - IBAction Method -

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

- (void)performBackNavigation:(id)sender
{
    [tfSearch setText:@""];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - UITextField Delegate Methods -

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    tfSearch.text = [tfSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(tfSearch.text.length)
    {
        [self.view endEditing:TRUE];
        return TRUE;
    }
    else
        return FALSE;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    tfSearch.text = [tfSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(tfSearch.text.length)
    {
        [self insertRecordForSearch];
        
        ProductListViewController *productListViewController = [[ProductListViewController alloc]initWithNibName:@"ProductListViewController" bundle:nil];
        productListViewController.strTitle = [tfSearch.text capitalizedString];
        productListViewController.strId = @"";
        productListViewController.strSearch = tfSearch.text;
        [self.navigationController pushViewController:productListViewController animated:YES];
    }
}

#pragma mark - UITable View Delegate Methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([arrSearchList count])
        [tblSearchList setHidden:FALSE];
    else
        [tblSearchList setHidden:TRUE];
    
    return arrSearchList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    
    cell.textLabel.text = [arrSearchList objectAtIndex:indexPath.row];
    
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteRecordForProduct:[arrSearchList objectAtIndex:indexPath.row]];
        [arrSearchList removeObjectAtIndex:indexPath.row];
        
        if([arrSearchList count])
            [tblSearchList setHidden:FALSE];
        else
            [tblSearchList setHidden:TRUE];
//        [tableView reloadData];
    }
}


//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return heightForFooter;//256
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tfSearch.text = [arrSearchList objectAtIndex:indexPath.row];
    [self.view endEditing:TRUE];
}


#pragma mark - Database Operations -

- (void)insertRecordForSearch
{
    sqlite3_stmt *statement;
    
    NSString *insertSQL = [NSString stringWithFormat:@"insert or replace into search values(\"%@\")",tfSearch.text];
    
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
}

- (NSMutableArray *)getAllRecordForSearch
{
    NSString *strGetDataQuery = [NSString stringWithFormat:@"select searchkey from search ORDER BY rowid DESC"];
    
    const char *getData = (const char *) [strGetDataQuery UTF8String];
    
    sqlite3_stmt *stmt_Get = nil;
    
    arrSearchList = [[NSMutableArray alloc]init];
    
    if(sqlite3_prepare_v2(appDelegate.dbPykLocal, getData, -1, &stmt_Get, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt_Get) == SQLITE_ROW)
        {
            if(sqlite3_column_text(stmt_Get, 0) != nil)
                [arrSearchList addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt_Get, 0)]];
            else
                [arrSearchList addObject:@""];
        }
    }
    else
    {
        NSLog(@"Error While Reading Data For search :- '%s'",sqlite3_errmsg(appDelegate.dbPykLocal));
    }
    
    sqlite3_finalize(stmt_Get);
    
    [tblSearchList reloadData];
    return arrSearchList;
}

- (void)deleteRecordForProduct:(NSString *)strSearchKey
{
    
    const char *deleteQuery = "delete from search where searchkey = ?";
    
    sqlite3_stmt *stmt_delete;
    
    if(sqlite3_prepare_v2(appDelegate.dbPykLocal, deleteQuery, -1, &stmt_delete, NULL) != SQLITE_OK)
    {
        sqlite3_finalize(stmt_delete);
    }
    
    sqlite3_bind_text(stmt_delete, 1, [strSearchKey UTF8String], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE != sqlite3_step(stmt_delete))
    {
        sqlite3_finalize(stmt_delete);
    }
    
    //NSLog(@"Record Deleted Successfully.");
    sqlite3_finalize(stmt_delete);
}

@end
