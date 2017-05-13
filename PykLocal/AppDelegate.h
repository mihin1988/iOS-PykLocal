//
//  AppDelegate.h
//  PykLocal
//
//  Created by Mihin  Patel on 04/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

#import "SideMenuViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *ncMain;
@property (strong, nonatomic) UINavigationController *ncSlider;
@property (strong, nonatomic) SideMenuViewController *leftMenuViewController;

@property (nonatomic, readwrite) BOOL isHandlePan;
@property (nonatomic, readwrite) BOOL isCart;
@property (nonatomic, readwrite) BOOL isEmptyCart;

@property (nonatomic , retain) NSString *strMyDeviceId;
@property (nonatomic , retain) NSString *strMyDeviceType;
@property (nonatomic , retain) NSString *strMyDeviceToken;

@property (nonatomic , retain) NSString *strCurrencySymbol;
@property (nonatomic , retain) NSString *strCartCount;
@property (nonatomic , retain) NSString *strOrderToken;

@property (nonatomic , readwrite) sqlite3 *dbPykLocal;

- (NSString *)numberFormatter:(NSString *)strPrice CurrencySymbol:(NSString *)strcurrencySymbol;

@end

