/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>


typedef id (^MapBlock)(id object);
typedef BOOL (^TestingBlock)(id object);


@interface NSArray (TCUtilities)

// Utility
@property (nonatomic, strong, readonly) NSArray *reversed;
@property (nonatomic, strong, readonly) NSArray *sorted;
@property (nonatomic, strong, readonly) NSArray *sortedCaseInsensitive;


// Setification
@property (nonatomic, strong, readonly) NSArray *uniqueElements;

- (id)topObject;

- (instancetype)unionWithArray:(NSArray *)anArray;
- (instancetype)intersectionWithArray:(NSArray *)anArray;
- (instancetype)differenceToArray:(NSArray *)anArray;


// Lisp
- (instancetype)map:(MapBlock)aBlock;
- (instancetype)collect:(TestingBlock)aBlock;
- (instancetype)reject:(TestingBlock)aBlock;

@end

@interface NSMutableArray (TCUtilities)
- (instancetype)reverse;
//- (NSMutableArray *) scramble;

@end

@interface NSMutableArray (TC_StackAndQueueExtensions)

- (id)popObject;
- (id)pullObject;
- (instancetype)pushObject:(id)object;
- (instancetype)pushObjects:(id)object, ...;

@end

