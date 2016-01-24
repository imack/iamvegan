//
//  VeganHelper.m
//  iamvegan
//
//  Created by Ian MacKinnon on 2016-01-22.
//  Copyright © 2016 Ian MacKinnon. All rights reserved.
//

#import "VeganHelper.h"
#import <NotificationCenter/NotificationCenter.h>
#import "AuthClient.h"
#import <Parse/Parse.h>

//https://github.com/AltBeacon
//https://github.com/CharruaLab/AltBeacon

@implementation VeganHelper



+(void) promptVegan:(Vegan*)vegan{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.alertTitle =@"A Vegan is Nearby";
    notification.alertBody =@"A Vegan is Nearby";
    NSDictionary *userInfo = @{@"uuid":vegan.uuid};
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = userInfo;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

+(void) testNotification{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.alertTitle = @"A Vegan is Nearby";
    notification.alertBody =@"A Vegan is Nearby";
    NSDate *fromnow = [[NSDate date] dateByAddingTimeInterval:5];
    NSDictionary *userInfo = @{@"uuid":@"B0D60303-A421-4DF1-8C1B-E8B629F058A6"};
    notification.fireDate = fromnow;
    notification.userInfo = userInfo;
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}

+(void)clearVegans{
    [Vegan MR_truncateAll];// for testing
}

+(void) grabNameData:(NSString*)uuid  withPrompt:(bool)prompt{
    Vegan *vegan = [Vegan MR_createEntity];
    vegan.uuid = uuid;
    vegan.last_seen = [NSDate date];
    
    [VeganHelper promptVegan:vegan];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
        //nooop
    }];
}


+(void) handleRangedBeacon:(NSString*)uuid {
    NSLog(@"Ranged a beacon uuid:%@ ", uuid);
    
    NSArray *vegans = [Vegan MR_findByAttribute:@"uuid" withValue:uuid];
    if ( [vegans count] == 0){
        
        [VeganHelper grabNameData:uuid withPrompt:true];
        
    } else {
        Vegan *vegan = [vegans objectAtIndex:0];
        NSTimeInterval interval = [vegan.last_seen timeIntervalSinceNow];
        
        if ( (-1*interval) > 5*60){
            //[VeganHelper performCheckin:(Vegan*)vegan];
            vegan.last_seen = [NSDate date];
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    
    
    
}

+(NSString*) getName{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"vegan-name"]){
        return [defaults objectForKey:@"vegan-name"];
    } else {
        return nil;
    }
}

+(void) setName:(NSString*)username{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:@"vegan-name"];
    [defaults synchronize];
}

+(NSString*)getUUID{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"vegan-uuid"]){
        return [defaults objectForKey:@"vegan-uuid"];
    } else {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [defaults setObject:uuid forKey:@"vegan-uuid"];
        [defaults synchronize];
        return uuid;
    }
}

@end
