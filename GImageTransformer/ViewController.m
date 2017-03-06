//
//  ViewController.m
//  GImageTransformer
//
//  Created by GaoAng on 2017/3/3.
//  Copyright © 2017年 selfWork.cn. All rights reserved.
//
#define KWIDTH  @"width"
#define KHIGHT  @"hight"
#define KNAME   @"name"

#import "ViewController.h"

#import "NSImageProperyCellView.h"
#import "NSImage+category.h"

@interface ViewController ()  <NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, weak) IBOutlet  NSComboBox  *mComboBox;
@property (nonatomic, weak) IBOutlet NSTableView *mTableView;
@property (nonatomic, strong) NSMutableArray  *mSourceData;

@property (nonatomic, weak) IBOutlet NSTextField *mWidhtTextFile;
@property (nonatomic, weak) IBOutlet NSTextField *mHightTextFile;
@property (nonatomic, weak) IBOutlet NSTextField *mNameTextFile;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    NSInteger maxValue, minValue;
    maxValue = 5000;
    minValue = 1;

    NSNumberFormatter * formater = [[NSNumberFormatter alloc] init];
    formater.numberStyle         = NSNumberFormatterDecimalStyle;
    formater.maximum             = @(maxValue);
    formater.minimum              = @(minValue);
    self.mWidhtTextFile.cell.formatter       = formater;
    self.mHightTextFile.cell.formatter       = formater;

    self.mTableView.rowHeight = 35;
}

-(NSMutableArray*)mSourceData{
    if (!_mSourceData) {
        _mSourceData = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _mSourceData;
}

-(void)addNewImageWithWidth:(NSInteger)widht hight:(NSInteger)hight name:(NSString*)name{
    widht = labs(widht);
    hight = labs(hight);

    if (name.length <= 0) {
        name = [NSString stringWithFormat:@"%lu", (unsigned long)self.mSourceData.count];
    }
    [self.mSourceData addObject:@{KWIDTH:@(widht),KHIGHT:@(hight), KNAME:name}];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
     return  self.mSourceData.count;
}

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    NSImageProperyCellView *cellView = [tableView makeViewWithIdentifier:@"NSImageProperyCellView" owner:self];
    if (row >=0 && row < self.mSourceData.count) {
        [cellView setMCurDict:self.mSourceData[row]];
    }

    return cellView;
}

#pragma mark - 文件选择。。
- (IBAction)selectImageFileAction:(id)sender{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.allowedFileTypes = @[@"png", @"jpeg"];
    panel.allowsMultipleSelection = NO;

    [panel beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSURL* element = panel.URLs.firstObject;
            [self.mComboBox selectText:[element path]];
        }
    }];
}


- (IBAction)deleteImageFileAction:(id)sender{
    if (self.mSourceData.count >0 && self.mTableView.selectedRow < self.mSourceData.count) {
        [self.mTableView beginUpdates];
        [self.mSourceData removeObjectAtIndex:self.mTableView.selectedRow];
        NSRange  range = NSMakeRange(self.mTableView.selectedRow, 1);
        [self.mTableView  removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] withAnimation:NSTableViewAnimationSlideUp];
        [self.mTableView endUpdates];
    }
}

- (IBAction)addImageFileAction:(id)sender{
    if (self.mWidhtTextFile.stringValue.length <= 0) {
//        NSAlert *alert = [NSAlert alertWithMessageText:@"messageText"
//                                         defaultButton:@"defaultButton"
//                                       alternateButton:@"alternateButton"
//                                           otherButton:@"otherButton"
//                             informativeTextWithFormat:@"informativeText"];
//
//        NSUInteger action = [alert runModal];
//            //响应window的按钮事件
//        if(action == NSAlertDefaultReturn)
//        {
//            NSLog(@"defaultButton clicked!");
//        }
//        else if(action == NSAlertAlternateReturn )
//        {
//            NSLog(@"alternateButton clicked!");
//        }
//        else if(action == NSAlertOtherReturn)
//        {
//            NSLog(@"otherButton clicked!");
//        }
    }
    if (self.mHightTextFile.stringValue.length <= 0) {

    }
    if (self.mNameTextFile.stringValue.length <= 0) {

    }

    [self addNewImageWithWidth:self.mWidhtTextFile.integerValue hight:self.mHightTextFile.integerValue name:self.mNameTextFile.stringValue];


    [self.mTableView beginUpdates];
    NSRange  newrange = NSMakeRange(self.mSourceData.count-1, 1) ;
    [self.mTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:newrange] withAnimation:NSTableViewAnimationSlideUp];
    [self.mTableView endUpdates];

}
- (IBAction)createImageAction:(id)sender{
    NSString *homedic = NSHomeDirectory(); // 用户目录
    NSString *userName = NSUserName(); // 用户目录
    homedic =    NSHomeDirectoryForUser(userName); //指定用户名的用户目录
    NSString *DesktopPath = [NSString stringWithFormat:@"%@/%@", homedic, @"Desktop"];
    NSLog(@"%@", DesktopPath);

    NSImage *image = [[NSImage alloc] initWithContentsOfFile:self.mComboBox.stringValue];
    image = [NSImage imageResize:image newSize:CGSizeMake(100, 100)];
}

@end
