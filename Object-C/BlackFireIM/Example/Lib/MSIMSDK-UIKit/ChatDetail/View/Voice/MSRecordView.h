//
//  MSRecordView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  录音状态枚举
 */
typedef NS_ENUM(NSUInteger, RecordStatus) {
    Record_Status_TooShort, //录音时长过短。
    Record_Status_TooLong, //录音时长超过时间限制。
    Record_Status_Recording, //正在录音。
    Record_Status_Cancel, //录音被取消。
};

@interface MSRecordView : UIView

@property (nonatomic, strong) UIImageView *recordImage;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UIView *background;

- (void)setPower:(NSInteger)power;

- (void)setStatus:(RecordStatus)status;

@end

NS_ASSUME_NONNULL_END
