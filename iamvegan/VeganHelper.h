//
//  VeganHelper.h
//  iamvegan
//
//  Created by Ian MacKinnon on 2016-01-22.
//  Copyright © 2016 Ian MacKinnon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "VeganHelper.h"
#import "Vegan.h"
#import <MagicalRecord/MagicalRecord.h>

#define SOURCE_BEACON_ID @"ca.lunarluau.iamvegan"
#define PF_USER_NAME @"full_name"
#define PF_USER_PRIMARY @"primary"


@interface VeganHelper : NSObject

+(void) handleRangedBeacon:(NSString*)uuid;
+(void) handleVeganCheckinResponse:(NSInteger)buttonIndex for:(NSDictionary*)userInfo;
+(void) clearVegans;
+(NSString*)getUUID;
+(void) testNotification;
+(NSString*) getName;
+(void) setName:(NSString*)username;

@end
