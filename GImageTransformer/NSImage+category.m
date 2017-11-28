//
//  NSImage+category.m
//  GImageTransformer
//
//  Created by GaoAng on 2017/3/4.
//  Copyright © 2017年 selfWork.cn. All rights reserved.
//

#import "NSImage+category.h"
#define MAX_PIXEL_SIZE   600*800
#define PIC_WIDTH  800
#define PIC_HEIGHT 600

@implementation NSImage (category)

    //缩放到目的大小，太小了不缩放添加背景
+ (NSImage *)createScalesImage:(NSImage *)sourceImage
                      newWidth:(NSInteger)bgWidth
                      newHeight:(NSInteger)bgHeight
                      flipFlag:(BOOL)bFlip
               amountReflected:(float)fraction
{
        //source picture size
    NSSize srcSize = [sourceImage size];

    unsigned int uiWidth= srcSize.width;
    unsigned int uiHeight= srcSize.height;

        //target bg picture size
//    unsigned int bgWidth = PIC_WIDTH;
//    unsigned int bgHeight = PIC_HEIGHT;
    NSSize tarSize =NSMakeSize(bgWidth, bgHeight);

    if(uiWidth>=bgWidth && uiHeight >= bgHeight)
    {
        [sourceImage setSize:tarSize];
        return sourceImage;
    }

    if(uiWidth>bgWidth && uiHeight < bgHeight)
    {
        [sourceImage setSize:tarSize];

            //target bg picture
        NSImage *targetImage = [[NSImage alloc] initWithSize:tarSize];
        [targetImage lockFocus];
            //fill target bg picture,using white color
        [[NSColor whiteColor] set];
        NSRectFill(NSMakeRect(0,0, bgWidth, bgHeight*fraction));

            //draw
        [sourceImage drawAtPoint:NSMakePoint(0,(bgHeight - uiHeight)*0.5) fromRect:NSZeroRect operation:NSCompositingOperationSourceIn fraction:1.0];
        [targetImage unlockFocus];
        return targetImage;
    }

    if(uiWidth<bgWidth && uiHeight >bgHeight)
    {
        [sourceImage setSize:tarSize];

            //target bg picture
        NSImage *targetImage = [[NSImage alloc] initWithSize:tarSize];
        [targetImage lockFocus];
            //fill target bg picture,using white color
        [[NSColor whiteColor] set];
        NSRectFill(NSMakeRect(0, 0, bgWidth, bgWidth*fraction));

            //draw
        [sourceImage drawAtPoint:NSMakePoint((bgWidth- uiWidth)*0.5, 0) fromRect:NSZeroRect operation:NSCompositingOperationSourceIn fraction:1.0];
        [targetImage unlockFocus];
        return targetImage;
    }
    else
            //(uiWidth<bgWidth && uiHeight < bgHeight)
    {
            //[sourceImage setSize:tarSize];
            //target bg picture
        NSImage *targetImage = [[NSImage alloc] initWithSize:tarSize];
        [targetImage lockFocus];
            //fill target bg picture,using white color
        [[NSColor whiteColor] set];
        NSRectFill(NSMakeRect(0, 0, bgWidth, bgWidth*fraction));

            //draw
        [sourceImage drawAtPoint:NSMakePoint((bgWidth - uiWidth)*0.5, (bgHeight - uiHeight)*0.5) fromRect:NSZeroRect operation:NSCompositingOperationSourceIn fraction:1.0];
        [targetImage unlockFocus];
        return targetImage;
    }
}



    //按照图片的中心旋转90.180.270,360度
+ (NSImage *) rotateImage:(NSImage*)sourceImage byDegrees:(float)deg
{
    NSSize srcsize= [sourceImage size];
    float srcw = srcsize.width;
    float srch= srcsize.height;
    float newdeg = 0;
        //旋转弧度
        //double ratain = ((deg/180) * PI);
    NSRect r1 = NSZeroRect;
    if(0< deg && deg <=90)
    {
        r1 = NSMakeRect(0.5*(srcw -srch), 0.5*(srch-srcw), srch, srcw);
        newdeg = 90.0;
    }
    if(90< deg && deg <=180)
    {
        r1 = NSMakeRect(0, 0, srcw, srch);
        newdeg = 180.0;
    }
    if(180< deg && deg <=270)
    {
        r1 = NSMakeRect(0.5*(srcw -srch), 0.5*(srch-srcw), srch, srcw);
        newdeg = 270.0;
    }
    if(270< deg && deg <=360)
    {
        r1 = NSMakeRect(0, 0, srch, srcw);
        newdeg = 360;
    }

        //draw new image
    NSImage *rotated = [[NSImage alloc] initWithSize:[sourceImage size]];
    [rotated lockFocus];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:(0.5*srcw) yBy: (0.5*srch)];  //按中心图片旋转
    [transform rotateByDegrees:newdeg];                   //旋转度数，rotateByRadians：使用弧度
    [transform translateXBy:(-0.5*srcw) yBy: (-0.5*srch)];
    [transform concat];
//    [[sourceImage bestRepresentationForDevice: nil] drawInRect: r1];//矩形内画图

    [[sourceImage bestRepresentationForRect:r1 context:nil hints:nil] drawInRect:r1];


        //[sourceImage drawInRect:r1 fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
        //[sourceImage drawAtPoint:arge/*NSZeroPoint*/ fromRect:NSMakeRect(arge.x, arge.y,ww ,wh)/*NSZeroRect*/ operation:NSCompositeCopy fraction:1.0];
    [rotated unlockFocus];

    return rotated;
    
}

