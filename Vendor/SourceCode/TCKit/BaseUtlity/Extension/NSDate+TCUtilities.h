/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook 3.x and beyond
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

extern NSInteger D_MINUTE;
extern NSInteger D_HOUR;
extern NSInteger D_DAY;
extern NSInteger D_WEEK;
extern NSInteger D_YEAR;

@interface NSDate (TCUtilities)

+ (NSCalendar *)currentCalendar; // avoid bottlenecks
+ (NSDateFormatter *)dateFormatter;

// Relative dates from the current date
+ (instancetype)dateTomorrow;
+ (instancetype)dateYesterday;
+ (instancetype)dateWithDaysFromNow:(NSInteger)days;
+ (instancetype)dateWithDaysBeforeNow:(NSInteger)days;
+ (instancetype)dateWithHoursFromNow:(NSInteger)dHours;
+ (instancetype)dateWithHoursBeforeNow:(NSInteger)dHours;
+ (instancetype)dateWithMinutesFromNow:(NSInteger)dMinutes;
+ (instancetype)dateWithMinutesBeforeNow:(NSInteger)dMinutes;

// Short string utilities
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;
- (NSString *)stringWithFormat:(NSString *)format;

@property (nonatomic, readonly) NSString *shortString;
@property (nonatomic, readonly) NSString *shortDateString;
@property (nonatomic, readonly) NSString *shortTimeString;
@property (nonatomic, readonly) NSString *mediumString;
@property (nonatomic, readonly) NSString *mediumDateString;
@property (nonatomic, readonly) NSString *mediumTimeString;
@property (nonatomic, readonly) NSString *longString;
@property (nonatomic, readonly) NSString *longDateString;
@property (nonatomic, readonly) NSString *longTimeString;

// Comparing dates
- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate;

- (BOOL)isToday;
- (BOOL)isTomorrow;
- (BOOL)isYesterday;

- (BOOL)isSameWeekAsDate:(NSDate *)aDate;
- (BOOL)isThisWeek;
- (BOOL)isNextWeek;
- (BOOL)isLastWeek;

- (BOOL)isSameMonthAsDate:(NSDate *)aDate;
- (BOOL)isThisMonth;
- (BOOL)isNextMonth;
- (BOOL)isLastMonth;

- (BOOL)isSameYearAsDate:(NSDate *)aDate;
- (BOOL)isThisYear;
- (BOOL)isNextYear;
- (BOOL)isLastYear;

- (BOOL)isEarlierThanDate:(NSDate *)aDate;
- (BOOL)isLaterThanDate:(NSDate *)aDate;

- (BOOL)isInFuture;
- (BOOL)isInPast;

// Date roles
- (BOOL)isTypicallyWorkday;
- (BOOL)isTypicallyWeekend;

// Adjusting dates
- (instancetype)dateByAddingYears:(NSInteger)dYears;
- (instancetype)dateBySubtractingYears:(NSInteger)dYears;
- (instancetype)dateByAddingMonths:(NSInteger)dMonths;
- (instancetype)dateBySubtractingMonths:(NSInteger)dMonths;
- (instancetype)dateByAddingDays:(NSInteger)dDays;
- (instancetype)dateBySubtractingDays:(NSInteger)dDays;
- (instancetype)dateByAddingHours:(NSInteger)dHours;
- (instancetype)dateBySubtractingHours:(NSInteger)dHours;
- (instancetype)dateByAddingMinutes:(NSInteger)dMinutes;
- (instancetype)dateBySubtractingMinutes:(NSInteger)dMinutes;

// Date extremes
- (instancetype)dateAtStartOfDay;
- (instancetype)dateAtEndOfDay;

// Retrieving intervals
- (NSInteger)minutesAfterDate:(NSDate *)aDate;
- (NSInteger)minutesBeforeDate:(NSDate *)aDate;
- (NSInteger)hoursAfterDate:(NSDate *)aDate;
- (NSInteger)hoursBeforeDate:(NSDate *)aDate;
- (NSInteger)daysAfterDate:(NSDate *)aDate;
- (NSInteger)daysBeforeDate:(NSDate *)aDate;
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate;

// Decomposing dates
@property (nonatomic, readonly) NSInteger nearestHour;
@property (nonatomic, readonly) NSInteger hour;
@property (nonatomic, readonly) NSInteger minute;
@property (nonatomic, readonly) NSInteger seconds;
@property (nonatomic, readonly) NSInteger day;
@property (nonatomic, readonly) NSInteger month;
@property (nonatomic, readonly) NSInteger weekOfYear;
@property (nonatomic, readonly) NSInteger weekOfMonth;
@property (nonatomic, readonly) NSInteger weekday;
@property (nonatomic, readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (nonatomic, readonly) NSInteger year;

@end
