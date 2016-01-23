//
//  AppDelegate.m
//  iamvegan
//
//  Created by Ian MacKinnon on 2016-01-22.
//  Copyright © 2016 Ian MacKinnon. All rights reserved.
//

#import "AppDelegate.h"

#import "VeganHelper.h"
#import <BuddyBuildSDK/BuddyBuildSDK.h>

@interface AppDelegate ()<CLLocationManagerDelegate>{
    NSDictionary *_userInfo;
    NSUUID *_uuid;
    BOOL _notifyOnDisplay;
    CLLocationManager *_locationManager;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [BuddyBuildSDK setup];
    
    // Override point for customization after application launch.
    
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    _uuid =  [[NSUUID alloc] initWithUUIDString:VEGAN_UUID];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:SOURCE_BEACON_ID];
    if(region)
    {
        _uuid = region.proximityUUID;
        _notifyOnDisplay = region.notifyEntryStateOnDisplay;
        [_locationManager startMonitoringForRegion:region];
        [_locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
    
    return YES;
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
    else if(state == CLRegionStateOutside){
        NSLog(@"Left a beacon ranging region");
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
        for (CLBeacon *beacon in beacons){
            [VeganHelper handleRangedBeacon:beacon];
            
        }
        
    } else {
        NSLog(@"Got weird state where no ranged beacons ");
    }
}



- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    if ( notification.userInfo){
        // If the application is in the foreground, we will notify the user of the region's state via an alert.
        _userInfo = notification.userInfo; //don't like this hack, but it'll do for now
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@ is a vegan in your presence, would you like to know more?",[_userInfo objectForKey:@"name"]] delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:nil otherButtonTitles:nil];
        [sheet addButtonWithTitle:@"Yes"];
        
        [sheet showInView: self.window];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [VeganHelper handleVeganCheckinResponse:buttonIndex for:_userInfo];
    }
    
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
