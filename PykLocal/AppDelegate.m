//
//  AppDelegate.m
//  PykLocal
//
//  Created by Mihin  Patel on 04/07/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginSignUpViewController.h"
#import "HomeViewController.h"
#import "MFSideMenuContainerViewController.h"
#import <SSKeychain/SSKeychainQuery.h>
#import "SSKeychain.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Google/SignIn.h>

#import "BraintreeCore.h"

@interface AppDelegate ()
{
    Reachability *reachability;
    
    NSUserDefaults *prefs;
}
@end

@implementation AppDelegate
@synthesize ncMain;
@synthesize ncSlider;
@synthesize leftMenuViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [BTAppSwitch setReturnURLScheme:@"com.AppMasonStudiosInc.PykLocal.payments"];
    
    // Facebook sign In Configuration
    // ==============================
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    prefs = [NSUserDefaults standardUserDefaults];
    _isHandlePan = TRUE;
    _strCartCount = @"";
    _strOrderToken = @"";
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    if([[prefs objectForKey:@"is_guest"] intValue] == 1 || [[prefs objectForKey:@"is_guest"]length])
    {
        HomeViewController *homeViewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
        ncMain = [[UINavigationController alloc]initWithRootViewController:homeViewController];
    }
    else
    {
        LoginSignUpViewController *loginSignUpViewController = [[LoginSignUpViewController alloc]initWithNibName:@"LoginSignUpViewController" bundle:nil];
        ncMain = [[UINavigationController alloc]initWithRootViewController:loginSignUpViewController];
    }
    
    leftMenuViewController = [[SideMenuViewController alloc] init];
    ncSlider = [[UINavigationController alloc]initWithRootViewController:leftMenuViewController];

//    SideMenuViewController *rightMenuViewController = [[SideMenuViewController alloc] init];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:ncMain
                                                    leftMenuViewController:ncSlider
                                                    rightMenuViewController:nil];
    
    self.window.tintColor = RGB;
    self.window.rootViewController = container;
    [self.window makeKeyAndVisible];
    
    [self CreateCopyOfDatabaseIfNeeded];
    [self OpenDatabase];
    
    [self didRegisterForRemoteNotifications];
    
    NSDictionary *pushNotificationPayload = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    
    if(pushNotificationPayload)
    {
        [self application:application didReceiveRemoteNotification:pushNotificationPayload];
//        blnNotification = TRUE;
//        dicUserInfo = pushNotificationPayload;
    }

    return YES;
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ([url.scheme localizedCaseInsensitiveCompare:@"com.AppMasonStudiosInc.PykLocal.payments"] == NSOrderedSame) {
        return [BTAppSwitch handleOpenURL:url sourceApplication:sourceApplication];
    }
    return NO;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    
    if ([url.scheme localizedCaseInsensitiveCompare:@"com.AppMasonStudiosInc.PykLocal.payments"] == NSOrderedSame) {
        return [BTAppSwitch handleOpenURL:url options:options];
    }
    
//    if ([[url path] isEqualToString:@"/productid"])
//    {
//        NSArray *arrControllers = [ncMain viewControllers];
//        
//        TabViewController *tv = [[TabViewController alloc]initWithNibName:@"TabViewController" bundle:nil];
//        UIViewController *currentController;
//        for(int i = 0 ; i < [arrControllers count] ; i++)
//        {
//            
//            UIViewController *viewController = [arrControllers objectAtIndex:i];
//            
//            
//            if([viewController isKindOfClass:[TabViewController class]])
//            {
//                //                blnNotification = TRUE;
//                
//                tv = (TabViewController *)viewController;
//                [tv.indTabBarController selectedIndex];
//                //                [tv.indTabBarController setSelectedIndex:2];
//                currentController = [tv.indTabBarController selectedViewController];
//                break;
//            }
//        }
//        
//        
//        ProductDetailViewController *productDetailViewController = [[ProductDetailViewController alloc]initWithNibName:@"ProductDetailViewController" bundle:nil];
//        productDetailViewController.strFromWhere = @"Home";
//        
//        [productDetailViewController setValue:@"t999" SupplierID:strSelectedSupplierId ProductID:@"270" ProductDetail:nil];
//        
//        if ([currentController isKindOfClass:[UINavigationController class]]){
//            [(UINavigationController *)currentController pushViewController:productDetailViewController animated:YES];
//        }else if ([currentController isKindOfClass:[UIViewController class]]){
//            [currentController.navigationController pushViewController:productDetailViewController animated:YES];
//        }
//        
//        
//        return TRUE;
//    }
    
    if ([[url scheme]isEqualToString:FACEBOOK_SCHEME])
        return [[FBSDKApplicationDelegate sharedInstance] application:app openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    else
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                          annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if(![[prefs objectForKey:@"LaunchFirstTime"] isEqualToString:@"TRUE"])
    {
        if(![prefs objectForKey:@"Noti"])
        {
            [prefs setObject:@"True" forKey:@"Noti"];
            return;
        }
    }
    

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        self.strMyDeviceType = @"iPad";
    else if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        self.strMyDeviceType = @"iPhone";
    else
        self.strMyDeviceType = @"iPhone";
    
    self.strMyDeviceId = [self getUniqueDeviceIdentifierAsString];
    self.strMyDeviceToken = [prefs objectForKey:@"StoredMyDeviceToken"];
    
    if(![self.strMyDeviceToken length])
    {
        self.strMyDeviceToken = @"abcdefghijklmnopqrstuvwxyz";
        [prefs setObject:self.strMyDeviceToken forKey:@"StoredMyDeviceToken"];
        [prefs synchronize];
    }
    
    [prefs setObject:self.strMyDeviceId forKey:@"StoredMyDeviceId"];
    [prefs setObject:self.strMyDeviceType forKey:@"StoredMyDeviceType"];
    
    self.strCurrencySymbol = @"$";
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Remote Notification Methods -

- (void)didRegisterForRemoteNotifications
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
}

