#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HDLoggerTableViewCell.h"
#import "HDWindowLogger.h"
#import "HDWindowLoggerItem.h"

FOUNDATION_EXPORT double HDWindowLoggerVersionNumber;
FOUNDATION_EXPORT const unsigned char HDWindowLoggerVersionString[];

