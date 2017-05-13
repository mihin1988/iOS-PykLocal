//
//  RatingViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 15/11/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "RatingViewController.h"
#import "RatingViewCell.h"

@interface RatingViewController ()
{
    AppDelegate *appDelegate;
    Common *common;
    RatingViewCell *ratingViewCell;

    NSUserDefaults *prefs;
    NSIndexPath *selectedIndexPath;
    NSMutableArray *arrReviews;
    
    float height;
    CGRect frameLblDiscription;
}
@end

@implementation RatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];

    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        [SVProgressHUD show];
        NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Ratings_Reviews];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];

        [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
        [dicPostData setObject:_strId forKey:@"product_id"];

        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        [common webAPIAFRequest:self URL:strURL POSTDATA:dicPostData TAG:Ratings_Reviews HTTPMethod:@"GET" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    
    //Mange Slider
    appDelegate.isHandlePan = FALSE;
    
    //Mange NavigationBar With Cart Count
    [self setNavigationBar:appDelegate.strCartCount];
}

#pragma mark - Helper Method -

- (void)setNavigationBar:(NSString *)strCartValue
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.navigationItem.title = @"Rating & Reviews";
}

#pragma mark - UITable View Delegate Methods -


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrReviews count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath == selectedIndexPath)
        return height;
    else
        return 113;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    static NSString *CellIdentifier = @"RatingViewCell";
    
    ratingViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (ratingViewCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RatingViewCell" owner:self options:nil];
        ratingViewCell = [nib objectAtIndex:0];
    }
    
    [ratingViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSMutableDictionary *dicReviews = [arrReviews objectAtIndex:indexPath.row];
    
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    
    NSDate *date = [format dateFromString:[dicReviews objectForKey:@"date"]];
    [format setDateFormat:@"MMM dd, yyyy"];
    
    ratingViewCell.lblDate.text = [format stringFromDate:date];
    [ratingViewCell.btnRate setTitle:[dicReviews objectForKey:@"rating"] forState:UIControlStateNormal];
    ratingViewCell.lblComment.text = [dicReviews objectForKey:@"comment"];
    ratingViewCell.lblName.text = [NSString stringWithFormat:@"By %@ %@",[dicReviews objectForKey:@"first_name"],[dicReviews objectForKey:@"Last_name"]];
    
    if([[dicReviews objectForKey:@"rating"] integerValue] <= 1)
        [ratingViewCell.btnRate setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]];
    else if([[dicReviews objectForKey:@"rating"] integerValue] <= 2)
        [ratingViewCell.btnRate setBackgroundColor:[UIColor colorWithRed:232.0/255.0 green:120.0/255.0 blue:20.0/255.0 alpha:1.0]];
    else
        [ratingViewCell.btnRate setBackgroundColor:[UIColor colorWithRed:23.0/255.0 green:114/255.0 blue:69.0/255.0 alpha:1.0]];
    
    ratingViewCell.btnRate.layer.cornerRadius = 5.0;
    [ratingViewCell.btnMoreLess setTintColor:RGB];
    
    CGRect frame = ratingViewCell.lblComment.frame;
    
    //    [ratingViewCell.lblDiscription setNumberOfLines:0];
    [ratingViewCell.lblComment sizeToFit];
    
    CGRect newFrame = ratingViewCell.lblComment.frame;
    
    if(selectedIndexPath != indexPath)
        ratingViewCell.lblComment.frame = frame;
    else
    {
        frameLblDiscription.size.width = frame.size.width;
        [ratingViewCell.lblComment setFrame:frameLblDiscription];
        [ratingViewCell.btnMoreLess setTitle:@"- Read Less" forState:UIControlStateNormal];
    }
    
    if(newFrame.size.height>40)
    {
        [ratingViewCell.btnMoreLess setHidden:FALSE];
    }
    else
    {
        [ratingViewCell.btnMoreLess setHidden:TRUE];
    }
    
    
    return ratingViewCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RatingViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if([cell.btnMoreLess isHidden])
        return;
    
    [cell.lblComment sizeToFit];
    
    frameLblDiscription = cell.lblComment.frame;
    
    height = 100+cell.lblComment.frame.size.height;
    [cell.btnMoreLess setTitle:@"- Read Less" forState:UIControlStateNormal];
    
    if(selectedIndexPath)
    {
        cell = [tableView cellForRowAtIndexPath:selectedIndexPath];
        CGRect frame = cell.lblComment.frame;
        frame.size.height = 40;
        cell.lblComment.frame = frame;
        [cell.btnMoreLess setTitle:@"+ Read More" forState:UIControlStateNormal];
    }
    
    if(selectedIndexPath == indexPath)
        selectedIndexPath = nil;
    else
        selectedIndexPath = indexPath;
    [self mangeCell:indexPath];
}

#pragma mark - Helper Method -

- (void)mangeCell:(NSIndexPath *)indexPath
{
    [tblRating beginUpdates];
    [tblRating endUpdates];
}

#pragma mark - WebAPI Response -

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther
{
    switch (tag)
    {
            
        case 14:
            //Ratings_Reviews
            
            [SVProgressHUD dismiss];
            
            if(data)
            {
                NSDictionary *dicResponse = [data JSONValue];
                if ([[dicResponse objectForKey:@"status"] intValue] == 1)
                {
                    arrReviews = [[NSMutableArray alloc]init];
                    arrReviews = [[dicResponse objectForKey:@"rating_details"]mutableCopy];
                    if([arrReviews count])
                    {
                        [tblRating setHidden:FALSE];
                        [tblRating reloadData];
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
            
        default:
            break;
            
    }
}
@end
