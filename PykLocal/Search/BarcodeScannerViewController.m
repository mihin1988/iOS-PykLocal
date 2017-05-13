//
//  BarcodeScannerViewController.m
//  PykLocal
//
//  Created by Mihin  Patel on 23/10/16.
//  Copyright © 2016 Mihin  Patel. All rights reserved.
//

#import "BarcodeScannerViewController.h"

@interface BarcodeScannerViewController ()
{
    AppDelegate *appDelegate;
    
    NSUserDefaults *prefs;
    NSString *strCodeType;
    NSString *strCode;
}
@end

@implementation BarcodeScannerViewController
@synthesize barcodeScannerDelegate;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    prefs = [NSUserDefaults standardUserDefaults];
    
    self.barcodeTypes = TFBarcodeTypeEAN8 | TFBarcodeTypeEAN13 | TFBarcodeTypeUPCA | TFBarcodeTypeUPCE | TFBarcodeTypeQRCODE;
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

    
    [self.navigationController setNavigationBarHidden:FALSE];
    
    UIButton *logoView = [[UIButton alloc] initWithFrame:CGRectMake(0,0,60,60)];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,60,60)];
    image.contentMode = UIViewContentModeScaleAspectFit;
    [image setImage: [UIImage imageNamed:@"Img-Logo.png"]];
    [logoView addSubview:image];
    [logoView setUserInteractionEnabled:NO];
    //    self.navigationItem.titleView = logoView;
    self.navigationItem.title = @"Scan Code";
    
    UIBarButtonItem *btnBarCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnCancelPressed:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnBarCancel, nil]];
}

#pragma mark - TFBarcodeScannerViewController

- (void)barcodePreviewWillShowWithDuration:(CGFloat)duration
{
}

- (void)barcodePreviewWillHideWithDuration:(CGFloat)duration
{
}

- (void)barcodeWasScanned:(NSSet *)barcodes
{
    TFBarcode* barcode = [barcodes anyObject];
    [self stop];
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(1108);
    
    strCodeType = [self stringFromBarcodeType:barcode.type];
    strCode = barcode.string;
    
    NSLog(@"Barcode Type :: %@",[self stringFromBarcodeType:barcode.type]);
    
    [prefs setObject:strCode forKey:@"scanCode"];
    [prefs synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private -

- (NSString *)stringFromBarcodeType:(TFBarcodeType)barcodeType
{
    static NSDictionary *typeMap;
    
    if (!typeMap) {
        typeMap = @{
                    @(TFBarcodeTypeEAN8):         @"EAN8",
                    @(TFBarcodeTypeEAN13):        @"EAN13",
                    @(TFBarcodeTypeUPCA):         @"UPCA",
                    @(TFBarcodeTypeUPCE):         @"UPCE",
                    @(TFBarcodeTypeQRCODE):       @"QRCODE",
                    @(TFBarcodeTypeCODE128):      @"CODE128",
                    @(TFBarcodeTypeCODE39):       @"CODE39",
                    @(TFBarcodeTypeCODE39Mod43):  @"CODE39Mod43",
                    @(TFBarcodeTypeCODE93):       @"CODE93",
                    @(TFBarcodeTypePDF417):       @"PDF417",
                    @(TFBarcodeTypeAztec):        @"Aztec"
                    };
    }
    
    return typeMap[@(barcodeType)];
}

#pragma mark - IBAction Method -

-(IBAction)btnCancelPressed:(UIButton *)sender
{
    [prefs setObject:@"" forKey:@"scanCode"];
    [prefs synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
