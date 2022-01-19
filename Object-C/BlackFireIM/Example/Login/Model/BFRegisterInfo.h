//
//  BFRegisterInfo.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFRegisterInfo : NSObject

@property(nonatomic,copy) NSString *userToken;

@property(nonatomic,copy) NSString *imUrl;

// 0 male 1 female
@property(nonatomic,assign) NSInteger gender;

@property(nonatomic,copy) NSString *phone;

@property(nonatomic,copy) NSString *nickName;

@property(nonatomic,copy) NSString *department;

@property(nonatomic,copy) NSString *workPlace;

@property(nonatomic,copy) NSString *inviteCode;

@property(nonatomic,strong) UIImage *avatarImage;

@property(nonatomic,copy) NSString *avatarUrl;

@property(nonatomic,copy) NSString *picUrl;

@property(nonatomic,assign) BOOL gold;

@property(nonatomic,assign) BOOL verified;

@end

NS_ASSUME_NONNULL_END
