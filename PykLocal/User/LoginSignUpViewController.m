//
//  LoginSignUpViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 04/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "LoginSignUpViewController.h"
#import "PowerfulBannerView.h"
#import "GFPageSlider.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "HomeViewController.h"

#define kSelfViewWidth self.view.frame.size.width
#define kSelfViewHeight self.view.frame.size.height


@interface LoginSignUpViewController ()
{
    AppDelegate *appDelegate;
    PowerfulBannerView *bannerView;
    LoginViewController *loginViewController;
    SignUpViewController *signUpViewController;
    GFPageSlider *pageSlider;
    Common *common;
    
    NSUserDefaults *prefs;
    NSMutableArray *arrBannerImage;
    NSMutableArray *arrViewControllers;
}
@end

@implementation LoginSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];

    arrBannerImage = [[NSMutableArray alloc]initWithObjects:@"Img-1.png",@"Img-2.png",@"Img-3.png", nil];
    [self addGallery:arrBannerImage];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [self manageScreen];
    [self.navigationController setNavigationBarHidden:TRUE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Method -

- (IBAction)btnContinueAsGuestPressed:(UIButton *)sender
{
    if([[prefs objectForKey:@"is_guest"] intValue] != 1)
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
    else
    {
        appDelegate.leftMenuViewController.index = 0;
        HomeViewController *homeViewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
        [self.navigationController pushViewController:homeViewController animated:YES];
    }
}

#pragma mark - Helper Method -

- (void)addGallery:(NSMutableArray *)arrImageDetail
{
    bannerView = [[PowerfulBannerView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.window.bounds.size.width, 200)];
    [bannerView setBackgroundColor:[UIColor clearColor]];

//    [pageControl setFrame:CGRectMake(0, bannerView.frame.size.height-25, appDelegate.window.bounds.size.width, 15)];

    bannerView.pageControl = pageControl;
    
    [pageControl setCurrentPageIndicatorTintColor:RGB];
    [pageControl setTintColor:[UIColor redColor]];
    
    bannerView.items = arrImageDetail;
    bannerView.bannerItemConfigurationBlock = ^UIView *(PowerfulBannerView *banner, id item, UIView *reusableView)
    {
        UIImageView *view = (UIImageView *)reusableView;
        if (!view) {
            view = [[UIImageView alloc] initWithFrame:CGRectZero];
            view.contentMode = UIViewContentModeScaleToFill;
            view.clipsToBounds = YES;
        }
        [view setImage:[UIImage imageNamed:item]];
        [view setBackgroundColor:[UIColor blackColor]];
        return view;
    };
    
    //        self.bannerView.bannerDidSelectBlock = ^(PowerfulBannerView *banner, NSInteger index) {
    //            printf("banner did select index at: %zd \n", index);
    //        };
    //
    //        self.bannerView.bannerIndexChangeBlock = ^(PowerfulBannerView *banner, NSInteger fromIndex, NSInteger toIndex) {
    //            printf("banner changed index from %zd to %zd\n", fromIndex, toIndex);
    //        };
    //
    //        self.bannerView.longTapGestureHandler = ^(PowerfulBannerView *banner, NSInteger index, id item, UIView *view) {
    //            printf("banner long gesture recognized on index: %zd !\n", index);
    //        };
    
    if ([bannerView.items count] <=1)
        [pageControl setHidden:TRUE];
    else
        [pageControl setHidden:FALSE];
    
    bannerView.loopingInterval = 10.f;
    bannerView.autoLooping = YES;
    
    [self.view addSubview:bannerView];
    
    CGRect frame = pageControl.frame;
    [self.view addSubview:pageControl];
    pageControl.frame = frame;
}

-(void)manageScreen
{
    if(!pageSlider)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        arrViewControllers =[[NSMutableArray alloc]init];
        
        loginViewController = [[LoginViewController alloc] init];
        signUpViewController = [[SignUpViewController alloc] init];
        
        
        [arrViewControllers addObject:loginViewController];
        [arrViewControllers addObject:signUpViewController];
        
        [self addChildViewController:arrViewControllers[0]];
        [self addChildViewController:arrViewControllers[1]];

        pageSlider = [[GFPageSlider alloc] initWithFrame:CGRectMake(0, 0, kSelfViewWidth, kSelfViewHeight - 200)
                                                          numberOfPage:2
                                                       viewControllers:arrViewControllers
                                                      menuButtonTitles:@[@"Login", @"Sign Up"]];
        [viewContainer addSubview:pageSlider];
        
        pageSlider.menuHeight = 40.0f;
        pageSlider.menuNumberPerPage = 2;
        //    pageSlider.indicatorLineColor = [UIColor blueColor];
    }
}

- (IBAction)btn:(UIButton *)sender {
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
                    [prefs setObject:@"1" forKey:@"is_guest"];
                    [prefs synchronize];
                    
                    HomeViewController *homeViewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
                    [self.navigationController pushViewController:homeViewController animated:YES];
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
