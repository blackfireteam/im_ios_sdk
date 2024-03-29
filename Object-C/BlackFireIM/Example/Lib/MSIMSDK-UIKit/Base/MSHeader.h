//
//  MSHeader.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#ifndef MSHeader_h
#define MSHeader_h

#import "UIColor+BFDarkMode.h"
#import "UIImage+BFDarkMode.h"
#import "UIButton+positon.h"
#import "UIImage+BFKit.h"
#import "UIView+Frame.h"
#import "NSString+Encry.h"
#import "NSBundle+BFKit.h"
#import "UIDevice+Ext.h"
#import "UIView+BFExtension.h"
#import "NSDate+MSKit.h"
#import "MSHelper.h"
#import "MSUploadManager.h"


#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define STRONG_SELF(strongSelf) if (!weakSelf) return; \
__strong typeof(weakSelf) strongSelf = weakSelf;

#define Screen_Width        [UIScreen mainScreen].bounds.size.width
#define Screen_Height       [UIScreen mainScreen].bounds.size.height
#define Is_Iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define Is_IPhoneX (Screen_Width >=375.0f && Screen_Height >=812.0f && Is_Iphone)

#define StatusBar_Height    (Is_IPhoneX ? (44.0):(20.0))
#define TabBar_Height       (Is_IPhoneX ? (49.0 + 34.0):(49.0))
#define NavBar_Height       (44)
#define SearchBar_Height    (55)
#define Bottom_SafeHeight   (Is_IPhoneX ? (34.0):(0))
#define RGBA(r, g, b, a)    [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]
#define RGB(r, g, b)    [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.f]


#define TUIKitFace(name) [[[NSBundle mainBundle] pathForResource:@"TUIKitFace" ofType:@"bundle"] stringByAppendingPathComponent:name]
#define TUIKitResource(name) [[[NSBundle mainBundle] pathForResource:@"TUIKitResource" ofType:@"bundle"] stringByAppendingPathComponent:name]

//cell
#define TMessageCell_Head_Width 45
#define TMessageCell_Head_Height 45
#define TMessageCell_Head_Size CGSizeMake(45, 45)
#define TMessageCell_Padding 8
#define TMessageCell_Margin 8
#define TMessageCell_Indicator_Size CGSizeMake(20, 20)

//text cell
#define TTextMessageCell_ReuseId @"TTextMessageCell"
#define TTextMessageCell_Height_Min (TMessageCell_Head_Size.height + 2 * TMessageCell_Padding)
#define TTextMessageCell_Text_PADDING (160)
#define TTextMessageCell_Text_Width_Max (Screen_Width - TTextMessageCell_Text_PADDING)
#define TTextMessageCell_Margin 12

//system cell
#define TSystemMessageCell_ReuseId @"TSystemMessageCell"
#define TSystemMessageCell_Text_Width_Max (Screen_Width * 0.5)
#define TSystemMessageCell_Margin 5

//joinGroup cell 继承自 system cell
#define TJoinGroupMessageCell_ReuseId @"TJoinGroupMessageCell"
#define TJoinGroupMessageCell_Text_Width_Max (Screen_Width * 0.5)
#define TJoinGroupMessageCell_Margin 5

//image cell
#define TImageMessageCell_ReuseId @"TImageMessageCell"
#define TImageMessageCell_Image_Width_Max (Screen_Width * 0.4)
#define TImageMessageCell_Image_Height_Max TImageMessageCell_Image_Width_Max
#define TImageMessageCell_Margin_2 8
#define TImageMessageCell_Margin_1 16
#define TImageMessageCell_Progress_Color  RGBA(0, 0, 0, 0.5)

//face cell
#define TFaceMessageCell_ReuseId @"TFaceMessageCell"
#define TFaceMessageCell_Image_Width_Max (Screen_Width * 0.25)
#define TFaceMessageCell_Image_Height_Max TFaceMessageCell_Image_Width_Max
#define TFaceMessageCell_Margin 16

//location cell
#define TLocationMessageCell_ReuseId @"TLocationMessageCell"
#define TLocationMessageCell_Width (Screen_Width * 0.65)
#define TLocationMessageCell_Height TLocationMessageCell_Width * 0.65

//file cell
#define TFileMessageCell_ReuseId @"TFileMessageCell"
#define TFileMessageCell_Container_Size CGSizeMake((Screen_Width * 0.5), (Screen_Width * 0.15))
#define TFileMessageCell_Margin 10
#define TFileMessageCell_Progress_Color  RGBA(0, 0, 0, 0.5)

//emotion cell
#define TEmotionMessageCell_ReuseId @"TEmotionMessageCell"
#define TEmotionMessageCell_Container_Size CGSizeMake(120, 120)

