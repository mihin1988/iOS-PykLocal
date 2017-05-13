//
//  FilterViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 11/09/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "FilterViewController.h"
#import "Attributes.h"
#import "Values.h"
#import "CategoryProductDetails.h"

@interface FilterViewController ()
{
    AppDelegate *appDelegate;
    Attributes *attributes;
    Values *values;
    CategoryProductDetails *categoryProductDetails;
    
    NSMutableArray *arrValues;
    
    BOOL isReset;
}

@end

@implementation FilterViewController

@synthesize tblAttributes;
@synthesize tblValues;
@synthesize btnCancel;
@synthesize btnApply;

@synthesize arrAttributes;
@synthesize arrFilteredAttribute;

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
   
    [tblAttributes setAutoresizesSubviews:NO];
    [tblAttributes selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Mange Slider
    appDelegate.isHandlePan = FALSE;
    
    //Mange NavigationBar With Cart Count
    [self setNavigationBar:appDelegate.strCartCount];
    
    [btnApply setBackgroundColor:RGB];
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
    self.navigationItem.title = @"Filter";
    
    UIBarButtonItem *btnBarCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnCancelPressed:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnBarCancel, nil]];
}



#pragma mark - IBAction Method -

-(IBAction)btnCancelPressed:(UIButton *)sender
{
    if(isReset)
        [delegate filteredData:arrFilteredAttribute ISReset:TRUE];
        
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)btnApplyPressed:(UIButton *)sender
{
    [delegate filteredData:arrFilteredAttribute ISReset:FALSE];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)btnResetPressed:(UIButton *)sender
{
    NSString *strAlertTitle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:strAlertTitle
                                                 message:@"Would you like to reset the filters? "
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Reset",nil];
    [alert show];
}

#pragma mark - UIAlertView Delegate Methods -

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        for(int i = 0 ; i<[arrFilteredAttribute count] ; i++)
        {
            NSMutableDictionary *dicFilteredAttribut = [[arrFilteredAttribute objectAtIndex:i]mutableCopy];
            for(int j = 0 ; j < [[dicFilteredAttribut objectForKey:@"list"] count] ; j++)
            {
                [[dicFilteredAttribut objectForKey:@"list"] replaceObjectAtIndex:j withObject:@"0"];
            }
        }
        
        isReset = TRUE;
        [tblValues reloadData];
    }
}


#pragma mark - UITable View Delegate Methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == tblValues)
    {
        NSIndexPath *selectedIndex = tblAttributes.indexPathForSelectedRow;

        return [[[arrAttributes objectAtIndex:selectedIndex.row] objectForKey:@"list"] count];
    }
    else
        return [arrAttributes count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tblValues)
        return 36;
    else
        return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UITableViewCell *cell;
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    if(tableView == tblValues)
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        NSIndexPath *selectedIndex = tblAttributes.indexPathForSelectedRow;
        
        {
            UILabel *lblCategoryName = [[UILabel alloc]initWithFrame:CGRectMake(15, 0 , self.tblValues.frame.size.width-55, 44)];
            [lblCategoryName setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
            [lblCategoryName setText:[[[arrAttributes objectAtIndex:selectedIndex.row] objectForKey:@"list"] objectAtIndex:indexPath.row]];
            [cell.contentView addSubview:lblCategoryName];
            
            UIButton *btnSelected = [[UIButton alloc]initWithFrame:CGRectMake(self.tblValues.frame.size.width-40, 3, 30, 30)];
            if([[[[arrFilteredAttribute objectAtIndex:selectedIndex.row] objectForKey:@"list"] objectAtIndex:indexPath.row] isEqualToString:@"1"])
                [btnSelected setImage:[UIImage imageNamed:@"Img-Checked-Button.png"] forState:UIControlStateNormal];
            else
                [btnSelected setImage:[UIImage imageNamed:@"Img-Unchecked-Radio-Button.png"] forState:UIControlStateNormal];
            
            [btnSelected setUserInteractionEnabled:FALSE];
            [cell.contentView addSubview:btnSelected];
        }
    }
    else
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [cell setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0]];
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
        
    
        UILabel *lblAttribute = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width-(tblValues.frame.size.width+15), 44)];
        [lblAttribute setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12]];
        [lblAttribute setNumberOfLines:2];
        [lblAttribute setTextColor:[UIColor darkGrayColor]];
        [lblAttribute setText:[[arrAttributes objectAtIndex:indexPath.row] objectForKey:@"name"]];
        [cell.contentView addSubview:lblAttribute];
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tblValues)
    {
        NSIndexPath *selectedIndex = tblAttributes.indexPathForSelectedRow;

        
        values = [arrValues objectAtIndex:indexPath.row];
        
        if([[[[arrFilteredAttribute objectAtIndex:selectedIndex.row] objectForKey:@"list"] objectAtIndex:indexPath.row] isEqualToString:@"1"])
            [[[arrFilteredAttribute objectAtIndex:selectedIndex.row] objectForKey:@"list"] replaceObjectAtIndex:indexPath.row withObject:[[[arrAttributes objectAtIndex:selectedIndex.row] objectForKey:@"list"] objectAtIndex:indexPath.row]];
        else
            [[[arrFilteredAttribute objectAtIndex:selectedIndex.row] objectForKey:@"list"] replaceObjectAtIndex:indexPath.row withObject:@"1"];
        
        [tblValues reloadData];
        
    }
    else
    {
        [tblValues reloadData];
    }
}
@end
