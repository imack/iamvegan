//
//  ViewController.m
//  iamvegan
//
//  Created by Ian MacKinnon on 2016-01-22.
//  Copyright © 2016 Ian MacKinnon. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    CLLocationManager *_locationManager;
}

@end

@implementation ViewController

@synthesize onSwitch;
@synthesize profileView;
@synthesize nameLabel;

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
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager requestAlwaysAuthorization];
    // Do any additional setup after loading the view.
    if(!self.bluetoothManager)
    {
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
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

- (void)viewWillAppear:(BOOL)animated
{

    
}


-(IBAction)clear:(id)sender{
    [VeganHelper clearVegans];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

