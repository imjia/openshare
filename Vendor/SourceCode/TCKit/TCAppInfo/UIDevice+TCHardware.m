/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

/** Thanks to
 https://github.com/Ekhoo/Device/blob/master/Source/Device.swift
 https://github.com/lmirosevic/GBDeviceInfo
 */

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "UIDevice+TCHardware.h"

static NSString *s_device_names[kTCDeviceCount] = {

    [kTCDeviceUnknown] = @"Unknown iOS device",
    
    // iPhone
    [kTCDevice1GiPhone] = @"iPhone 1G",
    [kTCDevice3GiPhone] = @"iPhone 3G",
    [kTCDevice3GSiPhone] = @"iPhone 3GS",
    [kTCDevice4iPhone] = @"iPhone 4",
    [kTCDevice4SiPhone] = @"iPhone 4S",
    [kTCDevice5iPhone] = @"iPhone 5",
    [kTCDevice5CiPhone] = @"iPhone 5C",
    [kTCDevice5SiPhone] = @"iPhone 5S",
    [kTCDevice6iPhone] = @"iPhone 6",
    [kTCDevice6PlusiPhone] = @"iPhone 6 Plus",
    [kTCDevice6SiPhone] = @"iPhone 6S",
    [kTCDevice6SPlusiPhone] = @"iPhone 6S Plus",
    [kTCDeviceUnknowniPhone] = @"Unknown iPhone",
    
    // iPod
    [kTCDevice1GiPod] = @"iPod touch 1G",
    [kTCDevice2GiPod] = @"iPod touch 2G",
    [kTCDevice3GiPod] = @"iPod touch 3G",
    [kTCDevice4GiPod] = @"iPod touch 4G",
    [kTCDevice5GiPod] = @"iPod touch 5G",
    [kTCDevice6GiPod] = @"iPod touch 6G",
    [kTCDeviceUnknowniPod] = @"Unknown iPod",
    
    // iPad
    [kTCDevice1GiPad] = @"iPad 1G",
    [kTCDevice2GiPad] = @"iPad 2G",
    [kTCDevice3GiPad] = @"iPad 3G",
    [kTCDevice4GiPad] = @"iPad 4G",
    
    // iPad mini
    [kTCDevice1GiPadMini] = @"iPad Mini 1G",
    [kTCDevice2GiPadMini] = @"iPad Mini 2G",
    [kTCDevice3GiPadMini] = @"iPad Mini 3G",
    [kTCDevice4GiPadMini] = @"iPad Mini 4G",
    
    // ipad Air
    [kTCDevice1GiPadAir] = @"iPad Air 1G",
    [kTCDevice2GiPadAir] = @"iPad Air 2G",
    [kTCDeviceUnknowniPad] = @"Unknown iPad",
    
    // ipad pro
    [kTCDevice1GiPadPro] = @"iPad Pro 1G",
    
    // apple TV
    [kTCDeviceAppleTV2] = @"Apple TV 2G",
    [kTCDeviceAppleTV3] = @"Apple TV 3G",
    [kTCDeviceAppleTV4] = @"Apple TV 4G",
    [kTCDeviceUnknownAppleTV] = @"Unknown Apple TV",
    
    // simulator
    [kTCDeviceSimulator] = @"iPhone Simulator",
    [kTCDeviceSimulatoriPhone] = @"iPhone Simulator",
    [kTCDeviceSimulatoriPad] = @"iPad Simulator",
    [kTCDeviceSimulatorAppleTV] = @"Apple TV Simulator",
};

@implementation UIDevice (TCHardware)


#pragma mark - sysctlbyname utils

- (NSString *)getSysInfoByName:(char *)typeSpecifier
{
    size_t size = 0;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];

    free(answer);
    return results;
}

- (NSString *)platform
{
    return [self getSysInfoByName:"hw.machine"];
}


// Thanks, Tom Harrington (Atomicbird)
- (NSString *)hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}


#pragma mark - sysctl utils

- (NSUInteger)getSysInfo:(uint)typeSpecifier
{
    NSUInteger results = 0;
    size_t size = sizeof(results);
    int mib[] = {CTL_HW, typeSpecifier};
    sysctl(mib, sizeof(mib)/sizeof(mib[0]), &results, &size, NULL, 0);
    return results;
}

- (NSUInteger)cpuFrequency
{
    return [self getSysInfo:HW_CPU_FREQ];
}

