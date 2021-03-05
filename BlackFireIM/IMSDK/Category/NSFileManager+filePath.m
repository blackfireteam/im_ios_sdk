//
//  NSFileManager+filePath.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//

#import "NSFileManager+filePath.h"
#import "BFIMTools.h"

@implementation NSFileManager (filePath)


+ (NSString *)pathDBMessage
{
    NSString *path = [NSString stringWithFormat:@"%@/User/%@/Chat/DB/", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject,[BFIMTools sharedInstance].user_id];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return [path stringByAppendingString:@"message.sqlite3"];
}


@end
