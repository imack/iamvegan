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



+(void) promptVegan:(PFUser*)user{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.alertTitle =[NSString stringWithFormat:@"%@ is a Vegan", user[PF_USER_NAME]];
    notification.alertBody = [NSString stringWithFormat:@"A person named %@ is near you and is a Vegan", user[PF_USER_NAME]];
    NSDictionary *userInfo = @{@"uuid":user.username, @"name":user[PF_USER_NAME]};
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = userInfo;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

+(void) testNotification{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.alertTitle = @"Jane is a Vegan";
    notification.alertBody = @"A Vegan is near you";
    NSDate *fromnow = [[NSDate date] dateByAddingTimeInterval:5];
    notification.fireDate = fromnow;
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}

+(void)clearVegans{
    [Vegan MR_truncateAll];// for testing
}

+(void) grabNameData:(NSString*)uuid  withPrompt:(bool)prompt{
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:uuid];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object){
            PFUser *user = (PFUser *)object;
            
            Vegan *vegan = [Vegan MR_createEntity];
            vegan.uuid = uuid;
            vegan.last_seen = [NSDate date];
            vegan.name = user[PF_USER_NAME];
            vegan.primary = user[PF_USER_PRIMARY];
            [VeganHelper promptVegan:user];
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
                //nooop
            }];
            
        } else {
            //error state
            Vegan *vegan = [Vegan MR_createEntity];
            vegan.uuid = uuid;
            vegan.last_seen = [NSDate date];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
                //nooop
            }];
        }
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
