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

+ (MSFaceUtil *)config
{
    static dispatch_once_t onceToken;
    static MSFaceUtil *config;
    dispatch_once(&onceToken, ^{
        config = [[MSFaceUtil alloc] init];
    });
    return config;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self defaultFace];
    }
    return self;
}

- (nullable MSFaceGroup *)defaultEmojiGroup
{
    NSMutableArray *emojiFaces = [NSMutableArray array];
    NSArray *emojis = [NSArray arrayWithContentsOfFile:TUIKitFace(@"emoji/emoji.plist")];
    for (NSDictionary *dic in emojis) {
        BFFaceCellData *data = [[BFFaceCellData alloc] init];
        data.e_id = [dic objectForKey:@"face_id"];
        data.name = [dic objectForKey:@"face_name"];
        data.facePath = [TUIKitFace(@"emoji/") stringByAppendingPathComponent:data.name];
        [emojiFaces addObject:data];
    }
    if(emojiFaces.count != 0){
        MSFaceGroup *emojiGroup = [[MSFaceGroup alloc] init];
        emojiGroup.groupIndex = 0;
        emojiGroup.groupPath = TUIKitFace(@"emoji/");
        emojiGroup.faces = emojiFaces;
        emojiGroup.rowCount = 3;
        emojiGroup.itemCountPerRow = 9;
        emojiGroup.needBackDelete = YES;
        emojiGroup.needSendBtn = YES;
        emojiGroup.menuNormalPath = TUIKitFace(@"emoji/emoj_normal");
        emojiGroup.menuSelectPath = TUIKitFace(@"emoji/emoj_pressed");
        return emojiGroup;
    }
    return nil;
}

- (void)defaultFace
{
    NSMutableArray *faceGroup = [NSMutableArray array];
    [faceGroup addObject:[self defaultEmojiGroup]];
    
    NSMutableArray *emotionFaces = [NSMutableArray array];
    NSArray *emotions = [NSArray arrayWithContentsOfFile:TUIKitFace(@"emotion/emotion.plist")];
    for (NSDictionary *dic in emotions) {
        BFFaceCellData *data = [[BFFaceCellData alloc] init];
        data.e_id = [dic objectForKey:@"id"];
        data.name = [dic objectForKey:@"image"];
        data.facePath = [TUIKitFace(@"emotion/") stringByAppendingPathComponent:data.name];
        [emotionFaces addObject:data];
    }
    if (emotionFaces.count != 0) {
        MSFaceGroup *emotionGroup = [[MSFaceGroup alloc] init];
        emotionGroup.groupIndex = 1;
        emotionGroup.groupPath = TUIKitFace(@"emotion/");
        emotionGroup.faces = emotionFaces;
        emotionGroup.rowCount = 2;
        emotionGroup.itemCountPerRow = 5;
        emotionGroup.needBackDelete = NO;
        emotionGroup.needSendBtn = NO;
        emotionGroup.menuNormalPath = TUIKitFace(@"emotion/emotion_normal");
        emotionGroup.menuSelectPath = TUIKitFace(@"emotion/emotion_pressed");
        [faceGroup addObject:emotionGroup];
    }
    _faceGroups = faceGroup;
}

@end
