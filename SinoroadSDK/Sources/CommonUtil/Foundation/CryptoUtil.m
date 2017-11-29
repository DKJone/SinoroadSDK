//
//  CryptoUtil.m
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

#import "CryptoUtil.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation CryptoUtil

+ (nonnull NSString *)md5:(nonnull NSString *) content {
    
    const char* input = [content UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;

}

@end
