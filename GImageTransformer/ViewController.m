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
@interface ViewController ()  <NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, weak) IBOutlet  NSComboBox  *mComboBox;
@property (nonatomic, weak) IBOutlet NSTableView *mTableView;
@property (nonatomic, strong) NSMutableArray  *mSourceData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.

    [self addNewImageWithWidth:58 hight:58 name:@"58*58"];
    [self addNewImageWithWidth:87 hight:87 name:@"87*87"];
    [self addNewImageWithWidth:87 hight:87 name:@"87*87"];
    [self addNewImageWithWidth:87 hight:87 name:@"87*87"];
    [self addNewImageWithWidth:87 hight:87 name:@"87*87"];
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

    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"NewImageidentify" owner:self];

    return cellView;
    
}

#pragma mark - 文件选择。。
- (IBAction)selectImageFileAction:(id)sender{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.allowedFileTypes = @[@"png", @"jpeg"];
    panel.allowsMultipleSelection = NO;

    [panel beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
//            NSMutableArray* filePaths = [[NSMutableArray alloc] init];
            NSURL* element = panel.URLs.firstObject;
            [self.mComboBox selectText:[element path]];
//?            [self.mComboBox addItemWithObjectValue:[element path]];
//            for (NSURL* elemnet in [panel URLs]) {
//                [filePaths addObject:[elemnet path]];
//            }
        }
    }];
}


- (IBAction)deleteImageFileAction:(id)sender{

}
- (IBAction)addImageFileAction:(id)sender{

}
- (IBAction)createImageAction:(id)sender{

}

@end
