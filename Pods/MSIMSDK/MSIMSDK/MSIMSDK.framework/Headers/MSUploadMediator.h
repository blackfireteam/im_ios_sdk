//
//  MSUploadMediator.h
//  BlackFireIM
//
//  Created by benny wang on 2021/5/15.
//

#import <UIKit/UIKit.h>
#import <MSIMSDK/MSIMConst.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^normalSucc)(NSString *url);
typedef void(^normalProgress)(CGFloat progress);
typedef void(^normalFail)(NSInteger code, NSString *desc);

@protocol MSUploadMediator <NSObject>

@optional

- (void)ms_uploadWithObject:(id)object
                   fileType:(MSIMMessageType)type
                   progress:(normalProgress)progress
                       succ:(normalSucc)succ
                       fail:(normalFail)fail;



- (void)ms_downloadFromUrl:(NSString *)url
                toSavePath:(NSString *)savePath
                  progress:(normalProgress)progress
                      succ:(normalSucc)succ
                      fail:(normalFail)fail;

@end

NS_ASSUME_NONNULL_END
