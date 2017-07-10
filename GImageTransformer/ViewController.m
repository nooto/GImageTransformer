//
//  ViewController.m
//  GImageTransformer
//
//  Created by GaoAng on 2017/3/3.
//  Copyright © 2017年 selfWork.cn. All rights reserved.
//
#define KWIDTH  @"width"
#define KHIGHT  @"hight"

#define KMAXINPUT  9999
#define KComboxSourceData   @"ComboxSourceData"
#define WS(weakSelf) __weak __typeof(&*self)weakSelf = self;


#import "ViewController.h"

#import "NSImageProperyCellView.h"
#import "NSImage+category.h"
#import "AppSandboxFileAccess.h"

@interface ViewController ()  <NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDelegate, NSComboBoxDataSource, NSWindowDelegate,NSTextDelegate, NSDraggingDestination>
@property (nonatomic, weak) IBOutlet  NSComboBox  *mComboBox;
@property (nonatomic, weak) IBOutlet NSTableView *mTableView;
@property (nonatomic, strong) NSMutableArray  *mSourceData;

@property (nonatomic, weak) IBOutlet NSTextField *mWidhtTextFile;
@property (nonatomic, weak) IBOutlet NSTextField *mHightTextFile;
@property (nonatomic, weak) IBOutlet NSImageView *mPreImageView;

@property (nonatomic, strong) NSMutableArray *mComboxSourceData;

@property (nonatomic, assign) NSInteger initWidth;
@property (nonatomic, assign) NSInteger initHight;


@property (nonatomic, strong) NSView *mBGView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(controlTextDidChange:)
                                                 name:NSTextDidChangeNotification
                                               object:nil];

    [self.mTableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,nil]];

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
    self.mTableView.rowHeight = 45;

}

-(NSMutableArray*)mSourceData{
    if (!_mSourceData) {
        _mSourceData = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _mSourceData;
}

-(NSMutableArray*)mComboxSourceData{
    if (!_mComboxSourceData) {
        _mComboxSourceData = [[NSMutableArray alloc] initWithCapacity:1];
      id  sourceData =  [[NSUserDefaults standardUserDefaults] objectForKey:KComboxSourceData];
        if ([sourceData isKindOfClass:[NSArray class]]) {
            [_mComboxSourceData addObjectsFromArray:sourceData];
        }
    }
    return _mComboxSourceData;
}

#pragma mark - NSCombox
-(NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox{
    return self.mComboxSourceData.count;
}

-(id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index{
    if (index < self.mComboxSourceData.count) {
        return self.mComboxSourceData[index];
    }
    else{
        return nil;
    }
}
- (IBAction)OnComboboxChanged:(id)sender{
    [self.mPreImageView setImage:[[NSImage alloc] initWithContentsOfFile:self.mComboBox.stringValue]];
}

-(void)comboBoxSelectionDidChange:(NSNotification *)notification{
    if (self.mComboBox.selectedTag < self.mComboxSourceData.count) {
        self.mComboBox.stringValue = self.mComboxSourceData[self.mComboBox.selectedTag];
        [self.mPreImageView setImage:[[NSImage alloc] initWithContentsOfFile:self.mComboBox.stringValue]];
    }
}

-(void)addNewImageWidthEqualToHight:(NSInteger)widht{
	if (![self.mSourceData containsObject:@{KWIDTH:@(widht),KHIGHT:@(widht)}]) {
		[self.mSourceData addObject:@{KWIDTH:@(widht),KHIGHT:@(widht)}];
	}
}

-(void)addNewImageWithWidth:(NSInteger)widht hight:(NSInteger)hight{
    widht = labs(widht);
    hight = labs(hight);
    if (![self.mSourceData containsObject:@{KWIDTH:@(widht),KHIGHT:@(hight)}]) {
        [self.mSourceData addObject:@{KWIDTH:@(widht),KHIGHT:@(hight)}];
    }
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


    WS(weakSelf);
    [cellView setDidSelectRmoveRow:^(NSDictionary *dict) {
        if ([weakSelf.mSourceData containsObject:dict]) {
            [self.mTableView beginUpdates];
            NSInteger index = [weakSelf.mSourceData indexOfObject:dict];
            [weakSelf.mSourceData removeObject:dict];
            NSRange  range = NSMakeRange(index, 1);
            [self.mTableView  removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] withAnimation:NSTableViewAnimationSlideUp];

            [self.mTableView endUpdates];
        }
    }];

    return cellView;
}

#pragma mark - 文件选择。。
- (IBAction)selectImageFileAction:(id)sender{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.allowedFileTypes = @[@"png", @"jpeg"];
    panel.allowsMultipleSelection = NO;
	panel.prompt = @"选中";

    [panel beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSURL* element = panel.URLs.firstObject;

            [self.mComboxSourceData insertObject:[element path] atIndex:0];

            [[NSUserDefaults standardUserDefaults] setValue:self.mComboxSourceData forKey:KComboxSourceData];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [self.mComboBox reloadData];
//            [self.mComboBox insertItemWithObjectValue:[element path] atIndex:0];
            self.mComboBox.stringValue = [element path];
            [self.mPreImageView setImage:[[NSImage alloc] initWithContentsOfFile:element.path]];
        }
    }];
}

