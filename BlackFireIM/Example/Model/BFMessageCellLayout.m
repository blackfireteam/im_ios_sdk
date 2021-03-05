//
//  BFMessageCellLayout.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "BFMessageCellLayout.h"

@implementation BFMessageCellLayout

- (instancetype)init:(BOOL)isIncomming
{
    self = [super init];
    if (self) {
        self.avatarSize = CGSizeMake(40, 40);
        if (isIncomming) {
            self.avatarInsets = (UIEdgeInsets){
                .left = 8,
                .top = 3,
                .bottom = 1,
            };
            self.messageInsets = (UIEdgeInsets){
                .top = 3,
                .bottom = 1,
                .left = 8,
            };
        } else {
            self.avatarInsets = (UIEdgeInsets){
                .right = 8,
                .top = 3,
                .bottom = 1,
            };
            self.messageInsets = (UIEdgeInsets){
                .top = 3,
                .bottom = 1,
                .right = 8,
            };
        }
    }
    return self;
}

static BFMessageCellLayout *sIncommingMessageLayout;

+ (BFMessageCellLayout *)incommingMessageLayout
{
    if (!sIncommingMessageLayout) {
        sIncommingMessageLayout = [[BFMessageCellLayout alloc] init:YES];
    }
    return sIncommingMessageLayout;
}

static BFMessageCellLayout *sOutgoingMessageLayout;

+ (BFMessageCellLayout *)outgoingMessageLayout
{
    if (!sOutgoingMessageLayout) {
        sOutgoingMessageLayout = [[BFMessageCellLayout alloc] init:NO];
    }
    return sOutgoingMessageLayout;
}

#pragma Text CellLayout

static BFMessageCellLayout *sIncommingTextMessageLayout;

+ (BFMessageCellLayout *)incommingTextMessageLayout
{
    if (!sIncommingTextMessageLayout) {
        sIncommingTextMessageLayout = [[BFMessageCellLayout alloc] init:YES];
        sIncommingTextMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 14, .bottom = 16, .left = 16, .right = 16};
    }
    return sIncommingTextMessageLayout;
}

static BFMessageCellLayout *sOutgingTextMessageLayout;

+ (BFMessageCellLayout *)outgoingTextMessageLayout
{
    if (!sOutgingTextMessageLayout) {
        sOutgingTextMessageLayout = [[BFMessageCellLayout alloc] init:NO];
        sOutgingTextMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 14, .bottom = 16, .left = 16, .right = 16};
    }
    return sOutgingTextMessageLayout;
}


#pragma Voice CellLayout

static BFMessageCellLayout *sIncommingVoiceMessageLayout;

+ (BFMessageCellLayout *)incommingVoiceMessageLayout
{
    if (!sIncommingVoiceMessageLayout) {
        sIncommingVoiceMessageLayout = [[BFMessageCellLayout alloc] init:YES];
        sIncommingVoiceMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 14, .bottom = 20, .left = 19, .right = 22};
    }
    return sIncommingVoiceMessageLayout;
}

static BFMessageCellLayout *sOutgingVoiceMessageLayout;

+ (BFMessageCellLayout *)outgoingVoiceMessageLayout
{
    if (!sOutgingVoiceMessageLayout) {
        sOutgingVoiceMessageLayout = [[BFMessageCellLayout alloc] init:NO];
        sOutgingVoiceMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 14, .bottom = 20, .left = 22, .right = 20};
    }
    return sOutgingVoiceMessageLayout;
}

#pragma System CellLayout

static BFMessageCellLayout *sSystemMessageLayout;

+ (BFMessageCellLayout *)systemMessageLayout
{
    if (!sSystemMessageLayout) {
        sSystemMessageLayout = [[BFMessageCellLayout alloc] init:YES];
        sSystemMessageLayout.messageInsets = (UIEdgeInsets){.top = 5, .bottom = 5};
    }
    return sSystemMessageLayout;
}

@end
