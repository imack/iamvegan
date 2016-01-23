//
//  Vegan+CoreDataProperties.h
//  iamvegan
//
//  Created by Ian MacKinnon on 2016-01-22.
//  Copyright © 2016 Ian MacKinnon. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Vegan.h"

NS_ASSUME_NONNULL_BEGIN

@interface Vegan (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSDate *last_seen;
@property (nullable, nonatomic, retain) NSNumber *major;
@property (nullable, nonatomic, retain) NSNumber *minor;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *primary;
@property (nullable, nonatomic, retain) NSString *secondary;
@property (nullable, nonatomic, retain) NSString *date;

@end

NS_ASSUME_NONNULL_END
