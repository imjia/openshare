/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TCDevicePlatform) {
    kTCDeviceUnknown = 0,
    
    kTCDeviceSimulator,
    kTCDeviceSimulatoriPhone,
    kTCDeviceSimulatoriPad,
    kTCDeviceSimulatorAppleTV,
    
    
    kTCDevice1GiPhone,
    kTCDevice3GiPhone,
    kTCDevice3GSiPhone,
    
    kTCDevice4iPhone,
    kTCDevice4SiPhone,
    
    kTCDevice5iPhone,
    kTCDevice5CiPhone,
    kTCDevice5SiPhone,
    
    kTCDevice6iPhone,
    kTCDevice6PlusiPhone,
    
    kTCDevice6SiPhone,
    kTCDevice6SPlusiPhone,
    
    kTCDevice1GiPod,
    kTCDevice2GiPod,
    kTCDevice3GiPod,
    kTCDevice4GiPod,
    kTCDevice5GiPod,
    kTCDevice6GiPod,
    
    kTCDevice1GiPad,
    kTCDevice2GiPad,
    kTCDevice1GiPadMini,
    
    kTCDevice3GiPad,
    kTCDevice4GiPad,
    kTCDevice1GiPadAir,
    kTCDevice2GiPadMini,
    kTCDevice3GiPadMini,
    kTCDevice4GiPadMini,
    kTCDevice2GiPadAir,
    
    kTCDevice1GiPadPro,
    
    
    kTCDeviceAppleTV2,
    kTCDeviceAppleTV3,
    kTCDeviceAppleTV4,
    
    kTCDeviceUnknowniPhone,
    kTCDeviceUnknowniPod,
    kTCDeviceUnknowniPad,
    kTCDeviceUnknownAppleTV,
    
    
    kTCDeviceCount,
};

typedef NS_ENUM(NSInteger, TCDeviceFamily) {
    kTCDeviceFamilyUnknown = 0,
    kTCDeviceFamilyiPhone,
    kTCDeviceFamilyiPod,
    kTCDeviceFamilyiPad,
    kTCDeviceFamilyAppleTV,
};

typedef NS_ENUM(NSInteger, TCDeviceScreen) {
    kTCDeviceScreenUnknown = 0,
    kTCDeviceScreen3Dot5inch,
    kTCDeviceScreen4inch,
    kTCDeviceScreen4Dot7inch,
    kTCDeviceScreen5Dot5inch,
};


@interface UIDevice (TCHardware)

- (NSString *)platform;
- (NSString *)hwmodel;
- (TCDevicePlatform)platformType;
- (NSString *)platformString;
- (TCDeviceScreen)deivceScreen;

- (NSUInteger)cpuFrequency;
- (NSUInteger)busFrequency;
- (NSUInteger)cpuCount;
- (NSUInteger)totalMemory;
- (NSUInteger)userMemory;

- (NSNumber *)totalDiskSpace;
- (NSNumber *)freeDiskSpace;

- (NSString *)macaddress;

- (BOOL)hasRetinaDisplay;
- (TCDeviceFamily)deviceFamily;

@end