#pragma mark - Destination Operations

-(NSDragOperation) draggingEntered:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pb =[sender draggingPasteboard];
    NSArray *array=[pb types];
    if ([array containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

    //
//-(BOOL) prepareForDragOperation:(id<NSDraggingInfo>)sender
//{
//    NSPasteboard *pb =[sender draggingPasteboard];
//    NSArray *list =[pb propertyListForType:NSFilenamesPboardType];
//    return YES;
//}



-(IBAction)addAppIcon:(NSButton*)sender{
    if (sender.tag == 1) {
        [self.mSourceData removeAllObjects];


		[self addNewImageWidthEqualToHight:20];
		[self addNewImageWidthEqualToHight:29];
		[self addNewImageWidthEqualToHight:40];
		[self addNewImageWidthEqualToHight:50];

		[self addNewImageWidthEqualToHight:57];

		[self addNewImageWidthEqualToHight:58];
		[self addNewImageWidthEqualToHight:60];
		[self addNewImageWidthEqualToHight:72];
		[self addNewImageWidthEqualToHight:76];

		[self addNewImageWidthEqualToHight:80];
		[self addNewImageWidthEqualToHight:87];
		[self addNewImageWidthEqualToHight:100];
		[self addNewImageWidthEqualToHight:114];

		[self addNewImageWidthEqualToHight:120];
		[self addNewImageWidthEqualToHight:144];
		[self addNewImageWidthEqualToHight:152];
		[self addNewImageWidthEqualToHight:167];
		[self addNewImageWidthEqualToHight:180];
		[self addNewImageWithWidth:1024 hight:768];  //itunes connect

        [self.mTableView reloadData];
    }
    else{
        [self.mSourceData removeAllObjects];

        [self addNewImageWithWidth:16 hight:16];
        [self addNewImageWithWidth:32 hight:32];

        [self addNewImageWithWidth:64 hight:64];
        [self addNewImageWithWidth:128 hight:128];
        [self addNewImageWithWidth:256 hight:256];

        [self addNewImageWithWidth:512 hight:512];
        [self addNewImageWithWidth:1024 hight:1024];

        [self.mTableView reloadData];
    }
}


- (IBAction)deleteImageFileAction:(id)sender{
    [self.mSourceData removeAllObjects];
    [self.mTableView reloadData];

//    if (self.mSourceData.count >0 && self.mTableView.selectedRow < self.mSourceData.count) {
//        [self.mTableView beginUpdates];
//        [self.mSourceData removeObjectAtIndex:self.mTableView.selectedRow];
//        NSRange  range = NSMakeRange(self.mTableView.selectedRow, 1);
//        [self.mTableView  removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] withAnimation:NSTableViewAnimationSlideUp];
//        [self.mTableView endUpdates];
//    }
}
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize{
    NSLog(@"%f %f",frameSize.width, frameSize.height);
    return frameSize;
}

- (void)controlTextDidChange:(NSNotification *)notification{
    if ([self.mWidhtTextFile isEqualTo:notification.object]) {
        if (self.mWidhtTextFile.integerValue >= KMAXINPUT) {
            [self.mWidhtTextFile setIntValue:KMAXINPUT];
            self.initWidth = KMAXINPUT;
        }
        else{
            self.initWidth = self.mWidhtTextFile.integerValue;
        }
    }
    else if ([self.mHightTextFile isEqualTo:notification.object]){
        if (self.mHightTextFile.integerValue >= KMAXINPUT) {
            [self.mHightTextFile setIntValue:KMAXINPUT];
            self.initHight = KMAXINPUT;
        }
        else{
            self.initHight = self.mHightTextFile.integerValue;
        }
    }
}

- (IBAction)multipleButton:(NSButton*)sender{
    if (self.initWidth > 0) {
        [self.mWidhtTextFile setIntValue:(int)(self.initWidth * sender.tag)];
    }

    if (self.initHight > 0) {
        [self.mHightTextFile setIntValue:(int)(self.initHight * sender.tag)];
    }
}

- (IBAction)addImageFileAction:(id)sender{
    if (self.mWidhtTextFile.stringValue.length <= 0) {
        NSAlert  *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"请指定要生成的图片宽度"];
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];
        [self.mWidhtTextFile becomeFirstResponder];
        return;
    }

    if (self.mHightTextFile.stringValue.length <= 0) {
        NSAlert  *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"请指定要生成的图片高度"];
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];
        [self.mHightTextFile becomeFirstResponder];
        return;
    }

    [self addNewImageWithWidth:self.mWidhtTextFile.integerValue hight:self.mHightTextFile.integerValue];


    [self.mTableView beginUpdates];
    NSRange  newrange = NSMakeRange(self.mSourceData.count-1, 1) ;
    [self.mTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:newrange] withAnimation:NSTableViewAnimationSlideUp];
    [self.mTableView endUpdates];

}
- (IBAction)createImageAction:(id)sender{

	[self readyToSaveImages:nil];

	/*
	 	// initialise the file access class
	AppSandboxFileAccess *fileAccess = [AppSandboxFileAccess fileAccess];

		// the application was provided this file when the user dragged this file on to the app
	NSString *DesktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) firstObject];

	NSString *homedic = NSHomeDirectory(); // 用户目录
           NSString *userName = NSUserName(); // 用户目录
             homedic =    NSHomeDirectoryForUser(userName); //指定用户名的用户目录
             NSString *DesktopPath11 = [NSString stringWithFormat:@"%@/%@/%@", homedic, @"Desktop",@"ImageTransformer"];
// -            NSLog(@"%@", DesktopPath);

	BOOL isDirectory = NO;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:DesktopPath isDirectory:&isDirectory];
	NSAssert(fileExists, @"File not found!");

		// persist permission to access the file the user introduced to the app, so we can always
		// access it and then the AppSandboxFileAccess class won't prompt for it if you wrap access to it
	[fileAccess persistPermissionPath:DesktopPath];

		// get the parent directory for the file
	NSString *directory = (isDirectory) ? DesktopPath : [DesktopPath stringByDeletingLastPathComponent];

		// get access to the parent directory
	BOOL accessAllowed = [fileAccess accessFilePath:directory persistPermission:YES withBlock:^{
		[self readyToSaveImages:DesktopPath];
	}];

	if (!accessAllowed) {
		NSLog(@"Sad Wookie");
	}


	return;
	 
	 //*/

}

