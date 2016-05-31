//
//  iConsole.h
//
//  Version 1.5.1
//
//  Created by Nick Lockwood on 20/12/2010.
//  Copyright 2010 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/iConsole
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//


#ifndef TC_IOS_PUBLISH

#import <UIKit/UIKit.h>


#import <Availability.h>
#undef weak_delegate
#if __has_feature(objc_arc_weak)
#define weak_delegate weak
#else
#define weak_delegate unsafe_unretained
#endif


#define ICONSOLE_ADD_EXCEPTION_HANDLER 1 //add automatic crash logging


typedef enum
{
    iConsoleLogLevelNone = 0,
    iConsoleLogLevelCrash,
    iConsoleLogLevelError,
    iConsoleLogLevelWarning,
    iConsoleLogLevelInfo
}
iConsoleLogLevel;


@protocol iConsoleDelegate <NSObject>

@optional
+ (void)handleConsoleCommand:(NSString *)command;
- (void)handleConsoleCommand:(NSString *)command;

+ (void)debugPanelTapped:(UIViewController *)parentCtrler;
- (void)debugPanelTapped:(UIViewController *)parentCtrler;

@end


@interface iConsole : UIViewController

//enabled/disable console features

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL saveLogToDisk;
@property (nonatomic, assign) NSUInteger maxLogItems;
@property (nonatomic, assign) iConsoleLogLevel logLevel;
@property (nonatomic, weak_delegate) id<iConsoleDelegate> delegate;

//console activation

@property (nonatomic, assign) NSUInteger simulatorTouchesToShow;
@property (nonatomic, assign) NSUInteger deviceTouchesToShow;
@property (nonatomic, assign) BOOL simulatorShakeToShow;
@property (nonatomic, assign) BOOL deviceShakeToShow;

//branding and feedback

@property (nonatomic, copy) NSString *infoString;
@property (nonatomic, copy) NSString *inputPlaceholderString;
@property (nonatomic, copy) NSString *logSubmissionEmail;

//styling

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *textColor;

//methods

+ (iConsole *)sharedConsole;

+ (void)log:(NSString *)format, ...;
+ (void)info:(NSString *)format, ...;
+ (void)warn:(NSString *)format, ...;
+ (void)error:(NSString *)format, ...;
+ (void)crash:(NSString *)format, ...;

+ (void)clear;

+ (void)show;
+ (void)hide;

@end


@interface iConsoleWindow : UIWindow

@end

#endif