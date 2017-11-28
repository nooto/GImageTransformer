//
//  NSImageProperyCellView.h
//  GImageTransformer
//
//  Created by GaoAng on 2017/3/6.
//  Copyright © 2017年 selfWork.cn. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImageProperyCellView : NSTableCellView
@property (nonatomic, strong) NSDictionary *mCurDict;
@property (nonatomic, assign) CGFloat  mCellHight;

@property (nonatomic, copy) void (^didSelectRmoveRow)(NSDictionary*dict);
@end