+ (NSImage*) resizeImage:(NSImage*)sourceImage size:(NSSize)size{

    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
    NSImage*  targetImage = [[NSImage alloc] initWithSize:size];

    NSSize sourceSize = [sourceImage size];

    float ratioH = sourceSize.height/ size.height;
    float ratioW = sourceSize.width / size.width;

    NSRect cropRect = NSZeroRect;

    if (ratioH >= ratioW) {
        cropRect.size.width = floor (sourceSize.width / ratioH);
        cropRect.size.height = size.height;
    } else {
        cropRect.size.width = size.width;
        cropRect.size.height = floor(sourceSize.height / ratioW);
    }

    cropRect.origin.x = floor( (targetFrame.size.width - cropRect.size.width)/2 );
    cropRect.origin.y = floor( (targetFrame.size.height - cropRect.size.height)/2 );

    [targetImage lockFocus];

    [sourceImage drawInRect:cropRect
                   fromRect:CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height)       //portion of source image to draw
                  operation:NSCompositingOperationCopy  //compositing operation
                   fraction:1.0              //alpha (transparency) value
             respectFlipped:YES              //coordinate system
                      hints:@{NSImageHintInterpolation: [NSNumber numberWithInt:NSImageInterpolationHigh]}];


    [targetImage unlockFocus];

    return targetImage;
}

+ (NSImage *)imageResize:(NSImage*)anImage newSize:(NSSize)newSize {

    NSImage *sourceImage = anImage;
//    [sourceImage setScalesWhenResized:YES];
        // Report an error if the source isn't a valid image
    if (![sourceImage isValid]){
        NSLog(@"Invalid Image");
    } else {
        NSImage *smallImage = [[NSImage alloc] initWithSize: newSize];
        [smallImage lockFocus];
        [sourceImage setSize: newSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, newSize.width, newSize.height) operation:NSCompositingOperationCopy fraction:1.0];
        [smallImage unlockFocus];
        return smallImage;
    }
    return nil;
}

- (BOOL)saveImage:(NSImage*)image ToTarget:(NSString *)targePath
{
//    [image lockFocus];
//    //先设置 下面一个实例
//    NSBitmapImageRep *bits = [[NSBitmapImageRep alloc]initWithFocusedViewRect:NSMakeRect(0, 0, 138, 32)];        //138.32为图片的长和宽
//    [image unlockFocus];
//    //再设置后面要用到得 props属性
//    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:0] forKey:NSImageCompressionFactor];
//
//    //之后 转化为NSData 以便存到文件中
//    NSData *imageData = [bits representationUsingType:NSPNGFileType properties:imageProps];
//    //设定好文件路径后进行存储就ok了
//    BOOL y = [imageData writeToFile:[[NSString stringWithString:@"~/Documents/test.png"] stringByExpandingTildeInPath]atomically:YES];    //保存的文件路径一定要是绝对路径，相对路径不行
//    NSLog(@"Save Image: %d", y);
    
    [image lockFocus];
    //先设置 下面一个实例
    NSBitmapImageRep *bits = [[NSBitmapImageRep alloc]initWithFocusedViewRect:NSMakeRect(0, 0, image.size.width, image.size.height)];
    [bits setAlpha:NO];
    [image unlockFocus];
    
    //再设置后面要用到得 props属性
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    
    //之后 转化为NSData 以便存到文件中
    NSData *imageData = [bits representationUsingType:NSJPEGFileType properties:imageProps];
    
    //设定好文件路径后进行存储就ok了
    BOOL y = [imageData writeToFile:targePath atomically:YES];    //保存的文件路径一定要是绝对路径，相对路径不行
    NSLog(@"Save Image: %d", y);
    return y;
}

- (BOOL)saveImage:(NSImage*)image                      //source image
         ToTarget:(NSString *) targePath

          ToWidth:(NSInteger)width ToHight:(NSInteger)hight{
    //save image to file
//- (BOOL)saveImage:(NSImage*)image                      //source image
//         ToTarget:(NSString *) targePath               //save path
//{
//    NSData *tempdata;
//    NSBitmapImageRep *srcImageRep;
//    BOOL reflag = NO;
//    [image lockFocus];
//
//    srcImageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
//    tempdata = [srcImageRep representationUsingType:NSBitmapImageFileTypePNG properties:@{NSImageCompressionFactor:@(1)}];
//    reflag = [tempdata writeToFile:targePath atomically:YES];
//    [image unlockFocus];
//    return reflag;
    
    [image lockFocus];
    //先设置 下面一个实例
    NSBitmapImageRep *bits = [[NSBitmapImageRep alloc]initWithFocusedViewRect:NSMakeRect(0, 0, width, hight)];        //138.32为图片的长和宽
    [image unlockFocus];
    //再设置后面要用到得 props属性
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:0] forKey:NSImageCompressionFactor];
    
    //之后 转化为NSData 以便存到文件中
    NSData *imageData = [bits representationUsingType:NSPNGFileType properties:imageProps];
    //设定好文件路径后进行存储就ok了
    BOOL y = [imageData writeToFile:targePath atomically:YES];    //保存的文件路径一定要是绝对路径，相对路径不行
    NSLog(@"Save Image: %d", y);
    return y;
}



@end
