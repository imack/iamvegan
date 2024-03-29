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
#import <Parse/Parse.h>
#import "ProfileViewController.h"

@interface AppDelegate ()<CLLocationManagerDelegate>{
    NSDictionary *_userInfo;
    NSUUID *_uuid;
    BOOL _notifyOnDisplay;
    CLLocationManager *_locationManager;
    PFUser *currentVegan;
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
    [Parse setApplicationId:@"P5HZyQzcnnDT7QWWlxROnZOq3vaZnWRNRG2GEJhc"
                  clientKey:@"LYO81dfm0aMTXCf3ZQ4iEvoeQyufgdxwCsCe7icE"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    return YES;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    if ( notification.userInfo){
        // If the application is in the foreground, we will notify the user of the region's state via an alert.
        _userInfo = notification.userInfo; //don't like this hack, but it'll do for now
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:[_userInfo objectForKey:@"uuid"]];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (object){
                PFUser *user = (PFUser *)object;
                currentVegan = user;
                
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@ is a vegan in your presence, would you like to know more?",user[PF_USER_NAME]] delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:nil otherButtonTitles:nil];
                [sheet addButtonWithTitle:@"Yes"];
                
                [sheet showInView: self.window];
                
            }
        }];

    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSArray *vegans = [Vegan MR_findByAttribute:@"uuid" withValue:[_userInfo objectForKey:@"uuid"]];
        Vegan *vegan  = [vegans objectAtIndex:0];
        
        switch (buttonIndex) {
            case 1: {
                UINavigationController* nav = (UINavigationController*)self.window.rootViewController;
                UIStoryboard *storyboard =[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                ProfileViewController *profileViewController = [storyboard instantiateViewControllerWithIdentifier:@"profileViewController"];
                profileViewController.vegan = currentVegan;
                
                [nav pushViewController:profileViewController animated:true];
                //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.vrg.org/nutshell/vegan.htm"]];
                break;
            }
        }
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