- (void)didUnregisterForRemoteNotifications
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    [prefs setObject:@"FALSE" forKey:@"StoredAllowNotifications"];
    [prefs synchronize];
}

- (NSString *) NSDataToHex :(NSData *)data
{
    const unsigned char *dbytes = [data bytes];
    NSMutableString *hexStr =
    [NSMutableString stringWithCapacity:[data length]*2];
    int i;
    for (i = 0; i < [data length]; i++) {
        [hexStr appendFormat:@"%02x", dbytes[i]];
    }
    return [NSString stringWithString: hexStr];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *strDeviceToken;
    NSString *strDeviceTokenHex;
    
    if([strDeviceToken isEqualToString:@""] || [strDeviceToken isEqualToString:@"(null)"] || strDeviceToken == NULL || strDeviceToken == nil)
    {
        strDeviceToken = [deviceToken description];
    }
    
    if([strDeviceToken isEqualToString:@""] || [strDeviceToken isEqualToString:@"(null)"] || strDeviceToken == NULL || strDeviceToken == nil)
    {
        strDeviceToken = [[NSString alloc] initWithData:deviceToken encoding:NSStringEncodingConversionAllowLossy];
    }
    
    if([strDeviceToken isEqualToString:@""] || [strDeviceToken isEqualToString:@"(null)"] || strDeviceToken == NULL || strDeviceToken == nil)
    {
        strDeviceToken = [[NSString alloc] initWithFormat:@"%@",deviceToken];
    }
    
    if([strDeviceToken isEqualToString:@""] || [strDeviceToken isEqualToString:@"(null)"] || strDeviceToken == NULL || strDeviceToken == nil)
    {
        strDeviceTokenHex = [self NSDataToHex:deviceToken];
    }
    
    strDeviceToken = [strDeviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    strDeviceToken = [strDeviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    strDeviceToken = [strDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus != NotReachable)
    {
        if([strDeviceToken isEqualToString:@""] || [strDeviceToken isEqualToString:@"(null)"] || strDeviceToken == NULL || strDeviceToken == nil)
        {
            [prefs setObject:@"" forKey:@"StoredMyDeviceToken"];
        }
        else
        {
            [prefs setObject:strDeviceToken forKey:@"StoredMyDeviceToken"];
            self.strMyDeviceToken = strDeviceToken;
            [prefs setObject:@"TRUE" forKey:@"StoredAllowNotifications"];
        }
        
        if([strDeviceTokenHex isEqualToString:@""] || [strDeviceTokenHex isEqualToString:@"(null)"] || strDeviceTokenHex == NULL || strDeviceTokenHex == nil)
        {
            strDeviceTokenHex = @"";
        }
        
        [prefs synchronize];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [prefs setObject:@"" forKey:@"StoredMyDeviceToken"];
    [prefs synchronize];
    
    //NSLog(@"Failed to get token, error: %@", error);
}

#pragma mark - Helper Method -

-(NSString *)getUniqueDeviceIdentifierAsString
{
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    NSString *strApplicationUUID = [SSKeychain passwordForService:appName account:@"incoding"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:strApplicationUUID forService:appName account:@"incoding"];
    }
    
    return strApplicationUUID;
}

- (NSString *)numberFormatter:(NSString *)strPrice CurrencySymbol:(NSString *)strcurrencySymbol
{
    double currency = [strPrice doubleValue];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setCurrencySymbol:strcurrencySymbol];
    NSString *numberAsString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:currency]];
    return numberAsString;
}

