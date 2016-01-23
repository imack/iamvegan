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


+(void) promptForAuthorization:(Vegan*)location{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.alertBody = [NSString stringWithFormat:@"Do you want to checkin to %@", location.name];
    NSDictionary *userInfo = @{@"major":location.major, @"minor":location.minor, @"name":location.name};
    
    notification.userInfo = userInfo;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
}

+(void) handleUserCheckinResponse:(NSInteger)buttonIndex for:(NSDictionary*)userInfo{
    
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
    
    NSString *major = [vegan.major stringValue];
    NSString *minor = [vegan.minor stringValue];
    
    NSDictionary *dict = @{ @"major": major,
                           @"minor":minor};
    
    
    [[AuthClient sharedClient] postPath:@"/api/checkin" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        
        notification.alertBody = [NSString stringWithFormat:@"You are near the vegan %@", vegan.name];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
}

+(void)clearVegans{
    [Vegan MR_truncateAll];// for testing
}

+(void) grabNameData:(Vegan*)location  withPrompt:(bool)prompt{
    
    NSDictionary *dict = @{@"major": location.major,
                           @"minor": location.minor};
    
    [[AuthClient sharedClient] getPath:@"/locations/lookup" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = responseObject;
        NSArray *location_dict = [dict objectForKey:@"locations"];
        if ([location_dict count] == 1){
            NSDictionary *raw_loc = [location_dict objectAtIndex:0];
            location.name = [raw_loc objectForKey:@"name"];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            if (prompt){
                [VeganHelper promptForAuthorization:location];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}


+(void) handleRangedBeacon:(CLBeacon*)beacon {
    NSLog(@"Ranged a beacon major:%@ minor:%@", beacon.major, beacon.minor);
    
    NSArray *locations = [Vegan MR_findByAttribute:@"major" withValue:beacon.major];
    if ( [locations count] > 0){
        Vegan *vegan = [locations objectAtIndex:0];
        NSTimeInterval interval = [vegan.last_seen timeIntervalSinceNow];
        
        if ( (-1*interval) > 5*60){
            [VeganHelper performCheckin:(Vegan*)vegan];
            vegan.last_seen = [NSDate date];
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
    } else {
        Vegan *vegan = [Vegan MR_createEntity];
        vegan.major = beacon.major;
        vegan.minor = beacon.minor;
        vegan.last_seen = [NSDate date];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        [VeganHelper grabNameData:vegan withPrompt:true];
    }
    
    
    
}

@end
