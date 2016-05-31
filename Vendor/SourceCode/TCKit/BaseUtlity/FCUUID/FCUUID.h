//
//  FCUUID
//
//  Created by Fabio Caccamo on 26/06/14.
//  Copyright (c) 2014 Fabio Caccamo - http://www.fabiocaccamo.com/ - All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const FCUUIDsOfUserDevicesDidChangeNotification;

@interface FCUUID : NSObject


// changes each time (no persistent)
+(NSString *)uuid;

// changes each time (no persistent), but allows to keep in memory more temporary uuids
+(NSString *)uuidForKey:(id<NSCopying>)key;

// changes each time the app gets launched (persistent to session)
+(NSString *)uuidForSession;

// changes each time the app gets installed (persistent to installation)
+(NSString *)uuidForInstallation;

// changes each time all the apps of the same vendor are uninstalled (this works exactly as identifierForVendor)
+(NSString *)uuidForVendor;

// changes only on system reset, this is the best replacement to the good old udid (persistent to device)
+(NSString *)uuidForDevice;

// these methods search for an existing UUID / UDID stored in the KeyChain or in UserDefaults for the given key / service / access-group
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key commitMigration:(BOOL)commitMigration;
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service commitMigration:(BOOL)commitMigration;
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup commitMigration:(BOOL)commitMigration;

// returns the list of all uuidForDevice of the same user, in this way it's possible manage guest accounts across multiple devices easily
+(NSArray *)uuidsOfUserDevices;

+(BOOL)uuidValueIsValid:(NSString *)uuidValue;

@end