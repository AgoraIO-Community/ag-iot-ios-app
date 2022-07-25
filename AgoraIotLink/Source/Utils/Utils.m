//
//  MediaUtils.m
//  APIExample
//
//  Created by Arlin on 2022/4/12.
//  Copyright © 2022 Agora Corp. All rights reserved.
//

#import "Utils.h"
#import <CoreImage/CoreImage.h>

@implementation Utils
//
//+ (UIImage *)i420ToImage:(unsigned char *)srcY srcU:(unsigned char *)srcU srcV:(unsigned char *)srcV yStride:(int)yStride uStride:(int)uStride vStride:(int)vStride width:(int)width height:(int)height  {
//    int size = width * height * 3 / 2;
//    int yLength = width * height;
//    int uLength = yLength / 4;
//
//    unsigned char *buf = (unsigned char *)malloc(size);
//    memcpy(buf, srcY, yLength);
//    memcpy(buf + yLength, srcU, uLength);
//    memcpy(buf + yLength + uLength, srcV, uLength);
//
//    unsigned char * NV12buf = (unsigned char *)malloc(size);
//    [self yuv420p_to_nv12:buf nv12:NV12buf width:width height:height];
//
//    int w = width;
//    int h = height;
//    NSDictionary *pixelAttributes = @{(NSString*)kCVPixelBufferIOSurfacePropertiesKey:@{}};
//    CVPixelBufferRef pixelBuffer = NULL;
//    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
//                                          w,
//                                          h,
//                                          kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
//                                          (__bridge CFDictionaryRef)(pixelAttributes),
//                                          &pixelBuffer);
//    if (result != kCVReturnSuccess) {
//        NSLog(@"Error Unable to create cvpixelbuffer %d", result);
//        return  nil;
//    }
//
//    CVPixelBufferLockBaseAddress(pixelBuffer,0);
//    void *yDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
//
//    // Here y_ch0 is Y-Plane of YUV(NV12) data.
//    unsigned char *y_ch0 = NV12buf;
//    unsigned char *y_ch1 = NV12buf + w * h;
//    memcpy(yDestPlane, y_ch0, w * h);
//    void *uvDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
//
//    // Here y_ch1 is UV-Plane of YUV(NV12) data.
//    memcpy(uvDestPlane, y_ch1, w * h * 0.5);
//    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
//
//    // CIImage Conversion
//    size_t pixelWidth = CVPixelBufferGetWidth(pixelBuffer);
//    size_t pixelHeight = CVPixelBufferGetHeight(pixelBuffer);
//    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
//
//    CIImage *coreImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
//    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
//    CGImageRef videoImage = [temporaryContext createCGImage:coreImage
//                                                   fromRect:CGRectMake(0, 0, pixelWidth,pixelHeight)];
//
//    UIImage *finalImage = [[UIImage alloc] initWithCGImage:videoImage
//                                                     scale:1.0
//                                               orientation:UIImageOrientationUp];
//    CVPixelBufferRelease(pixelBuffer);
//    CGImageRelease(videoImage);
//    return finalImage;
//}


+ (UIImage *)i420ToImage:(unsigned char *)srcY srcU:(unsigned char *)srcU srcV:(unsigned char *)srcV yStride:(int)yStride uStride:(int)uStride vStride:(int)vStride width:(int)width height:(int)height {
    NSDictionary *pixelAttributes = @{(NSString *)kCVPixelBufferIOSurfacePropertiesKey:@{}};
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                          width,
                                          height,
                                          kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,   //  NV12
                                          (__bridge CFDictionaryRef)(pixelAttributes),
                                          &pixelBuffer);
    if (result != kCVReturnSuccess) {
        NSLog(@"Unable to create cvpixelbuffer %d", result);
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    unsigned char *yDestPlane = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    size_t bytesPerRowChrominance = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    long chrominanceWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    long chrominanceHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    
    int start = 0;
    for (int i = 0;i < height; i ++) {
        int k = start;
        for (int j = 0; j < width; j ++) {
            yDestPlane[k++] = srcY[j + i * yStride];
        }
        start += bytesPerRowChrominance;
    }
    unsigned char *uvDestPlane = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    bytesPerRowChrominance = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
    chrominanceWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
    chrominanceHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    //memset(uvDestPlane, 0x80, chrominanceHeight * bytesPerRowChrominance);
    
    start = 0;
    for (int i = 0; i < height / 2; i ++) {
        int k = start;
        for (int j = 0; j < width / 2; j ++) {
            uvDestPlane[k++] = srcU[j + i * uStride];
            uvDestPlane[k++] = srcV[j + i * vStride];
        }
        start += bytesPerRowChrominance;
    }

    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

    CIImage *coreImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *MytemporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef MyvideoImage = [MytemporaryContext createCGImage:coreImage
                                                       fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];

    UIImage *Mynnnimage = [[UIImage alloc] initWithCGImage:MyvideoImage
                                                     scale:1.0
                                               orientation:UIImageOrientationUp];
    CVPixelBufferRelease(pixelBuffer);
    CGImageRelease(MyvideoImage);

    return Mynnnimage;
}

+ (void)yuv420p_to_nv12:(unsigned char*)yuv420p nv12:(unsigned char*)nv12 width:(int)width height:(int)height {
    int i, j;
    int y_size = width * height;
    
    unsigned char* y = yuv420p;
    unsigned char* u = yuv420p + y_size;
    unsigned char* v = yuv420p + y_size * 5 / 4;
    
    unsigned char* y_tmp = nv12;
    unsigned char* uv_tmp = nv12 + y_size;
    
    memcpy(y_tmp, y, y_size);
    
    for (j = 0, i = 0; j < y_size * 0.5; j += 2, i++) {
        uv_tmp[j] = u[i];
        uv_tmp[j+1] = v[i];
    }
}

+ (UIImage *)convert:(CVPixelBufferRef)pixelBuffer {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];

    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
        createCGImage:ciImage
             fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];

    UIImage *uiImage = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);

    return uiImage;
}

+ (NSString*)dateTime{
    return @__DATE__" "__TIME__;
}

@end
