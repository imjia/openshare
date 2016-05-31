/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface NSObject (TCUtilities)

@property (nonatomic, strong) id tcUserInfo;

+ (void)tc_swizzle:(SEL)aSelector;


// Selector Utilities
- (NSInvocation *)invocationWithSelectorAndArguments:(SEL)selector, ...;
- (BOOL)performSelector:(SEL)selector withReturnValueAndArguments:(void *)result, ...;
- (const char *)returnTypeForSelector:(SEL)selector;

// Request return value from performing selector
- (id)objectByPerformingSelectorWithArguments:(SEL)selector, ...;
- (__autoreleasing id)objectByPerformingSelector:(SEL)selector withObject:(id)object1 andObject:(id)object2;
- (id)objectByPerformingSelector:(SEL)selector withObject:(id)object1;
- (id)objectByPerformingSelector:(SEL)selector;

// Delay Utilities
+ (void)performBlock:(dispatch_block_t)block afterDelay:(NSTimeInterval)delay;
- (void)performBlock:(dispatch_block_t)block afterDelay:(NSTimeInterval)delay;

- (void)performSelector:(SEL)selector withCPointer:(void *)cPointer afterDelay:(NSTimeInterval)delay;
- (void)performSelector:(SEL)selector withInt:(int)intValue afterDelay:(NSTimeInterval)delay;
- (void)performSelector:(SEL)selector withFloat:(float)floatValue afterDelay:(NSTimeInterval)delay;
- (void)performSelector:(SEL)selector withBool:(BOOL)boolValue afterDelay:(NSTimeInterval)delay;
- (void)performSelector:(SEL)selector afterDelay:(NSTimeInterval)delay;
- (void)performSelector:(SEL)selector withDelayAndArguments:(NSTimeInterval)delay, ...;


#pragma mark - DEBUG

#ifdef DEBUG

// Access to object essentials for run-time checks. Stored by class in dictionary.
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSArray<NSString *> *> *selectors;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSArray<NSString *> *> *properties;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSArray<NSString *> *> *ivars;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSArray<NSString *> *> *protocols;


// Return all superclasses of object
+ (NSArray<Class> *)superclasses;
- (NSArray<Class> *)superclasses;

// Examine
+ (NSString *)dump;
- (NSString *)dump;

+ (NSArray<NSString *> *)getPropertyListForClass;

// Check for properties, ivar. Use respondsToSelector: and conformsToProtocol: as well
- (BOOL)hasProperty:(NSString *)propertyName;
- (BOOL)hasIvar:(NSString *)ivarName;
+ (BOOL)classExists:(NSString *)className;

// Choose the first selector that the object responds to
- (SEL)chooseSelector:(SEL)aSelector, ...;

#endif

@end