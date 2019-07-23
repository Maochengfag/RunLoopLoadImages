//
//  UIImageView+AddPragram.m
//  RunLoopLoadImages
//
//  Created by Mac on 2019/7/2.
//  Copyright © 2019年 Mac. All rights reserved.
//Property 'downUrl' requires method 'downUrl' to be defined - use @dynamic or provide a method implementation in this category
//

#import "UIImageView+AddPragram.h"
#import <objc/runtime.h>

static const char *kDownUrlPropertyKey = "kDownUrlPropertyKey";

@implementation UIImageView (AddPragram)

- (void)setDownUrl:(NSString *)downUrl{
    objc_setAssociatedObject(self, kDownUrlPropertyKey, downUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)getDownUrl{
    return objc_getAssociatedObject(self, kDownUrlPropertyKey);
}

@end
