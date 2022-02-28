//
//  MSCallModel.h
//  BlackFireIM
//
//  Created by benny wang on 2021/7/20.
//

#import <Foundation/Foundation.h>
#import <MSIMSDK/MSProfileInfo.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,CallType) {
    CallType_Unknown,        //未知类型
    CallType_Audio,          //语音邀请
    CallType_Video,          //视频邀请
};


@interface MSCallModel : NSObject

@property(nonatomic,assign) CallType calltype;        //call 类型
@property(nonatomic,copy) NSString *callid;           //call 唯一 ID
@property(nonatomic,strong) MSProfileInfo *hoster;    //邀请者

@end




NS_ASSUME_NONNULL_END
