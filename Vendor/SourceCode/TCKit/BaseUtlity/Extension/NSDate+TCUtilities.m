/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook 3.x and beyond
 BSD License, Use at your own risk
 */

/*
 #import <humor.h> : Not planning to implement: dateByAskingBoyOut and dateByGettingBabysitter
 ----
 General Thanks: sstreza, Scott Lawrence, Kevin Ballard, NoOneButMe, Avi`, August Joki. Emanuele Vulcano, jcromartiej, Blagovest Dachev, Matthias Plappert,  Slava Bushtruk, Ali Servet Donmez, Ricardo1980, pip8786, Danny Thuerin, Dennis Madsen
 
 Include GMT and time zone utilities?
*/

#import "NSDate+TCUtilities.h"

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0)
#define NSYearCalendarUnit                  NSCalendarUnitYear
#define NSMonthCalendarUnit                 NSCalendarUnitMonth
#define NSDayCalendarUnit                   NSCalendarUnitDay
#define NSHourCalendarUnit                  NSCalendarUnitHour
#define NSMinuteCalendarUnit                NSCalendarUnitMinute
#define NSSecondCalendarUnit                NSCalendarUnitSecond
#define NSWeekdayCalendarUnit               NSCalendarUnitWeekday
#define NSWeekdayOrdinalCalendarUnit        NSCalendarUnitWeekdayOrdinal
#define NSWeekCalendarUnit                  (NSCalendarUnitWeekOfYear|NSCalendarUnitWeekOfMonth)

#define NSGregorianCalendar  NSCalendarIdentifierGregorian

#endif

NSInteger D_MINUTE = 60;
NSInteger D_HOUR = 3600;
NSInteger D_DAY = 86400;
NSInteger D_WEEK = 604800;
NSInteger D_YEAR = 31556926;

// Thanks, AshFurrow
static const NSUInteger kComponentFlags = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit);

@implementation NSDate (TCUtilities)

// Courtesy of Lukasz Margielewski
// Updated via Holger Haenisch
+ (NSCalendar *)currentCalendar
{
    return [NSCalendar autoupdatingCurrentCalendar];
}

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *s_fmt = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_fmt = [[NSDateFormatter alloc] init];
        s_fmt.locale = NSLocale.autoupdatingCurrentLocale;
    });
    
    return s_fmt;
}


#pragma mark - Relative Dates

+ (instancetype)dateWithDaysFromNow:(NSInteger)days
{
    // Thanks, Jim Morrison
	return [[NSDate date] dateByAddingDays:days];
}

+ (instancetype)dateWithDaysBeforeNow:(NSInteger)days
{
    // Thanks, Jim Morrison
	return [[NSDate date] dateBySubtractingDays:days];
}

+ (instancetype)dateTomorrow
{
	return [self dateWithDaysFromNow:1];
}

+ (instancetype)dateYesterday
{
	return [self dateWithDaysBeforeNow:1];
}

+ (instancetype)dateWithHoursFromNow:(NSInteger)dHours
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	return [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
}

+ (instancetype)dateWithHoursBeforeNow:(NSInteger)dHours
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
	return [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
}

+ (instancetype)dateWithMinutesFromNow:(NSInteger)dMinutes
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	return [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
}

+ (instancetype)dateWithMinutesBeforeNow:(NSInteger)dMinutes
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
	return [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
}


#pragma mark - String Properties

- (NSString *)stringWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = self.class.dateFormatter;
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
    NSDateFormatter *formatter = self.class.dateFormatter;
    formatter.dateStyle = dateStyle;
    formatter.timeStyle = timeStyle;
    formatter.dateFormat = nil;
    return [formatter stringFromDate:self];
}

