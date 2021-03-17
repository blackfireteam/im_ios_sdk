//
//  MSIMElem.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import "MSIMElem.h"
#import "MSIMTools.h"

@implementation MSIMElem

- (BOOL)isSelf
{
    return self.fromUid == [MSIMTools sharedInstance].user_id;
}

- (NSString *)partner_id
{
    return self.isSelf ? self.toUid : self.fromUid;
}

- (NSDictionary *)contentDic
{
    return @{};
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
    elem.sendStatus = self.sendStatus;
    elem.readStatus = self.readStatus;
    return elem;
}

@end

@implementation MSIMTextElem

- (NSDictionary *)contentDic
{
    return @{@"text": XMNoNilString(self.text)};
}

- (id)copyWithZone:(NSZone *)zone
{
    MSIMTextElem *elem = [[[self class] allocWithZone:zone]init];
    elem.text = self.text;
    return elem;
}

@end

@implementation MSIMImageElem

- (NSDictionary *)contentDic
{
    return @{@"url": XMNoNilString(self.url),@"width": @(self.width),@"height": @(self.height),@"path": XMNoNilString(self.path),@"size": @(self.size),@"uuid": XMNoNilString(self.uuid)};
}

- (id)copyWithZone:(NSZone *)zone
{
    MSIMImageElem *elem = [[[self class] allocWithZone:zone]init];
    elem.url = self.url;
    elem.path = self.path;
    elem.width = self.width;
    elem.height = self.height;
    elem.size = self.size;
    elem.uuid = self.uuid;
    return elem;
}

@end

@implementation MSIMCustomElem

- (NSDictionary *)contentDic
{
    return @{};
}

- (id)copyWithZone:(NSZone *)zone
{
    MSIMCustomElem *elem = [[[self class] allocWithZone:zone]init];
    elem.data = self.data;
    return elem;
}

@end
