//
//  BarcodeScannerViewController.h
//  PykLocal
//
//  Created by Mihin  Patel on 23/10/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFBarcodeScanner.h"

// Delgate
@protocol BarcodeScannerDelegate <NSObject>
@optional
- (void)reloadScreen;

@end

@interface BarcodeScannerViewController : TFBarcodeScannerViewController

// Property for delegate
@property (weak, nonatomic) id<BarcodeScannerDelegate> barcodeScannerDelegate;


@end