- (NSString *)shortString
{
    return [self stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)shortTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)shortDateString
{
    return [self stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)mediumString
{
    return [self stringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
}

- (NSString *)mediumTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
}

- (NSString *)mediumDateString
{
    return [self stringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)longString
{
    return [self stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
}

- (NSString *)longTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterLongStyle];
}

- (NSString *)longDateString
{
    return [self stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
}


#pragma mark - Comparing Dates

- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate
{
    NSDateComponents *components1 = [self.class.currentCalendar components:kComponentFlags fromDate:self];
    NSDateComponents *components2 = [self.class.currentCalendar components:kComponentFlags fromDate:aDate];
    return (components1.year == components2.year) &&
    (components1.month == components2.month) &&
    (components1.day == components2.day);
}

- (BOOL)isToday
{
	return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL)isTomorrow
{
	return [self isEqualToDateIgnoringTime:self.class.dateTomorrow];
}

- (BOOL)isYesterday
{
	return [self isEqualToDateIgnoringTime:self.class.dateYesterday];
}

// This hard codes the assumption that a week is 7 days
- (BOOL)isSameWeekAsDate:(NSDate *)aDate
{
	NSDateComponents *components1 = [self.class.currentCalendar components:kComponentFlags fromDate:self];
	NSDateComponents *components2 = [self.class.currentCalendar components:kComponentFlags fromDate:aDate];
	
	// Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
    if (components1.weekOfYear != components2.weekOfYear) {
        return NO;
    }
	
	// Must have a time interval under 1 week. Thanks @aclark
	return (ABS([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL)isThisWeek
{
	return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL)isNextWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameWeekAsDate:newDate];
}

- (BOOL)isLastWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameWeekAsDate:newDate];
}

// Thanks, mspasov
- (BOOL)isSameMonthAsDate:(NSDate *)aDate
{
    NSDateComponents *components1 = [self.class.currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
    NSDateComponents *components2 = [self.class.currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:aDate];
    return (components1.month == components2.month) && (components1.year == components2.year);
}

- (BOOL)isThisMonth
{
    return [self isSameMonthAsDate:[NSDate date]];
}

// Thanks Marcin Krzyzanowski, also for adding/subtracting years and months
- (BOOL)isLastMonth
{
    return [self isSameMonthAsDate:[[NSDate date] dateBySubtractingMonths:1]];
}

- (BOOL)isNextMonth
{
    return [self isSameMonthAsDate:[[NSDate date] dateByAddingMonths:1]];
}

- (BOOL)isSameYearAsDate:(NSDate *)aDate
{
	NSDateComponents *components1 = [self.class.currentCalendar components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [self.class.currentCalendar components:NSYearCalendarUnit fromDate:aDate];
	return (components1.year == components2.year);
}

- (BOOL)isThisYear
{
    // Thanks, baspellis
	return [self isSameYearAsDate:[NSDate date]];
}

- (BOOL)isNextYear
{
	NSDateComponents *components1 = [self.class.currentCalendar components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [self.class.currentCalendar components:NSYearCalendarUnit fromDate:[NSDate date]];
	
	return (components1.year == (components2.year + 1));
}

- (BOOL)isLastYear
{
	NSDateComponents *components1 = [self.class.currentCalendar components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [self.class.currentCalendar components:NSYearCalendarUnit fromDate:[NSDate date]];
	
	return (components1.year == (components2.year - 1));
}

- (BOOL)isEarlierThanDate:(NSDate *)aDate
{
	return [self compare:aDate] == NSOrderedAscending;
}

- (BOOL)isLaterThanDate:(NSDate *)aDate
{
	return [self compare:aDate] == NSOrderedDescending;
}

// Thanks, markrickert
- (BOOL)isInFuture
{
    return [self isLaterThanDate:[NSDate date]];
}

// Thanks, markrickert
- (BOOL)isInPast
{
    return [self isEarlierThanDate:[NSDate date]];
}


#pragma mark - Roles

- (BOOL)isTypicallyWeekend
{
    NSDateComponents *components = [self.class.currentCalendar components:NSWeekdayCalendarUnit fromDate:self];
    return components.weekday == 1 || components.weekday == 7;
}

- (BOOL)isTypicallyWorkday
{
    return !self.isTypicallyWeekend;
}


#pragma mark - Adjusting Dates

// Thaks, rsjohnson
- (instancetype)dateByAddingYears:(NSInteger)dYears
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = dYears;
    return [self.class.currentCalendar dateByAddingComponents:dateComponents toDate:self options:kNilOptions];
}

- (instancetype)dateBySubtractingYears:(NSInteger)dYears
{
    return [self dateByAddingYears:-dYears];
}

- (instancetype)dateByAddingMonths:(NSInteger)dMonths
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = dMonths;
    return [self.class.currentCalendar dateByAddingComponents:dateComponents toDate:self options:kNilOptions];
}

- (instancetype)dateBySubtractingMonths:(NSInteger)dMonths
{
    return [self dateByAddingMonths:-dMonths];
}

// Courtesy of dedan who mentions issues with Daylight Savings
- (instancetype)dateByAddingDays:(NSInteger)dDays
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = dDays;
    return [self.class.currentCalendar dateByAddingComponents:dateComponents toDate:self options:kNilOptions];
}

- (instancetype)dateBySubtractingDays:(NSInteger)dDays
{
	return [self dateByAddingDays:-dDays];
}

- (instancetype)dateByAddingHours:(NSInteger)dHours
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	return [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
}

- (instancetype)dateBySubtractingHours:(NSInteger)dHours
{
	return [self dateByAddingHours:-dHours];
}

- (instancetype)dateByAddingMinutes:(NSInteger)dMinutes
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	return [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
}

- (instancetype)dateBySubtractingMinutes:(NSInteger)dMinutes
{
	return [self dateByAddingMinutes:-dMinutes];
}

- (NSDateComponents *)componentsWithOffsetFromDate:(NSDate *)aDate
{
	return [self.class.currentCalendar components:kComponentFlags fromDate:aDate toDate:self options:kNilOptions];
}


#pragma mark - Extremes

- (instancetype)dateAtStartOfDay
{
	NSDateComponents *components = [self.class.currentCalendar components:kComponentFlags fromDate:self];
	components.hour = 0;
	components.minute = 0;
	components.second = 0;
	return [self.class.currentCalendar dateFromComponents:components];
}

// Thanks gsempe & mteece
- (instancetype)dateAtEndOfDay
{
	NSDateComponents *components = [self.class.currentCalendar components:kComponentFlags fromDate:self];
	components.hour = 23; // Thanks Aleksey Kononov
	components.minute = 59;
	components.second = 59;
	return [self.class.currentCalendar dateFromComponents:components];
}

#pragma mark - Retrieving Intervals

- (NSInteger)minutesAfterDate:(NSDate *)aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger)(ti / D_MINUTE);
}

