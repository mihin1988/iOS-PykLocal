//
//  Common.h
//  PykLocal
//
//  Created by Mihin  Patel on 23/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

#define Sessions            1
#define Registrations       2
#define Login               3
#define Categories          4
#define Token               5
#define Password            6
#define ProductDetail       7
#define Home                8
#define Search              9
#define Filters             10
#define Wishlists           11
#define Order               12
#define Products            13
#define Ratings_Reviews     14
#define Update_Cart         15
#define RelatedProduct      16
#define Get_Cart            17
#define Delete_Cart         18
#define Change_Password     19
#define Get_Profile         20
#define Update_Profile      21
#define Next                22
#define User_Addresses      23
#define Countries           24
#define States              25
#define Update_Address      26
#define Pages               27
#define AddressToDelivery   28
#define DeliveryToPayment   29
#define PaymentToConfirm    30
#define ConfirmToComplete   31
#define ApplyCouponCode     32
#define CancelCouponCode    33
#define GetOrders           34
#define CancelOrders        35


@interface Common : NSObject

@property(nonatomic,retain) NSMutableURLRequest *request;
@property(nonatomic,retain) NSURLSession *session;
@property(nonatomic,retain) AFHTTPRequestOperationManager *manager;

- (void)webAPIRequestHelper:(NSObject*)delegate
                        URL:(NSString *)strURL
                   POSTDATA:(NSMutableDictionary *)dicPostData
                        TAG:(int)tag
                 HTTPMethod:(NSString *)httpMethod
                SHOWMESSAGE:(BOOL)isShow
             SHOWSYSMESSAGE:(BOOL)isShowSysMess
                      OTHER:(NSMutableDictionary *)dicOther;

- (void)webAPIAFRequest:(NSObject*)delegate
                    URL:(NSString *)strURL
               POSTDATA:(NSMutableDictionary *)dicPostData
                    TAG:(int)tag
             HTTPMethod:(NSString *)httpMethod
            SHOWMESSAGE:(BOOL)isShow
         SHOWSYSMESSAGE:(BOOL)isShowSysMess
                  OTHER:(NSMutableDictionary *)dicOther;

-(id)setBorderAndCornerRadius:(id)sender Border:(BOOL)isBorder Size:(float)size Color:(UIColor *)color ColorWithAlpha:(float)colorWithAlpha Redius:(float)redius;
-(BOOL)checkInternetConnection:(BOOL)isShow ViewController:(UIViewController *)viewController;

@end