//video cell
#define TVideoMessageCell_ReuseId @"TVideoMessageCell"
#define TVideoMessageCell_Image_Width_Max (Screen_Width * 0.4)
#define TVideoMessageCell_Image_Height_Max TVideoMessageCell_Image_Width_Max
#define TVideoMessageCell_Margin_3 4
#define TVideoMessageCell_Margin_2 8
#define TVideoMessageCell_Margin_1 16
#define TVideoMessageCell_Play_Size CGSizeMake(35, 35)
#define TVideoMessageCell_Progress_Color  RGBA(0, 0, 0, 0.5)


//voice cell
#define TVoiceMessageCell_ReuseId @"TVoiceMessaageCell"
#define TVoiceMessageCell_Max_Duration 60.0
#define TVoiceMessageCell_Height TMessageCell_Head_Size.height
#define TVoiceMessageCell_Margin 12
#define TVoiceMessageCell_Back_Width_Max (Screen_Width * 0.4)
#define TVoiceMessageCell_Back_Width_Min 60
#define TVoiceMessageCell_Duration_Size CGSizeMake(33, 33)

//menu item cell
#define TMenuCell_ReuseId @"TMenuCell"
#define TMenuCell_Margin 6
#define TMenuCell_Line_ReuseId @"TMenuLineCell"
#define TMenuCell_Background_Color  RGBA(246, 246, 246, 1.0)
#define TMenuCell_Background_Color_Dark  RGBA(30, 30, 30, 1.0)
#define TMenuCell_Selected_Background_Color  RGBA(255, 255, 255, 1.0)
#define TMenuCell_Selected_Background_Color_Dark  RGBA(41, 41, 41, 1.0)

//group_live
#define TGroupLiveMessageCell_ReuseId @"TGroupLiveMessageCell"

#define TTextView_Height (49)
#define TTextView_Button_Size CGSizeMake(30, 30)
#define TTextView_Margin 6
#define TTextView_TextView_Height_Min (TTextView_Height - 2 * TTextView_Margin)
#define TTextView_TextView_Height_Max 80

#define TInput_Background_Color  RGBA(246, 246, 246, 1.0)
#define TInput_Background_Color_Dark  RGBA(30, 30, 30, 1.0)

#define TLine_Color RGBA(188, 188, 188, 0.6)
#define TLine_Color_Dark RGBA(35, 35, 35, 0.6)
#define TLine_Heigh 0.5

// page commom color
#define TPage_Color RGBA(222, 222, 222, 1.0)
#define TPage_Color_Dark RGBA(55, 55, 55, 1.0)
#define TPage_Current_Color RGBA(125, 125, 125, 1.0)
#define TPage_Current_Color_Dark RGBA(140, 140, 140, 1.0)

// title commom color
#define TText_Color [UIColor blackColor]
#define TText_Color_Dark RGB(217, 217, 217)
#define TText_OutMessage_Color_Dark RGB(0, 15, 0)

#define TController_Background_Color RGBA(247, 247, 247, 1.0)
#define TController_Background_Color_Dark RGBA(25, 25, 25, 1.0)

// bottom line
#define TCell_separatorColor RGBA(230, 230, 230, 1.0)
#define TCell_separatorColor_Dark RGBA(47, 47, 47, 1.0)
// cell commom color
#define TCell_Nomal [UIColor whiteColor]
#define TCell_Nomal_Dark RGB(35, 35, 35)
#define TCell_Touched RGB(219, 219, 219)
#define TCell_Touched_Dark RGB(47, 47, 47)
#define TCell_OnTop RGB(247, 247, 247)
#define TCell_OnTop_Dark RGB(47, 47, 47)

//record
#define Record_Background_Color RGBA(0, 0, 0, 0.6)
#define Record_Background_Size CGSizeMake(Screen_Width * 0.4, Screen_Width * 0.4)
#define Record_Title_Height 30
#define Record_Title_Background_Color RGBA(186, 60, 65, 1.0)
#define Record_Margin 8


//store
#define GaodeAPIKey @"be89a357dfc9e986f1ca53bbab8e4a16"
#define GaodeAPIWebKey @"d696e2e8fc6c1685be52faa64b66d318"
#define kChatRoomID 1641525634
#define kAppID @"100"
//com.blackfire.im.msim.normal1  bundle_id

//noral
//#define GaodeAPIKey @"28d8663963475a7eb9126c8ebb9c4bc9"
//#define GaodeAPIWebKey @"1db3c63e96dccbe7dd34b6b5150fae90"
//#define kChatRoomID 1646637677
//#define kAppID @"2"
//com.blackfire.im.msim.normal  bundle_id



#define kAppInviteCode @"MSIPO"

/** 自定义消息分类*/
typedef NS_ENUM(NSUInteger, MSIMCustomSubType) {
    
    MSIMCustomSubTypeLike = 1,              //like
    MSIMCustomSubTypeTexting = 100,         //正在输入
    MSIMCustomSubTypeVoiceCall = 200,       //语音聊天
    MSIMCustomSubTypeVideoCall = 300,       //视频聊天
};


#endif /* BFHeader_h */