- (NSUInteger)busFrequency
{
    return [self getSysInfo:HW_BUS_FREQ];
}

- (NSUInteger)cpuCount
{
    return [self getSysInfo:HW_NCPU];
}

- (NSUInteger)totalMemory
{
    return [self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger)userMemory
{
    return [self getSysInfo:HW_USERMEM];
}

- (NSUInteger)maxSocketBufferSize
{
    return [self getSysInfo:KIPC_MAXSOCKBUF];
}

#pragma mark file system -- Thanks Joachim Bean!

/*
 extern NSString *NSFileSystemSize;
 extern NSString *NSFileSystemFreeSize;
 extern NSString *NSFileSystemNodes;
 extern NSString *NSFileSystemFreeNodes;
 extern NSString *NSFileSystemNumber;
*/

- (NSNumber *)totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:NULL];
    return [fattributes objectForKey:NSFileSystemSize];
}

- (NSNumber *)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:NULL];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}


#pragma mark - platform type and name utils

- (TCDevicePlatform)platformType
{
    NSString *platform = self.platform;

    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])         return kTCDevice1GiPhone;
    else if ([platform isEqualToString:@"iPhone1,2"])    return kTCDevice3GiPhone;
    else if ([platform hasPrefix:@"iPhone2"])            return kTCDevice3GSiPhone;
    else if ([platform hasPrefix:@"iPhone3"])            return kTCDevice4iPhone;
    else if ([platform hasPrefix:@"iPhone4"])            return kTCDevice4SiPhone;
    else if ([platform hasPrefix:@"iPhone5"]) {
        NSInteger subVersion = [[[platform componentsSeparatedByString:@","] lastObject] integerValue];
        if (subVersion <= 2) {
            return kTCDevice5iPhone;
        } else if (subVersion <= 4) {
            return kTCDevice5CiPhone;
        }
    }
    else if ([platform hasPrefix:@"iPhone6"])            return kTCDevice5SiPhone;
    else if ([platform hasPrefix:@"iPhone7,1"])          return kTCDevice6PlusiPhone;
    else if ([platform hasPrefix:@"iPhone7,2"])          return kTCDevice6iPhone;
    else if ([platform hasPrefix:@"iPhone8,1"])          return kTCDevice6SiPhone;
    else if ([platform hasPrefix:@"iPhone8,2"])          return kTCDevice6SPlusiPhone;
    
    // iPod
    else if ([platform hasPrefix:@"iPod1"])              return kTCDevice1GiPod;
    else if ([platform hasPrefix:@"iPod2"])              return kTCDevice2GiPod;
    else if ([platform hasPrefix:@"iPod3"])              return kTCDevice3GiPod;
    else if ([platform hasPrefix:@"iPod4"])              return kTCDevice4GiPod;
    else if ([platform hasPrefix:@"iPod5"])              return kTCDevice5GiPod;
    else if ([platform hasPrefix:@"iPod7"])              return kTCDevice6GiPod;

    // iPad
    else if ([platform hasPrefix:@"iPad1"])              return kTCDevice1GiPad;
    else if ([platform hasPrefix:@"iPad2"]) {
        NSInteger subVersion = [[[platform componentsSeparatedByString:@","] lastObject] integerValue];
        if (subVersion <= 4) {
            return kTCDevice2GiPad;
        } else if (subVersion <= 7) {
            return kTCDevice1GiPadMini;
        }
    }
    else if ([platform hasPrefix:@"iPad3"]) {
        NSInteger subVersion = [[[platform componentsSeparatedByString:@","] lastObject] integerValue];
        if (subVersion <= 3) {
            return kTCDevice3GiPad;
        } else if (subVersion <= 6) {
            return kTCDevice4GiPad;
        }
    }
    else if ([platform hasPrefix:@"iPad4"]) {
        NSInteger subVersion = [[[platform componentsSeparatedByString:@","] lastObject] integerValue];
        if (subVersion <= 3) {
            return kTCDevice1GiPadAir;
        } else if (subVersion <= 6) {
            return kTCDevice2GiPadMini;
        } else if (subVersion <= 9) {
            return kTCDevice3GiPadMini;
        }
    }
    else if ([platform hasPrefix:@"iPad5"]) {
        NSInteger subVersion = [[[platform componentsSeparatedByString:@","] lastObject] integerValue];
        if (subVersion <= 2) {
            return kTCDevice4GiPadMini;
        } else if (subVersion <= 4) {
            return kTCDevice2GiPadAir;
        }
    }
    else if ([platform hasPrefix:@"iPad6"])              return kTCDevice1GiPadPro;
    
    // Apple TV
    else if ([platform hasPrefix:@"AppleTV2"])           return kTCDeviceAppleTV2;
    else if ([platform hasPrefix:@"AppleTV3"])           return kTCDeviceAppleTV3;
    
    // Simulator thanks Jordan Breeding
    else if ([platform hasSuffix:@"86"] || [platform isEqualToString:@"x86_64"]) {
        switch (UI_USER_INTERFACE_IDIOM()) {
            case UIUserInterfaceIdiomPad: return kTCDeviceSimulatoriPad;
            case UIUserInterfaceIdiomPhone: return kTCDeviceSimulatoriPhone;
            default:
                break;
        }
    }

    if ([platform hasPrefix:@"iPhone"])             return kTCDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"])               return kTCDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"])               return kTCDeviceUnknowniPad;
    if ([platform hasPrefix:@"AppleTV"])            return kTCDeviceUnknownAppleTV;
    
    return kTCDeviceUnknown;
}