#pragma mark - Create And Open Database Methods -

- (void)CreateCopyOfDatabaseIfNeeded
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    
    NSString *finalPath = [documentPath stringByAppendingPathComponent:@"PykLocal.sqlite"];
    
    NSLog(@"Database Path :- %@",finalPath);
    
    BOOL blnSuccess = [fileManager fileExistsAtPath:finalPath];
    
    if(!blnSuccess)
    {
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PykLocal.sqlite"];
        
        blnSuccess = [fileManager copyItemAtPath:defaultPath toPath:finalPath error:&error];
        
        if(blnSuccess)
        {
        }
    }
}

- (void)UpdateDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *finalPath = [documentPath stringByAppendingPathComponent:@"PykLocal.sqlite"];
    
    BOOL blnSuccess = [fileManager fileExistsAtPath:finalPath];
    BOOL success;
    if(blnSuccess)
    {
        success = [fileManager removeItemAtPath:finalPath error:&error];
    }
    
    NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PykLocal.sqlite"];
    
    [fileManager copyItemAtPath:defaultPath toPath:finalPath error:&error];
}

- (void)OpenDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *finalPath = [documentPath stringByAppendingPathComponent:@"PykLocal.sqlite"];
    
    if(sqlite3_open([finalPath UTF8String], &_dbPykLocal) != SQLITE_OK)
    {
        //NSLog(@"Error to Open Database :- %s",sqlite3_errmsg(self.dbQuickeSelling));
        
        sqlite3_close(_dbPykLocal);
    }
}

//- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    NSDictionary *runMsg = (NSDictionary*)[userInfo objectForKey:@"aps"];
//    
//    if ( application.applicationState != UIApplicationStateActive )
//    {
//        //        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[runMsg objectForKey:@"badge"] intValue]];
//        [self manageNotification:userInfo];
//    }
//    else
//    {
//        // app was already in the foreground
//        dicUserInfo = userInfo;
//        NSString *message = [[NSString alloc] init];
//        for (id key in runMsg)
//        {
//            if([key isEqualToString:@"alert"])
//            {
//                message = [NSString stringWithFormat:@"%@", [runMsg objectForKey:key]];
//            }
//            else if([key isEqualToString:@"badge"])
//            {
//                //                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[runMsg objectForKey:key] intValue]];
//            }
//        }
//        
//        [self GenerateMyRemoteNotification:message];
//    }
//}
//
//
//#ifdef __IPHONE_8_0
//
//- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
//{
//    //handle the actions
//    
//    NSDictionary *runMsg = (NSDictionary*)[userInfo objectForKey:@"aps"];
//    
//    if ( application.applicationState != UIApplicationStateActive )
//    {
//        //        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[runMsg objectForKey:@"badge"] intValue]];
//        [self manageNotification:userInfo];
//    }
//    else
//    {
//        // app was already in the foreground
//        dicUserInfo = userInfo;
//        NSString *message = [[NSString alloc] init];
//        for (id key in runMsg)
//        {
//            if([key isEqualToString:@"alert"])
//            {
//                message = [NSString stringWithFormat:@"%@", [runMsg objectForKey:key]];
//            }
//            else if([key isEqualToString:@"badge"])
//            {
//                //                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[runMsg objectForKey:key] intValue]];
//            }
//        }
//        
//        [self GenerateMyRemoteNotification:message];
//    }
//}
//
//#endif
//
//- (void)GenerateMyRemoteNotification:(NSString *)strNotifType
//{
//    NSString *strAlertTitle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
//    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strAlertTitle
//                                                    message:[NSString stringWithFormat:@"%@", strNotifType]
//                                                   delegate:self
//                                          cancelButtonTitle:nil
//                                          otherButtonTitles:@"Close", @"View", nil];
//    [alert setTag:2];
//    [alert show];
//}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
//    
//    if([title isEqualToString:@"View"])
//    {
//        NSArray *arrControllers = [ncMain viewControllers];
//        
//        for(int i = 0 ; i < [arrControllers count] ; i++)
//        {
//            UIViewController *viewController = [arrControllers objectAtIndex:i];
//            if([viewController isKindOfClass:[TabViewController class]])
//            {
//                [self manageNotification:dicUserInfo];
//            }
//        }
//        
//    }
//    else if([title isEqualToString:@"Close"])
//    {
//    }
//}
@end
