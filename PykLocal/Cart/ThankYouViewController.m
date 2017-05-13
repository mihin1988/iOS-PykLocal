//
//  ThankYouViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 25/12/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "ThankYouViewController.h"
#import "HomeViewController.h"

@interface ThankYouViewController ()
{
    AppDelegate *appDelegate;
    Common *common;
    
    NSUserDefaults *prefs;
}
@end

@implementation ThankYouViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    
    [lblOrdernumber setText:[NSString stringWithFormat:@"Your order %@",_strOrderNumber]];
    
    [btnViewYourOrder.layer setBorderColor:[[RGB colorWithAlphaComponent:1.0] CGColor]];
    [btnViewYourOrder.layer setBorderWidth:0.5];
    btnViewYourOrder.layer.cornerRadius = 15;
    btnViewYourOrder.clipsToBounds = YES;

    btnContinueShopping.layer.cornerRadius = 5.0;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Mange Slider
    appDelegate.isHandlePan = FALSE;
    
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
    self.navigationItem.hidesBackButton = YES;
    
    [self.navigationController setNavigationBarHidden:FALSE];
    self.navigationItem.title = @"Order Confirmed";
    
}

#pragma mark - IBAction Method -

-(IBAction)btnContinueShoppingPressed:(UIButton *)sender
{
    NSArray *arrControllers = [self.navigationController viewControllers];
    for(int j= 0 ; j<arrControllers.count ; j++)
    {
        if([[arrControllers objectAtIndex:j] isKindOfClass:[HomeViewController class]])
        {
            appDelegate.isEmptyCart = TRUE;
            [self.navigationController popToViewController:[arrControllers objectAtIndex:j] animated:YES];
            break;
        }
    }
}

//-(IBAction)btnContinueShoppingPressed:(UIButton *)sender
//{
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

@end
