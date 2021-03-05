//
//  BFIMElem.h
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import <Foundation/Foundation.h>
#import "BFIMConst.h"


NS_ASSUME_NONNULL_BEGIN

@interface BFIMElem : NSObject<NSCopying>

/** 消息类型*/
@property(nonatomic,assign) BFIMMessageType type;

/** 消息发送方ID*/
@property(nonatomic,copy) NSString *fromUid;

/** 消息接收方ID*/
@property(nonatomic,copy) NSString *toUid;

/** 服务器返回的消息的唯一标识ID，消息未发送时没有值*/
@property(nonatomic,assign) NSInteger msg_id;

/** 当消息生成时就已经固定，全局唯一，会贯穿整个发送以及接收过程。*/
@property(nonatomic,assign) NSInteger msg_sign;

/** 消息状态*/
@property(nonatomic,assign) BFIMMessageStatus sendStatus;

/** 消息已读状态*/
@property(nonatomic,assign) BFIMMessageReadStatus readStatus;

@property(nonatomic,assign,readonly) NSDictionary *contentDic;

/** TRUE：表示是发送消息；FALSE：表示是接收消息*/
- (BOOL)isSelf;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      文本消息 Elem
//
/////////////////////////////////////////////////////////////////////////////////
@interface BFIMTextElem : BFIMElem

@property(nonatomic,copy) NSString *text;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      图片消息 Elem
//
/////////////////////////////////////////////////////////////////////////////////
@interface BFIMImageElem : BFIMElem

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
/** 待发送的图片本地路径*/
@property(nonatomic,copy) NSString *path;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      自定义消息 Elem
//
/////////////////////////////////////////////////////////////////////////////////
@interface BFIMCustomElem: BFIMElem

/** 自定义消息二进制数据*/
@property(nonatomic,strong) NSData *data;

@end

NS_ASSUME_NONNULL_END
