//
//  MSIMElem.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import "MSIMElem.h"
#import "MSIMTools.h"
#import "NSDictionary+Ext.h"

@implementation MSIMElem

- (BOOL)isSelf
{
    if ([self.fromUid isEqualToString:[MSIMTools sharedInstance].user_id]) {
        return YES;
    }
    return NO;
}

- (NSString *)partner_id
{
    return self.isSelf ? self.toUid : self.fromUid;
}

- (NSData *)extData
{
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    MSIMElem *elem = [[[self class] allocWithZone:zone]init];
    elem.type = self.type;
    elem.fromUid = self.fromUid;
    elem.toUid = self.toUid;
    elem.msg_id = self.msg_id;
    elem.msg_sign = self.msg_sign;
    elem.block_id = self.block_id;
    elem.revoke_msg_id = self.revoke_msg_id;
    elem.sendStatus = self.sendStatus;
    elem.readStatus = self.readStatus;
    elem.code = self.code;
    elem.reason = self.reason;
    return elem;
}

- (NSString *)displayStr
{
    if (self.type == BFIM_MSG_TYPE_REVOKE) {
        if (self.isSelf) {
            return @"您撤回了一条消息";
        }else {
            return @"对方撤回了一条消息";
        }
    }
    return @"不支持的消息类型，请升级SDK查看";
}

@end

@implementation MSIMTextElem

- (id)copyWithZone:(NSZone *)zone
{
    MSIMTextElem *elem = [[[self class] allocWithZone:zone]init];
    elem.text = self.text;
    return elem;
}

- (NSString *)displayStr
{
    if (self.text.length > 100) {
        return [self.text substringToIndex:100];
    }else {
        return self.text;
    }
}

- (NSData *)extData
{
    NSDictionary *dic = @{@"text": XMNoNilString(self.text)};
    return [dic el_convertData];
}

@end

@implementation MSIMImageElem

- (NSData *)extData
{
    NSDictionary *dic = @{@"url": XMNoNilString(self.url),@"width": @(self.width),@"height": @(self.height),@"path": XMNoNilString(self.path),@"size": @(self.size),@"uuid": XMNoNilString(self.uuid)};
    return [dic el_convertData];
}

- (id)copyWithZone:(NSZone *)zone
{
    MSIMImageElem *elem = [[[self class] allocWithZone:zone]init];
    elem.url = self.url;
    elem.image = self.image;
    elem.path = self.path;
    elem.width = self.width;
    elem.height = self.height;
    elem.size = self.size;
    elem.uuid = self.uuid;
    return elem;
}

- (NSString *)displayStr
{
    return @"[Image]";
}

@end

@implementation MSIMVoiceElem

- (NSData *)extData
{
    NSDictionary *dic = @{@"voiceUrl": XMNoNilString(self.url),@"voicePath": XMNoNilString(self.path),@"duration": @(self.duration),@"size":@(self.dataSize)};
    return [dic el_convertData];
}

- (id)copyWithZone:(NSZone *)zone
{
    MSIMVoiceElem *elem = [[[self class] allocWithZone:zone]init];
    elem.path = self.path;
    elem.url = self.url;
    elem.dataSize = self.dataSize;
    elem.duration = self.duration;
    return elem;
}

- (NSString *)displayStr
{
    return @"[Voice]";
}


@end

@implementation MSIMVideoElem

- (NSData *)extData
{
    NSDictionary *dic = @{@"videoUrl": XMNoNilString(self.videoUrl),@"width": @(self.width),@"height": @(self.height),@"videoPath": XMNoNilString(self.videoPath),@"duration": @(self.duration),@"coverPath":XMNoNilString(self.coverPath),@"coverUrl":XMNoNilString(self.coverUrl),@"uuid": XMNoNilString(self.uuid)};
    return [dic el_convertData];
}

- (id)copyWithZone:(NSZone *)zone
{
    MSIMVideoElem *elem = [[[self class] allocWithZone:zone]init];
    elem.videoUrl = self.videoUrl;
    elem.videoPath = self.videoPath;
    elem.coverUrl = self.coverUrl;
    elem.coverPath = self.coverPath;
    elem.width = self.width;
    elem.height = self.height;
    elem.duration = self.duration;
    elem.uuid = self.uuid;
    return elem;
}

- (NSString *)displayStr
{
    return @"[Video]";
}


@end

@implementation MSIMCustomElem

- (id)copyWithZone:(NSZone *)zone
{
    MSIMCustomElem *elem = [[[self class] allocWithZone:zone]init];
    elem.jsonStr = self.jsonStr;
    return elem;
}

- (NSData *)extData
{
    return  [self.jsonStr dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)displayStr
{
    return @"[like]";
}

@end
