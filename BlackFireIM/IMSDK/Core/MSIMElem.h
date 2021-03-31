//
//  MSIMElem.h
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import <UIKit/UIKit.h>
#import "MSIMConst.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSIMElem : NSObject<NSCopying>

/** 消息类型*/
@property(nonatomic,assign) BFIMMessageType type;

/** 消息发送方ID*/
@property(nonatomic,copy) NSString *fromUid;

/** 消息接收方ID*/
@property(nonatomic,copy) NSString *toUid;

/** 服务器返回的消息的自增id*/
@property(nonatomic,assign) NSInteger msg_id;

/** 当消息生成时就已经固定，全局唯一，会贯穿整个发送以及接收过程。*/
@property(nonatomic,assign) NSInteger msg_sign;

/** 消息状态*/
@property(nonatomic,assign) BFIMMessageStatus sendStatus;

/** 消息发送失败错误码*/
@property(nonatomic,assign) NSInteger code;

/** 消息发送失败描述*/
@property(nonatomic,copy) NSString *reason;

/** 消息已读状态*/
@property(nonatomic,assign) BFIMMessageReadStatus readStatus;

@property(nonatomic,assign,readonly) NSDictionary *contentDic;

/** 被撤回消息msg_id*/
@property(nonatomic,assign) NSInteger revoke_msg_id;

@property(nonatomic,assign) NSInteger block_id;

/** TRUE：表示是发送消息；FALSE：表示是接收消息*/
- (BOOL)isSelf;

- (NSString *)partner_id;

/** 在会话列表中显示的文字*/
@property(nonatomic,copy,readonly) NSString *displayStr;


@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      文本消息 Elem
//
/////////////////////////////////////////////////////////////////////////////////
@interface MSIMTextElem : MSIMElem

@property(nonatomic,copy) NSString *text;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      图片消息 Elem
//
/////////////////////////////////////////////////////////////////////////////////
@interface MSIMImageElem : MSIMElem

/** 图片 ID，内部标识，可用于外部缓存key*/
@property(nonatomic,copy) NSString *uuid;
/** 图片大小*/
@property(nonatomic,assign) NSInteger size;
/** 图片宽*/
@property(nonatomic,assign) NSInteger width;
/** 图片高*/
@property(nonatomic,assign) NSInteger height;
/** 下载URL*/
@property(nonatomic,copy) NSString *url;
/** 待发送的图片*/
@property(nonatomic,strong) UIImage *image;
/** 保存在沙盒中的相对地址*/
@property(nonatomic,copy) NSString *path;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      自定义消息 Elem
//
/////////////////////////////////////////////////////////////////////////////////
@interface MSIMCustomElem: MSIMElem

/** 自定义消息二进制数据*/
@property(nonatomic,strong) NSData *data;

@end

NS_ASSUME_NONNULL_END
