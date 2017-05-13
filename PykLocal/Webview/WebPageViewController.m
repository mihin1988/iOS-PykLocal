//
//  WebPageViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 12/11/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "WebPageViewController.h"

@interface WebPageViewController ()
{
    AppDelegate *appDelegate;
    
    NSUserDefaults *prefs;

}
@end

@implementation WebPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];

    [SVProgressHUD show];

    if([_strText length])
    {
        NSString *strTAndC = [NSString stringWithFormat:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"> <html xmlns=\"http://www.w3.org/1999/xhtml\"> <head> <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/> <title>Untitled Document</title> </head> <body> <div style=\"width:100%%; border:1px; font-family:Helvetica; font-size:14px;\"> %@ </div> </body> </head> </html>", _strText];
        
        [wvPage loadHTMLString:strTAndC baseURL:nil];
    }
    else
    {
        NSURL *nsurl = [NSURL URLWithString:_strURL];
        NSURLRequest *nsrequest = [NSURLRequest requestWithURL:nsurl];
        

        [wvPage loadRequest:nsrequest];

    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method -

- (void)setNavigationBar:(NSString *)strCartValue
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.navigationItem.title = _strTitle;
}

#pragma mark - UIWebView Method -

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

@end
