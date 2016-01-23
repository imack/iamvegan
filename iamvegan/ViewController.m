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
    NSUUID *_uuid;
    BOOL _notifyOnDisplay;
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
    
    
    _uuid =  [[NSUUID alloc] initWithUUIDString:VEGAN_UUID];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:SOURCE_BEACON_ID];
    if(region)
    {
        _uuid = region.proximityUUID;
        _notifyOnDisplay = region.notifyEntryStateOnDisplay;
        self.onSwitch.on = true;
        [_locationManager startMonitoringForRegion:region];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    // A user can transition in or out of a region while the application is not running.
    // When this happens CoreLocation will launch the application momentarily, call this delegate method
    // and we will let the user know via a local notification.
    
    if(state == CLRegionStateInside)
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [_locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
    else if(state == CLRegionStateOutside)
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [_locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
        [VeganHelper clearVegans];
    }
    else
    {
        return;
    }
    
    // If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
    // If its not, iOS will display the notification to the user.
}



-(void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    if ( [beacons count] > 0 ){
        CLBeacon *nearest = [beacons objectAtIndex:0];
        
        [VeganHelper handleRangedBeacon:nearest];
        [_locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
        
    } else {
        NSLog(@"Got weird state where no ranged beacons ");
    }
}



-(IBAction)toggleSwitch:(id)sender{
    if( self.onSwitch.on )
    {
    }
    else
    {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] identifier:SOURCE_BEACON_ID];
        [_locationManager stopMonitoringForRegion:region];
    }
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

