    //
//  Common.m
//  PykLocal
//
//  Created by Mihin  Patel on 23/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "Common.h"

@interface NSObject(Extended)

-(void)responseData:(NSString *)data WITHTAG:(int)tag OTHER:(NSMutableDictionary *)dicOther;

@end

@implementation Common
@synthesize request;
@synthesize session;
@synthesize manager;

- (void)webAPIRequestHelper:(NSObject*)delegate
                        URL:(NSString *)strURL
                   POSTDATA:(NSMutableDictionary *)dicPostData
                        TAG:(int)tag
                 HTTPMethod:(NSString *)httpMethod
                SHOWMESSAGE:(BOOL)isShow
             SHOWSYSMESSAGE:(BOOL)isShowSysMess
                      OTHER:(NSMutableDictionary *)dicOther
{
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    
    NSError *error;
    NSString *strPostData = @"";
    if([[dicPostData allKeys] count])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicPostData options:NSJSONWritingPrettyPrinted error:&error];
        strPostData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSData *postData = [strPostData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:strURL]];
    [request setHTTPMethod:httpMethod];//@"POST"
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request addValue:[prefs objectForKey:@"spree_api_key"] forHTTPHeaderField:@"X-Spree-Token"];
    [request setTimeoutInterval:60];

    NSLog(@"spree_api_key => %@",[prefs objectForKey:@"spree_api_key"]);
    
//    NSLog(@"Start => %f",[[NSDate date] timeIntervalSince1970]);
    
    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
//        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
//        NSLog(@"status code: %ld", (long)statusCode);
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // time-consuming task
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"\nURL :: %@\nRequest :: %@\nReply :: %@\nError :: %@\n",strURL,strPostData,requestReply,error);
//                NSLog(@"\nURL :: %@\nRequest :: %@\nError :: %@\n",strURL,strPostData,error);
                
                if(error)
                {
                    [delegate responseData:@"" WITHTAG:tag OTHER:nil];
                    
                    if(isShow)
                    {
//                        if(isShowSysMess)
//                            [appDelegate displayViewForError:[NSString stringWithFormat:@"%@",error]];
//                        else
//                            [appDelegate displayViewForError:appDelegate.strWebresponseErrorMessage];
                    }
                    //                    NSLog(@"Error: \n%@ => \n%@",urlstr, error);
                    request = nil;
                    session = nil;
                }
                else
                {
                    [delegate responseData:requestReply WITHTAG:tag OTHER:nil];
                }
            });
        });
    }] resume];
}


- (void)webAPIAFRequest:(NSObject*)delegate
                    URL:(NSString *)strURL
               POSTDATA:(NSMutableDictionary *)dicPostData
                    TAG:(int)tag
             HTTPMethod:(NSString *)httpMethod
            SHOWMESSAGE:(BOOL)isShow
         SHOWSYSMESSAGE:(BOOL)isShowSysMess
                  OTHER:(NSMutableDictionary *)dicOther
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[prefs objectForKey:@"spree_api_key"] forHTTPHeaderField:@"X-Spree-Token"];
    
    NSLog(@"spree_api_key => %@",[prefs objectForKey:@"spree_api_key"]);
    
    if(tag == 22 || tag == 28 || tag == 29 || tag == 30 || tag == 31)
    {
        NSLog(@"X-Spree-Order-Token => %@",appDelegate.strOrderToken);
        [manager.requestSerializer setValue:appDelegate.strOrderToken forHTTPHeaderField:@"X-Spree-Order-Token"];
    }
    
    
    
    
    
    NSError *error;
    NSString *strPostData = @"";
    if([[dicPostData allKeys] count])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicPostData options:NSJSONWritingPrettyPrinted error:&error];
        strPostData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }


    if([httpMethod isEqualToString:@"GET"])
    {
        [manager GET:strURL parameters:dicPostData success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSError * error;
            NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:responseObject options:0 error:&error];
            NSString * requestReply = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
            NSLog(@"\nURL :: %@\nRequest :: %@\nReply :: %@\nError :: %@\n",strURL,strPostData,requestReply,error);
            [delegate responseData:requestReply WITHTAG:tag OTHER:nil];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"\nURL :: %@\nRequest :: %@\nError :: %@\n",strURL,strPostData,[error localizedDescription]);
            NSMutableDictionary *other = [[NSMutableDictionary alloc]init];
            [other setObject:@"-999" forKey:@"Code"];
            [delegate responseData:@"" WITHTAG:tag OTHER:other];
        }];
    }
    else
    {
        [manager PUT:strURL parameters:dicPostData success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSError * error;
            NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:responseObject options:0 error:&error];
            NSString * requestReply = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
            NSLog(@"\nURL :: %@\nRequest :: %@\nReply :: %@\nError :: %@\n",strURL,strPostData,requestReply,error);
            [delegate responseData:requestReply WITHTAG:tag OTHER:nil];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"\nURL :: %@\nRequest :: %@\nError :: %@\n",strURL,strPostData,[error localizedDescription]);
            NSMutableDictionary *other = [[NSMutableDictionary alloc]init];
            [other setObject:@"-999" forKey:@"Code"];
            [delegate responseData:@"" WITHTAG:tag OTHER:other];
        }];
    }
    
}

#pragma mark - Set Border And Corner Radius Method -

-(id)setBorderAndCornerRadius:(id)sender Border:(BOOL)isBorder Size:(float)size Color:(UIColor *)color ColorWithAlpha:(float)colorWithAlpha Redius:(float)redius
{
    return sender;
}

#pragma mark - Check Internet Connection Method -


-(BOOL)checkInternetConnection:(BOOL)isShow ViewController:(UIViewController *)viewController
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable)
    {
        if(isShow)
        {
            [TSMessage showNotificationInViewController:viewController
                                                  title:nil//NSLocalizedString(@"Whoa!", nil)
                                               subtitle:@"Please check your Internet connection and try again"
                                                  image:nil
                                                   type:TSMessageNotificationTypeError
                                               duration:TSMessageNotificationDurationAutomatic
                                               callback:nil
                                            buttonTitle:nil
                                         buttonCallback:nil
                                             atPosition:TSMessageNotificationPositionBottom
                                   canBeDismissedByUser:YES];        }
        return FALSE;
    }
    else
        return TRUE;
}
@end
