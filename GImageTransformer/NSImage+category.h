//
//  NSImage+category.h
//  GImageTransformer
//
//  Created by GaoAng on 2017/3/4.
//  Copyright © 2017年 selfWork.cn. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (category)
+ (NSImage *)imageResize:(NSImage*)anImage newSize:(NSSize)newSize;
+ (NSImage*) resizeImage:(NSImage*)sourceImage size:(NSSize)size;

- (BOOL)saveImage:(NSImage*)image ToTarget:(NSString *)targePath;               //save path
- (BOOL)saveImage:(NSImage*)image ToTarget:(NSString *)targePath ToWidth:(NSInteger)width ToHight:(NSInteger)hight;//save path

@end
