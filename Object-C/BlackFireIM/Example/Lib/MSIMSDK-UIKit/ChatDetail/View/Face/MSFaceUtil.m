//
//  MSFaceUtil.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/29.
//

#import "MSFaceUtil.h"
#import "MSFaceView.h"
#import "MSIMSDK-UIKit.h"

@implementation MSFaceUtil

+ (MSFaceUtil *)defaultConfig
{
    static dispatch_once_t onceToken;
    static MSFaceUtil *config;
    dispatch_once(&onceToken, ^{
        config = [[MSFaceUtil alloc] init];
    });
    return config;
}

- (NSMutableArray *)defaultFace
{
    if (!_defaultFace) {
        _defaultFace = [NSMutableArray array];
        //emoji group
        NSMutableArray *emojiFaces = [NSMutableArray array];
        NSArray *emojis = [NSArray arrayWithContentsOfFile:TUIKitFace(@"emoji/emoji.plist")];
        for (NSDictionary *dic in emojis) {
            BFFaceCellData *data = [[BFFaceCellData alloc] init];
            NSString *name = [dic objectForKey:@"face_name"];
            data.name = [NSString stringWithFormat:@"emoji/%@",name];
            [emojiFaces addObject:data];
        }
        if(emojiFaces.count != 0){
            BFFaceGroup *emojiGroup = [[BFFaceGroup alloc] init];
            emojiGroup.groupIndex = 0;
            emojiGroup.groupPath = TUIKitFace(@"emoji/");
            emojiGroup.faces = emojiFaces;
            emojiGroup.rowCount = 3;
            emojiGroup.itemCountPerRow = 9;
            emojiGroup.needBackDelete = YES;
            [_defaultFace addObject:emojiGroup];
        }
    }
    return _defaultFace;
}

@end