- (NSString *)platformString
{
    TCDevicePlatform type = self.platformType;
    if (type < kTCDeviceUnknown || type >= kTCDeviceCount) {
        type = kTCDeviceUnknown;
    }
    
    if (type == kTCDeviceUnknown ||
        type == kTCDeviceUnknowniPhone ||
        type == kTCDeviceUnknowniPod ||
        type == kTCDeviceUnknowniPad ||
        type == kTCDeviceUnknownAppleTV) {
        return self.platform;
    }
    
    return s_device_names[type];
}

- (TCDeviceScreen)deivceScreen
{
    CGSize size = UIScreen.mainScreen.bounds.size;
    CGFloat screenHeight = MAX(size.height, size.width);
    
    if (screenHeight == 480.0f) {
        return kTCDeviceScreen3Dot5inch;
    } else if (screenHeight == 568.0f) {
        return kTCDeviceScreen4inch;
    } else if (screenHeight == 667.0f) {
        return UIScreen.mainScreen.scale > 2.9f ? kTCDeviceScreen5Dot5inch : kTCDeviceScreen4Dot7inch;
    } else if (screenHeight == 736.0f) {
        return kTCDeviceScreen5Dot5inch;
    } else {
        return kTCDeviceScreenUnknown;
    }
}

- (BOOL)hasRetinaDisplay
{
    return UIScreen.mainScreen.scale >= 2.0f;
}

- (TCDeviceFamily)deviceFamily
{
    NSString *platform = self.platform;
    if ([platform hasPrefix:@"iPhone"]) return kTCDeviceFamilyiPhone;
    if ([platform hasPrefix:@"iPod"]) return kTCDeviceFamilyiPod;
    if ([platform hasPrefix:@"iPad"]) return kTCDeviceFamilyiPad;
    if ([platform hasPrefix:@"AppleTV"]) return kTCDeviceFamilyAppleTV;
    
    return kTCDeviceFamilyUnknown;
}

#pragma mark - MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *)macaddress
{
    int mib[] = {
        CTL_NET,
        AF_ROUTE,
        0,
        AF_LINK,
        NET_RT_IFLIST,
        0
    };
    u_int size = sizeof(mib)/sizeof(mib[0]);
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return nil;
    }
    
    size_t len = 0;
    if (sysctl(mib, size, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return nil;
    }
    
    char *buf = malloc(len);
    if (buf == NULL) {
        printf("Error: Memory allocation error\n");
        return nil;
    }
    
    if (sysctl(mib, size, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return nil;
    }
    
    struct if_msghdr *ifm = (struct if_msghdr *)buf;
    struct sockaddr_dl *sdl = (struct sockaddr_dl *)(ifm + 1);
    unsigned char *ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];

    free(buf);
    return outstring;
}

// Illicit Bluetooth check -- cannot be used in App Store
/* 
Class  btclass = NSClassFromString(@"GKBluetoothSupport");
if ([btclass respondsToSelector:@selector(bluetoothStatus)])
{
    printf("BTStatus %d\n", ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0);
    bluetooth = ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0;
    printf("Bluetooth %s enabled\n", bluetooth ? "is" : "isn't");
}
*/
@end