//
//  NSString+Extension.m
//  IotLinkDemo
//
//  Created by admin on 2022/12/14.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

//获取字符串字节数，每个汉字两个字节
- (NSInteger)getToInt

{

    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);

    NSData* da = [self dataUsingEncoding:enc];
    return [da length];

}

@end
