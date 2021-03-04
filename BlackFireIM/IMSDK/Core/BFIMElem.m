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

@end

@implementation BFIMTextElem

- (NSDictionary *)contentDic
{
    return @{@"text": XMNoNilString(self.text)};
}

@end

@implementation BFIMImageElem

- (NSDictionary *)contentDic
{
    return @{@"url": XMNoNilString(self.url),@"width": @(self.width),@"height": @(self.height),@"path": XMNoNilString(self.path),@"size": @(self.size),@"uuid": XMNoNilString(self.uuid)};
}

@end

@implementation BFIMCustomElem

- (NSDictionary *)contentDic
{
    return @{};
}

@end
