//
//  NSDate+MSKit.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "NSDate+MSKit.h"
#import "NSBundle+BFKit.h"

@implementation NSDate (MSKit)

- (NSString *)ms_messageString
{
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:self];
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc ] init ];
    BOOL isYesterday = NO;
    if (nowCmps.year != myCmps.year) {
        dateFmt.dateFormat = @"yyyy/MM/dd HH:mm";
    }else{
        if (nowCmps.day==myCmps.day) {
            dateFmt.dateFormat = @"HH:mm";
        } else if((nowCmps.day-myCmps.day)==1) {
            isYesterday = YES;
            dateFmt.AMSymbol = TUILocalizableString(am); //@"上午";
            dateFmt.PMSymbol = TUILocalizableString(pm); //@"下午";
            dateFmt.dateFormat = TUILocalizableString(YesterdayDateFormat);
        } else {
            if ((nowCmps.day-myCmps.day) <=7) {
                dateFmt.dateFormat = @"EEEE HH:mm";
            }else {
                dateFmt.dateFormat = @"yyyy/MM/dd HH:mm";
            }
        }
    }
    NSString *str = [dateFmt stringFromDate:self];
    if (isYesterday) {
        str = [NSString stringWithFormat:@"%@ %@", TUILocalizableString(Yesterday), str];
    }
    return str;
}

@end
