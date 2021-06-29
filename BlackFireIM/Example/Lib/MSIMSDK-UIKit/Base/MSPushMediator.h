//
//  MSPushMediator.h
//  BlackFireIM
//
//  Created by benny wang on 2021/6/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MSPushMediatorDelegate<NSObject>

/** 点击推送消息进入的app,可以做些跳转操作*/
- (void)didReceiveNotificationResponse:(NSDictionary *)userInfo;

@end
@interface MSPushMediator : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic,weak) id<MSPushMediatorDelegate> delegate;

@property(nonatomic,copy) NSString *device_token;

- (void)applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
