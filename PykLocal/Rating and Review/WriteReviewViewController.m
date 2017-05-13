//
//  WriteReviewViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 21/11/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "WriteReviewViewController.h"
#import "DJWStarRatingView.h"

@interface WriteReviewViewController ()<DJWStarRatingViewDelegate>
{
    AppDelegate *appDelegate;
    Common *common;
    DJWStarRatingView *anotherStarRatingView;
    
    NSUserDefaults *prefs;
    UILabel * lbl;
    NSString *strRating;
}
@end

@implementation WriteReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    common = [[Common alloc]init];
    
    strRating = @"0";

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
    
    [lblName setText:[NSString stringWithFormat:@"How would you rate %@",_strName]];
    
    anotherStarRatingView = [[DJWStarRatingView alloc] initWithStarSize:CGSizeMake(30, 30) numberOfStars:5 rating:0.0 fillColor:RGB unfilledColor:[UIColor clearColor] strokeColor:RGB];
    
    CGRect frame = anotherStarRatingView.frame;
    frame.origin.x = (self.view.frame.size.width/2)-(frame.size.width/2);
    frame.origin.y +=10;
    
    [self.view addSubview:anotherStarRatingView];
    anotherStarRatingView.editable = YES;
    anotherStarRatingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    anotherStarRatingView.delegate = self;
    
    [anotherStarRatingView setFrame:frame];
    
    frame = tvDiscription.frame;
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 0.0,frame.size.width-8, 34.0)];
    lbl.font=[UIFont systemFontOfSize:14.0];
    [lbl setText:@"Your Review..."];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor lightGrayColor]];
    [tvDiscription addSubview:lbl];
    
    [tfTitle setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    [tvDiscription.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:.3] CGColor]];
    [tvDiscription.layer setBorderWidth:.8];
    tvDiscription.layer.cornerRadius = 5.0;
    tvDiscription.clipsToBounds = YES;
    
    
    btnSubmit.layer.cornerRadius = 5.0;
    [btnSubmit setBackgroundColor:RGB];
}

#pragma mark - Helper Method -

- (void)setNavigationBar:(NSString *)strCartValue
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.title = @"Write Review";
}

- (void)djwStarRatingChangedValue:(DJWStarRatingView *)view
{
    strRating = [NSString stringWithFormat:@"%.f", view.rating];
}

#pragma mark - UITextView Method -

-(void)textViewDidChange:(UITextView *)textView
{
    if (![textView hasText])
        lbl.hidden = NO;
    else
        lbl.hidden = YES;
}

#pragma mark - IBAction Method -


-(IBAction)btnSubmitPressed:(UIButton *)sender
{
    if(![strRating intValue])
    {
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:nil//NSLocalizedString(@"Whoa!", nil)
                                           subtitle:@"Please Give Rating"
                                              image:nil
                                               type:TSMessageNotificationTypeError
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionBottom
                               canBeDismissedByUser:YES];
        return;
    }
    
    if([common checkInternetConnection:TRUE ViewController:self.navigationController])
    {
        [SVProgressHUD show];
        [self.view endEditing:TRUE];
        NSString *strURL = [NSString stringWithFormat:@"%@%@",WS_BaseUrl,WS_Ratings_Reviews];
        
        NSMutableDictionary *dicPostData = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *dicRatingReview = [[NSMutableDictionary alloc]init];
        [dicRatingReview setObject:_strId forKey:@"product_id"];
        [dicRatingReview setObject:tvDiscription.text forKey:@"comment"];
        [dicRatingReview setObject:strRating forKey:@"rating"];
        
        [dicPostData setObject:dicRatingReview forKey:@"rating_review"];
        [dicPostData setObject:[prefs objectForKey:@"token"] forKey:@"token"];
        [dicPostData setObject:appDelegate.strMyDeviceId forKey:@"device_id"];
        [dicPostData setObject:appDelegate.strMyDeviceType forKey:@"device_type"];
        [dicPostData setObject:appDelegate.strMyDeviceToken forKey:@"device_token"];
        
        [common webAPIRequestHelper:self URL:strURL POSTDATA:dicPostData TAG:Ratings_Reviews HTTPMethod:@"POST" SHOWMESSAGE:YES SHOWSYSMESSAGE:NO OTHER:nil];
    }
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
                    [TSMessage showNotificationInViewController:self.navigationController
                                                          title:nil//NSLocalizedString(@"Whoa!", nil)
                                                       subtitle:[dicResponse objectForKey:@"message"]
                                                          image:nil
                                                           type:TSMessageNotificationTypeSuccess
                                                       duration:TSMessageNotificationDurationAutomatic
                                                       callback:nil
                                                    buttonTitle:nil
                                                 buttonCallback:nil
                                                     atPosition:TSMessageNotificationPositionBottom
                                           canBeDismissedByUser:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    NSString *strMessage = @"";
                    if(dicResponse)
                        strMessage = [dicResponse objectForKey:@"message"];
                    else
                        strMessage = @"Something is likely wrong!";
                    anotherStarRatingView.rating = 0;
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
