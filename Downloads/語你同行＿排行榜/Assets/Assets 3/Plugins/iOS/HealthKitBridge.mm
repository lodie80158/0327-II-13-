#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <UIKit/UIKit.h>

extern "C" {

// 共用 HealthStore 實例
HKHealthStore *GetHealthStore() {
    static HKHealthStore *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[HKHealthStore alloc] init];
    });
    return sharedStore;
}

// 授權 HealthKit
// 授權 HealthKit
void RequestHealthKitAuthorization() {
    if (![HKHealthStore isHealthDataAvailable]) return;

    NSSet *readTypes = [NSSet setWithObjects:
        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
        nil];

    [GetHealthStore() requestAuthorizationToShareTypes:nil
                                               readTypes:readTypes
                                              completion:^(BOOL success, NSError *error) {
        if (!success || error) {
            NSLog(@"❌ HealthKit 授權失敗: %@", error.localizedDescription);
        } else {
            NSLog(@"✅ HealthKit 授權成功");
            // 👇 加這行，通知 Unity 授權成功
            UnitySendMessage("test", "OnHealthKitAuthorizationSuccess", "");
        }
    }];
}



// 取得本週步數
void GetThisWeekStepCount() {
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startOfWeek;
    [calendar rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&startOfWeek interval:NULL forDate:now];

    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startOfWeek endDate:now options:HKQueryOptionStrictStartDate];

    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepType
                                                      quantitySamplePredicate:predicate
                                                                       options:HKStatisticsOptionCumulativeSum
                                                             completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        if (error) {
            NSLog(@"❌ GetThisWeekStepCount 錯誤: %@", error.localizedDescription);
            return;
        }

        if (result.sumQuantity) {
            double steps = [result.sumQuantity doubleValueForUnit:[HKUnit countUnit]];
            NSString *stepsStr = [NSString stringWithFormat:@"%d", (int)steps];
            UnitySendMessage("test", "OnThisWeekStepCountReceived", [stepsStr UTF8String]);
        }
    }];

    [GetHealthStore() executeQuery:query];
}

// 取得今日步數
void GetTodayStepCount() {
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startOfDay = [calendar startOfDayForDate:now];

    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startOfDay endDate:now options:HKQueryOptionStrictStartDate];

    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepType
                                                      quantitySamplePredicate:predicate
                                                                       options:HKStatisticsOptionCumulativeSum
                                                             completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        if (error) {
            NSLog(@"❌ GetTodayStepCount 錯誤: %@", error.localizedDescription);
            return;
        }

        if (result.sumQuantity) {
            double steps = [result.sumQuantity doubleValueForUnit:[HKUnit countUnit]];
            NSString *stepsStr = [NSString stringWithFormat:@"%d", (int)steps];
            UnitySendMessage("test", "OnTodayStepCountReceived", [stepsStr UTF8String]);
        }
    }];

    [GetHealthStore() executeQuery:query];
}

// 取得昨日步數
void GetYesterdayStepCount() {
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];

    NSDate *startOfToday = [calendar startOfDayForDate:now];
    NSDate *startOfYesterday = [calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:startOfToday options:0];
    NSDate *endOfYesterday = [calendar dateByAddingUnit:NSCalendarUnitSecond value:-1 toDate:startOfToday options:0];

    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startOfYesterday endDate:endOfYesterday options:HKQueryOptionStrictStartDate];

    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepType
                                                      quantitySamplePredicate:predicate
                                                                       options:HKStatisticsOptionCumulativeSum
                                                             completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        if (error) {
            NSLog(@"❌ GetYesterdayStepCount 錯誤: %@", error.localizedDescription);
            return;
        }

        if (result.sumQuantity) {
            double steps = [result.sumQuantity doubleValueForUnit:[HKUnit countUnit]];
            NSString *stepsStr = [NSString stringWithFormat:@"%d", (int)steps];
            UnitySendMessage("test", "OnYesterdayStepCountReceived", [stepsStr UTF8String]);
        }
    }];

    [GetHealthStore() executeQuery:query];
}

// 取得上週步數
void GetLastWeekStepCount() {
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];

    NSDate *startOfThisWeek;
    [calendar rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&startOfThisWeek interval:NULL forDate:now];

    NSDate *startOfLastWeek = [calendar dateByAddingUnit:NSCalendarUnitWeekOfYear value:-1 toDate:startOfThisWeek options:0];
    NSDate *endOfLastWeek = [calendar dateByAddingUnit:NSCalendarUnitSecond value:-1 toDate:startOfThisWeek options:0];

    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startOfLastWeek endDate:endOfLastWeek options:HKQueryOptionStrictStartDate];

    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepType
                                                      quantitySamplePredicate:predicate
                                                                       options:HKStatisticsOptionCumulativeSum
                                                             completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        if (error) {
            NSLog(@"❌ GetLastWeekStepCount 錯誤: %@", error.localizedDescription);
            return;
        }

        if (result.sumQuantity) {
            double steps = [result.sumQuantity doubleValueForUnit:[HKUnit countUnit]];
            NSString *stepsStr = [NSString stringWithFormat:@"%d", (int)steps];
            UnitySendMessage("test", "OnLastWeekStepCountReceived", [stepsStr UTF8String]);
        }
    }];

    [GetHealthStore() executeQuery:query];
}

} // extern "C"
