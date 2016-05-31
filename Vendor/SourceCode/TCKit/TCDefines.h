//
//  TCDefines.h
//  TCKit
//
//  Created by dake on 13-1-30.
//  Copyright (c) 2013年 dake. All rights reserved.
//

#ifndef TCDefines_h
#define TCDefines_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef TARGET_OS_IOS
#define TARGET_OS_IOS TARGET_OS_IPHONE
#endif
#ifndef TARGET_OS_WATCH
#define TARGET_OS_WATCH 0
#endif


#define PropertySTR(name)   NSStringFromSelector(@selector(name))
#define _URL(name) [NSURL URLWithString:name]


#pragma mark - onExit

NS_INLINE void _tc_blockCleanUp(__strong void(^*block)(void)) {
    (*block)();
}
#define tc_onExit \
__strong void(^block)(void) __attribute__((cleanup(_tc_blockCleanUp), unused)) = ^


#pragma mark - UIDevice Helpers

NS_INLINE BOOL IS_IPAD(void)
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

NS_INLINE NSComparisonResult COMPARE_SYSTEM_VERSION(NSString *v)
{
    return [[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch];
}

NS_INLINE BOOL SYSTEM_VERSION_EQUAL_TO(NSString *v)
{
    return COMPARE_SYSTEM_VERSION(v) == NSOrderedSame;
}

NS_INLINE BOOL SYSTEM_VERSION_GREATER_THAN(NSString *v)
{
    return COMPARE_SYSTEM_VERSION(v) == NSOrderedDescending;
}

NS_INLINE BOOL SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(NSString *v)
{
    return COMPARE_SYSTEM_VERSION(v) != NSOrderedAscending;
}

NS_INLINE BOOL SYSTEM_VERSION_LESS_THAN(NSString *v)
{
    return COMPARE_SYSTEM_VERSION(v) == NSOrderedAscending;
}

NS_INLINE BOOL SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(NSString *v)
{
    return COMPARE_SYSTEM_VERSION(v) != NSOrderedDescending;
}


NS_INLINE void tc_dispatch_main_sync_safe(dispatch_block_t block)
{
    if (nil == block) {
        return;
    }
    
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

NS_INLINE void tc_dispatch_main_async_safe(dispatch_block_t block)
{
    if (nil == block) {
        return;
    }
    
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

#endif // TCDefines_h