- (NSInteger)minutesBeforeDate:(NSDate *)aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger)(ti / D_MINUTE);
}

- (NSInteger)hoursAfterDate:(NSDate *)aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger)(ti / D_HOUR);
}

- (NSInteger)hoursBeforeDate:(NSDate *)aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger)(ti / D_HOUR);
}

- (NSInteger)daysAfterDate:(NSDate *)aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger)(ti / D_DAY);
}

- (NSInteger)daysBeforeDate:(NSDate *)aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger)(ti / D_DAY);
}

// Thanks, dmitrydims
// I have not yet thoroughly tested this
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:self toDate:anotherDate options:kNilOptions];
    return components.day;
}


#pragma mark - Decomposing Dates

- (NSInteger)nearestHour
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	NSDateComponents *components = [self.class.currentCalendar components:NSHourCalendarUnit fromDate:newDate];
	return components.hour;
}

- (NSInteger)hour
{
	NSDateComponents *components = [self.class.currentCalendar components:kComponentFlags fromDate:self];
	return components.hour;
}

- (NSInteger)minute
{
	NSDateComponents *components = [self.class.currentCalendar components:kComponentFlags fromDate:self];
	return components.minute;
}

- (NSInteger)seconds
{
	NSDateComponents *components = [self.class.currentCalendar components:kComponentFlags fromDate:self];
	return components.second;
}

- (NSInteger)day
{
	NSDateComponents *components = [self.class.currentCalendar components:kComponentFlags fromDate:self];
	return components.day;
}

- (NSInteger)month
{
	NSDateComponents *components = [self.class.currentCalendar components:kComponentFlags fromDate:self];
	return components.month;
}

- (NSInteger)weekOfYear
{
	NSDateComponents *components = [self.class.currentCalendar components:kComponentFlags fromDate:self];
	return components.weekOfYear;
}

- (NSInteger)weekOfMonth
{
    NSDateComponents *components = [self.class.currentCalendar components:kComponentFlags fromDate:self];
    return components.weekOfMonth;
}

- (NSInteger)weekday
{
	NSDateComponents *components = [self.class.currentCalendar components:kComponentFlags fromDate:self];
	return components.weekday;
}

- (NSInteger)nthWeekday // e.g. 2nd Tuesday of the month is 2
{
	NSDateComponents *components = [self.class.currentCalendar components:kComponentFlags fromDate:self];
	return components.weekdayOrdinal;
}

- (NSInteger)year
{
	NSDateComponents *components = [self.class.currentCalendar components:kComponentFlags fromDate:self];
	return components.year;
}

@end