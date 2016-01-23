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


@implementation VeganHelper


+(void) handleVeganCheckinResponse:(NSInteger)buttonIndex for:(NSDictionary*)userInfo{
    
    NSArray *vegans = [Vegan MR_findByAttribute:@"major" withValue:[userInfo objectForKey:@"major"]];
    Vegan *vegan  = [vegans objectAtIndex:0];
    
    switch (buttonIndex) {
        case 0: {
            //yes
            [VeganHelper performCheckin:vegan];
            break;
            
        }case 1: {
            //no
            break;
        }
        case 2: {
            //Always
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [VeganHelper performCheckin:vegan];
            break;
            
        }
        case 3: {
            //never
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            break;
        }
            
    }
    
}


+(void) performCheckin:(Vegan*)vegan{
    
    NSString *uuid = vegan.uuid;
    //NSString *minor = [vegan.minor stringValue];
    
    NSString *urlString = [NSString stringWithFormat:@"/user?user_id=%@", uuid];
    
    [[AuthClient sharedClient] getPath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        
        notification.alertBody = [NSString stringWithFormat:@"You are near the vegan %@", vegan.name];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
}

+(void) promptVegan:(Vegan*)vegan{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.alertBody = [NSString stringWithFormat:@"%@ is a Vegan and is in your presence", vegan.name];
    NSDictionary *userInfo = @{@"uuid":vegan.uuid, @"name":vegan.name};
    
    notification.userInfo = userInfo;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
}

+(void)clearVegans{
    [Vegan MR_truncateAll];// for testing
}

+(void) grabNameData:(Vegan*)vegan  withPrompt:(bool)prompt{
    
    NSString *urlString = [NSString stringWithFormat:@"/user?user_id=%@", vegan.uuid];
    
    [[AuthClient sharedClient] getPath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *veganDict = responseObject;
        vegan.name = [veganDict objectForKey:@"name"];
        vegan.primary = [veganDict objectForKey:@"primary"];
        vegan.date = [veganDict objectForKey:@"date"];
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        [VeganHelper promptVegan:vegan];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}


+(void) handleRangedBeacon:(NSString*)uuid {
    NSLog(@"Ranged a beacon uuid:%@ ", uuid);
    
    NSArray *vegans = [Vegan MR_findByAttribute:@"uuid" withValue:uuid];
    if ( [vegans count] == 0){
        Vegan *vegan = [Vegan MR_createEntity];
        vegan.uuid = uuid;
        vegan.last_seen = [NSDate date];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        [VeganHelper grabNameData:vegan withPrompt:true];
        
    } else {
        Vegan *vegan = [vegans objectAtIndex:0];
        NSTimeInterval interval = [vegan.last_seen timeIntervalSinceNow];
        
        if ( (-1*interval) > 5*60){
            [VeganHelper performCheckin:(Vegan*)vegan];
            vegan.last_seen = [NSDate date];
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    
    
    
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