-(void)readyToSaveImages:(NSString*)DesktopPath{
	NSImage *sourceImage = [[NSImage alloc] initWithContentsOfFile:self.mComboBox.stringValue];
	if (sourceImage.isValid) {
		if (self.mSourceData.count) {

			/*
				//确保生成子文件夹
			NSString *destPath = [NSString stringWithFormat:@"%@/%@", DesktopPath,@"ImageTransformer"];
			NSFileManager *fileManager =  [NSFileManager defaultManager];
			[fileManager removeItemAtPath:destPath error:nil];
			BOOL isSuccess = NO; NSError *error = nil;
			isSuccess =  [fileManager  createDirectoryAtPath:destPath withIntermediateDirectories:yearMask attributes:nil error:&error];

			for (NSInteger i = 0; i < self.mSourceData.count; i++) {
				NSDictionary *dict =self.mSourceData[i];
				if ([dict isKindOfClass:[NSDictionary class]]) {
					NSImage  *newImage = [NSImage resizeImage:sourceImage size:CGSizeMake([dict[KWIDTH] integerValue], [dict[KHIGHT] integerValue])];
						//写入制定的文件中。。。
					NSString *newPath = [NSString stringWithFormat:@"%@/%@.png", destPath,
										 [NSString stringWithFormat:@"%ld*%ld",
										  [dict[KWIDTH] integerValue],
										  [dict[KHIGHT] integerValue]]
										 ];
					[newImage saveImage:newImage ToTarget:newPath];
				}
			}

			NSAlert  *alert = [[NSAlert alloc] init];
			alert.icon = [NSImage imageNamed:@"AppIcon"];
			[alert setMessageText:@"生成成功，点击查看"];
			[alert addButtonWithTitle:@"查看"];
			[alert addButtonWithTitle:@"取消"];

			[alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {

				if(returnCode == abs(NSModalResponseStop)){
					[[NSWorkspace sharedWorkspace] openFile:destPath];  使用默认程序打开文件
				}
				else if(returnCode == abs(NSModalResponseAbort)){

				}

			}];
					 */

		}
		else{
			NSAlert  *alert = [[NSAlert alloc] init];
			alert.icon = [NSImage imageNamed:@"AppIcon"];
			[alert setMessageText:@"请指定要生成的图片尺寸"];
			[alert addButtonWithTitle:@"确定"];
			[alert runModal];
		}
	}
	else{
		NSAlert  *alert = [[NSAlert alloc] init];
		alert.icon = [NSImage imageNamed:@"AppIcon"];
		[alert setMessageText:@"没有选择源图片"];
		[alert addButtonWithTitle:@"确定"];
		[alert runModal];
	}
}

@end
