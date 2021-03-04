//
//  BFIMElem.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import "BFIMElem.h"
#import "BFIMTools.h"

@implementation BFIMElem

- (BOOL)isSelf
{
    return self.fromUid == [BFIMTools sharedInstance].user_id;
}

- (NSDictionary *)contentDic
{
    return @{};
}

- (id)copyWithZone:(NSZone *)zone
{
    BFIMElem *elem = [[[self class] allocWithZone:zone]init];
    elem.type = self.type;
    elem.fromUid = self.fromUid;
    elem.toUid = self.toUid;
    elem.msg_id = self.msg_id;
    elem.msg_sign = self.msg_sign;
    elem.sendStatus = self.sendStatus;
    elem.readStatus = self.readStatus;
    return elem;
}

@end

@implementation BFIMTextElem

- (NSDictionary *)contentDic
{
    return @{@"text": XMNoNilString(self.text)};
}

- (id)copyWithZone:(NSZone *)zone
{
    BFIMTextElem *elem = [[[self class] allocWithZone:zone]init];
    elem.text = self.text;
    return elem;
}

@end

@implementation BFIMImageElem

- (NSDictionary *)contentDic
{
    return @{@"url": XMNoNilString(self.url),@"width": @(self.width),@"height": @(self.height),@"path": XMNoNilString(self.path),@"size": @(self.size),@"uuid": XMNoNilString(self.uuid)};
}

- (id)copyWithZone:(NSZone *)zone
{
    BFIMImageElem *elem = [[[self class] allocWithZone:zone]init];
    elem.url = self.url;
    elem.path = self.path;
    elem.width = self.width;
    elem.height = self.height;
    elem.size = self.size;
    elem.uuid = self.uuid;
    return elem;
}

@end

@implementation BFIMCustomElem

- (NSDictionary *)contentDic
{
    return @{};
}

- (id)copyWithZone:(NSZone *)zone
{
    BFIMCustomElem *elem = [[[self class] allocWithZone:zone]init];
    elem.data = self.data;
    return elem;
}

@end
