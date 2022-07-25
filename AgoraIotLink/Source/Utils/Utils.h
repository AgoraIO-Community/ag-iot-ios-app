//
//  MediaUtils.h
//  APIExample
//
//  Created by Arlin on 2022/4/12.
//  Copyright © 2022 Agora Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

+ (nullable UIImage *)i420ToImage:(nullable unsigned char *)srcY srcU:(nullable unsigned char *)srcU srcV:(nullable unsigned char *)srcV yStride:(int)yStride uStride:(int)uStride vStride:(int)vStride width:(int)width height:(int)height;

+ (UIImage *)convert:(CVPixelBufferRef)pixelBuffer;

+ (NSString*)dateTime;
@end

NS_ASSUME_NONNULL_END
