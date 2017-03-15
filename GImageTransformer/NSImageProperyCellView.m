//
//  NSImageProperyCellView.m
//  GImageTransformer
//
//  Created by GaoAng on 2017/3/6.
//  Copyright © 2017年 selfWork.cn. All rights reserved.
//
#define KWIDTH  @"width"
#define KHIGHT  @"hight"
#define KNAME   @"name"

#import "NSImageProperyCellView.h"
@interface NSImageProperyCellView ()
@property (nonatomic, weak) IBOutlet  NSTextField *mWidthText;
@property (nonatomic, weak) IBOutlet  NSTextField *mWidth;
@property (nonatomic, weak) IBOutlet  NSTextField *mHidthText;
@property (nonatomic, weak) IBOutlet  NSTextField *mHidth;
@end

@implementation NSImageProperyCellView

-(void)awakeFromNib{
    [super awakeFromNib];
}

-(IBAction)deleteButtonAction:(id)sender{
    if (self.didSelectRmoveRow) {
        self.didSelectRmoveRow(_mCurDict);
    }
}

-(void)setMCurDict:(NSDictionary *)mCurDict{
    _mCurDict = mCurDict;
    [self.mWidth setStringValue:mCurDict[KWIDTH]];
    [self.mHidth setStringValue:mCurDict[KHIGHT]];

}
@end
