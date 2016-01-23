//
//  ViewController.m
//  iamvegan
//
//  Created by Ian MacKinnon on 2016-01-22.
//  Copyright © 2016 Ian MacKinnon. All rights reserved.
//

#import "ViewController.h"
#import <AltBeacon/AltBeacon.h>
#import <PulsingHalo/PulsingHaloLayer.h>
#import "AuthClient.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface ViewController ()<AltBeaconDelegate>{
    CLLocationManager *_locationManager;
    bool _broadcasting;
    
}
@property (strong, nonatomic) AltBeacon* veganBeacon;
@property (strong, nonatomic) PulsingHaloLayer *halo;

@end

@implementation ViewController

@synthesize profileView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    if(!self.bluetoothManager)
    {
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
    
    self.veganBeacon =  [[AltBeacon alloc ]initWithIdentifier:[VeganHelper getUUID]];
    [self.veganBeacon addDelegate:self];
    [self.veganBeacon startDetecting];
    
    _broadcasting = false;
    [self.buttonLabel setText:@"Tap to broadcast Veganness"];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"background.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (void)start {
    // start broadcasting
    
    [self.veganBeacon startBroadcasting];
    _broadcasting = true;
    [self.buttonLabel setText:@"Broadcasting"];
    self.halo = [[PulsingHaloLayer alloc] initWithLayerNumber:5];
    self.halo.radius = 240.0;
    self.halo.animationDuration = 6.0;
    self.halo.position = self.view.center;
    UIColor *color = [UIColor colorWithRed:51/250.0
                                     green:85/255.0
                                      blue:0
                                     alpha:0.5];
    
    self.halo.backgroundColor = color.CGColor;
    
    
    [self.view.layer addSublayer:self.halo];
}

- (void)stop {
    
    // start broadcasting
    [self.veganBeacon stopBroadcasting];
    _broadcasting = false;
    [self.buttonLabel setText:@"Tap to broadcast Veganness"];
    self.halo.radius = 0;
}

// Delegate methods
- (void)service:(AltBeacon *)service foundDevices:(NSMutableDictionary *)devices {
    
    for(NSString *key in devices) {
        NSNumber * range = [devices objectForKey:key];
        
        if (range.intValue == INDetectorRangeUnknown){
            NSLog(@"beacon %@ out of range", key);
        }else{
            [VeganHelper handleRangedBeacon:key];
        }
        
    }
}

- (NSString*) convertToString:(NSNumber *)number {
    NSString *result = nil;
    
    switch(number.intValue) {
        case INDetectorRangeFar:
            result = @"Up to 100 meters";
            break;
        case INDetectorRangeNear:
            result = @"Up to 15 meters";
            break;
        case INDetectorRangeImmediate:
            result = @"Up to 5 meters";
            break;
            
        default:
            result = @"Unknown";
    }
    
    return result;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *stateString = nil;
    switch(self.bluetoothManager.state)
    {
        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent."; break;
        case CBCentralManagerStateUnsupported: stateString = @"The platform doesn't support Bluetooth Low Energy."; break;
        case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy."; break;
        case CBCentralManagerStatePoweredOff: stateString = @"Bluetooth is currently powered off."; break;
        case CBCentralManagerStatePoweredOn: stateString = nil; break;
        default: stateString = nil; break;
    }
    
    if (stateString){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BlutoothState" message:stateString delegate:self cancelButtonTitle:@"k" otherButtonTitles:nil];
        [alert show];
    }
}


-(IBAction)veganAction:(id)sender{
    if (_broadcasting){
        [self stop];
    } else {
        if ([VeganHelper getName]){
            [self tellServerVegan:[VeganHelper getName]];
        } else {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Sign In"
                                                  message:nil
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
             {
                 textField.placeholder = @"Enter your name";
             }];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:@"Ok"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"OK action, %@", alertController.textFields.firstObject.text);
                                           [self tellServerVegan:alertController.textFields.firstObject.text];
                                       }];
            
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

-(void) tellServerVegan:(NSString*)veganName{
    
    NSString *urlString = [NSString stringWithFormat:@"/user?device_id=%@&name=%@", [VeganHelper getUUID], [veganName stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AuthClient sharedClient] getPath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *veganDict = responseObject;
        [VeganHelper setName:[veganDict objectForKey:@"name"]];
        [self start];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}



-(IBAction)clear:(id)sender{
    [VeganHelper clearVegans];
}

-(IBAction)testNotification:(id)sender{
    [VeganHelper testNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

