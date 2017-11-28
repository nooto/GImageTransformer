//
//  ViewController.m
//  GImageTransformer
//
//  Created by GaoAng on 2017/3/3.
//  Copyright © 2017年 selfWork.cn. All rights reserved.
//
#define KWIDTH  @"width"
#define KHIGHT  @"hight"
#define KNAme  @"name"

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

@property (nonatomic, assign) BOOL mImageType;

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
//    BOOL isDirectory = NO;
//    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.mComboBox.stringValue isDirectory:&isDirectory];
    [self.mPreImageView setImage:[[NSImage alloc] initWithContentsOfFile:self.mComboBox.stringValue]];
}

-(void)comboBoxSelectionDidChange:(NSNotification *)notification{
    if (self.mComboBox.selectedTag < self.mComboxSourceData.count) {
        self.mComboBox.stringValue = self.mComboxSourceData[self.mComboBox.selectedTag];
        [self.mPreImageView setImage:[[NSImage alloc] initWithContentsOfFile:self.mComboBox.stringValue]];
    }
}

-(void)addNewImageWidthEqualToHight:(NSInteger)widht name:(NSString*)name{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [tempDict setValue:@(widht) forKey:KWIDTH];
    [tempDict setValue:@(widht) forKey:KHIGHT];
    [tempDict setValue:name forKey:KNAme];
    [self.mSourceData addObject:tempDict];
}

//-(void)addNewImageWidthEqualToHight:(NSInteger)widht{
//    if (![self.mSourceData containsObject:@{KWIDTH:@(widht),KHIGHT:@(widht)}]) {
//        [self.mSourceData addObject:@{KWIDTH:@(widht),KHIGHT:@(widht)}];
//    }
//}

-(void)addNewImageWithWidth:(NSInteger)widht hight:(NSInteger)hight name:(NSString*)name{
    widht = labs(widht);
    hight = labs(hight);
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [tempDict setValue:@(widht) forKey:KWIDTH];
    [tempDict setValue:@(hight) forKey:KHIGHT];
    [tempDict setValue:name forKey:KNAme];
    [self.mSourceData addObject:tempDict];
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
    self.mImageType = sender.tag;

    if (sender.tag == 1) {
        [self.mSourceData removeAllObjects];
        
		[self addNewImageWidthEqualToHight:20 name:@"AppIcon_20"];
        [self addNewImageWidthEqualToHight:29 name:@"AppIcon_29"];
        [self addNewImageWidthEqualToHight:29 name:@"AppIcon_29_1"];
        [self addNewImageWidthEqualToHight:40 name:@"AppIcon_40"];
        [self addNewImageWidthEqualToHight:40 name:@"AppIcon_40_1"];
        [self addNewImageWidthEqualToHight:40 name:@"AppIcon_40_2"];
		[self addNewImageWidthEqualToHight:50 name:@"AppIcon_50"];

		[self addNewImageWidthEqualToHight:57 name:@"AppIcon_57"];

        [self addNewImageWidthEqualToHight:58 name:@"AppIcon_58"];
        [self addNewImageWidthEqualToHight:58 name:@"AppIcon_58_1"];
		[self addNewImageWidthEqualToHight:60 name:@"AppIcon_60"];
		[self addNewImageWidthEqualToHight:72 name:@"AppIcon_72"];
		[self addNewImageWidthEqualToHight:76 name:@"AppIcon_76"];

        [self addNewImageWidthEqualToHight:80 name:@"AppIcon_80"];
        [self addNewImageWidthEqualToHight:80 name:@"AppIcon_80_1"];
		[self addNewImageWidthEqualToHight:87 name:@"AppIcon_87"];
		[self addNewImageWidthEqualToHight:100 name:@"AppIcon_100"];
		[self addNewImageWidthEqualToHight:114 name:@"AppIcon_114"];

        [self addNewImageWidthEqualToHight:120 name:@"AppIcon_120"];
        [self addNewImageWidthEqualToHight:120 name:@"AppIcon_120_1"];
        [self addNewImageWidthEqualToHight:120 name:@"AppIcon_120_2"];
		[self addNewImageWidthEqualToHight:144 name:@"AppIcon_144"];
		[self addNewImageWidthEqualToHight:152 name:@"AppIcon_152"];
		[self addNewImageWidthEqualToHight:167 name:@"AppIcon_167"];
        [self addNewImageWidthEqualToHight:180 name:@"AppIcon_180"];
        [self addNewImageWidthEqualToHight:180 name:@"AppIcon_180_1"];
        [self addNewImageWidthEqualToHight:1024 name:@"AppIcon_1024"];

        
        [self addNewImageWithWidth:1024 hight:768 name:@"1024"];  //itunes connect
        [self.mTableView reloadData];
    }
    else{
        [self.mSourceData removeAllObjects];
        
        [self addNewImageWithWidth:320 hight:480 name:@"LaunchImage_320x480"];

        [self addNewImageWithWidth:640 hight:960 name:@"LaunchImage_640x960"];
        [self addNewImageWithWidth:640 hight:960 name:@"LaunchImage_640x960_1"];

        [self addNewImageWithWidth:640 hight:1136 name:@"LaunchImage_640x1136"];
        [self addNewImageWithWidth:640 hight:1136 name:@"LaunchImage_640x1136_1"];

        [self addNewImageWithWidth:768 hight:1004 name:@"LaunchImage_768x1004"];
        [self addNewImageWithWidth:768 hight:1024 name:@"LaunchImage_768x1024"];
        [self addNewImageWithWidth:768 hight:1024 name:@"LaunchImage_768x1024_1"];
        
        [self addNewImageWithWidth:1536 hight:2008 name:@"LaunchImage_1536x2008"];
        [self addNewImageWithWidth:1536 hight:2048 name:@"LaunchImage_1536x2048"];
        [self addNewImageWithWidth:1536 hight:2048 name:@"LaunchImage_1536x2048_1"];

        [self addNewImageWithWidth:1242 hight:2208 name:@"LaunchImage_1242x2208"];
        [self addNewImageWithWidth:750 hight:1334 name:@"LaunchImage_750x1334"];
        
        [self addNewImageWithWidth:1125 hight:2436 name:@"LaunchImage_1125x2436"];
        
        
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

    [self addNewImageWithWidth:self.mWidhtTextFile.integerValue hight:self.mHightTextFile.integerValue name:[NSString stringWithFormat:@"%zdx%zd", self.mWidhtTextFile.integerValue, self.mHightTextFile.integerValue]];


    [self.mTableView beginUpdates];
    NSRange  newrange = NSMakeRange(self.mSourceData.count-1, 1) ;
    [self.mTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:newrange] withAnimation:NSTableViewAnimationSlideUp];
    [self.mTableView endUpdates];

}
- (IBAction)createImageAction:(id)sender{

//    [self readyToSaveImages:nil];

	//*
	 	// initialise the file access class
	AppSandboxFileAccess *fileAccess = [AppSandboxFileAccess fileAccess];

		// the application was provided this file when the user dragged this file on to the app
	NSString *DesktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) firstObject];

	NSString *homedic = NSHomeDirectory(); // 用户目录
           NSString *userName = NSUserName(); // 用户目录
             homedic =    NSHomeDirectoryForUser(userName); //指定用户名的用户目录
//    NSString *DesktopPath11 = [NSString stringWithFormat:@"%@/%@/%@", homedic, @"Desktop",@"ImageTransformer"];
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
        
        //确保生成子文件夹
        NSString *destPath = [NSString stringWithFormat:@"%@/ImageTransformer/%@", DesktopPath,@"ImageTransformer"];
        if (self.mImageType == 1) {
            destPath = [NSString stringWithFormat:@"%@/ImageTransformer/%@", DesktopPath,@"AppIcon.appiconset"];
        }
        else{
            destPath = [NSString stringWithFormat:@"%@/ImageTransformer/%@", DesktopPath,@"LaunchImage.launchimage"];
        }

        NSFileManager *fileManager =  [NSFileManager defaultManager];
        [fileManager removeItemAtPath:destPath error:nil];
        BOOL isSuccess = NO; NSError *error = nil;
        isSuccess =  [fileManager  createDirectoryAtPath:destPath withIntermediateDirectories:yearMask attributes:nil error:&error];
		[self readyToSaveImages:destPath];
        
	}];

	if (!accessAllowed) {
		NSLog(@"Sad Wookie");
	}
    
	return;
	 
	 //*/

}

-(void)readyToSaveImages:(NSString*)destPath{
	NSImage *sourceImage = [[NSImage alloc] initWithContentsOfFile:self.mComboBox.stringValue];
	if (sourceImage.isValid) {
		if (self.mSourceData.count) {
			//*
			for (NSInteger i = 0; i < self.mSourceData.count; i++) {
				NSDictionary *dict =self.mSourceData[i];
				if ([dict isKindOfClass:[NSDictionary class]]) {
                    
//                    AppIcon.appiconset
//                    LaunchImage.launchimage
                    if (dict[KNAme]) {
                        NSImage  *newImage = [NSImage resizeImage:sourceImage size:CGSizeMake([dict[KWIDTH] integerValue]/2.f, [dict[KHIGHT] integerValue]/2.f)];
                        //写入制定的文件中。。。

                        NSString *newPath = [NSString stringWithFormat:@"%@/%@.png", destPath,
                                             dict[KNAme]
                                             ];
                        [newImage saveImage:newImage ToTarget:newPath];
                    }
				}
			}

            if (self.mImageType == 1) {
                [self saveIOSContentsJSONtoFile:destPath];
            }
            else{
                [self saveIOSLaunchContentsJSONtoFile:destPath];
            }
            
			NSAlert  *alert = [[NSAlert alloc] init];
			alert.icon = [NSImage imageNamed:@"AppIcon"];
			[alert setMessageText:@"生成成功，点击查看"];
			[alert addButtonWithTitle:@"查看"];
			[alert addButtonWithTitle:@"取消"];

			[alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {

				if(returnCode == ABS(NSModalResponseStop)){
					[[NSWorkspace sharedWorkspace] openFile:destPath]; // 使用默认程序打开文件
				}
				else if(returnCode == ABS(NSModalResponseAbort)){

				}

			}];
					 //*/

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


-(NSString*)getImageFileName:(NSInteger)width higth:(NSInteger)hight{
    NSString *fileName =  [NSString stringWithFormat:@"%ld_%ld.png",width, hight];
    return fileName;
}



#pragma mark -   ios app icon
-(void)saveIOSContentsJSONtoFile:(NSString*)destPath{
    NSMutableDictionary *contentDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    //图片信息
    
    NSInteger width = 0, scale = 1;
    NSMutableArray *imageInfoArr= [[NSMutableArray alloc] initWithCapacity:2];


    width = 20, scale = 2;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"iphone"]];
    
    width = 20, scale = 3;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"iphone"]];
    width = 29, scale = 1;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"iphone"]];

    width = 29, scale = 2;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"iphone"]];
    width = 29, scale = 3;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"iphone"]];
    width = 40, scale = 2;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"iphone"]];
    width = 40, scale = 3;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"iphone"]];
    
    width = 57, scale = 1;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"iphone"]];
    
    width = 57, scale = 2;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"iphone"]];

    width = 60, scale = 2;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"iphone"]];
    width = 60, scale = 3;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"iphone"]];


    
    width = 20, scale = 1;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"ipad"]];

    
    width = 20, scale = 2;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd_1.png",width*scale] idiom:@"ipad"]];


    width = 29, scale = 1;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd_1.png",width*scale] idiom:@"ipad"]];
    
    width = 29, scale = 2;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd_1.png",width*scale] idiom:@"ipad"]];
    
    width = 40, scale = 1;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd_2.png",width*scale] idiom:@"ipad"]];
    
    width = 40, scale = 2;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd_1.png",width*scale] idiom:@"ipad"]];

    
    width = 50, scale = 1;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"ipad"]];
    
    width = 50, scale = 2;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"ipad"]];
    
    
    width = 72, scale = 1;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"ipad"]];
    
    width = 72, scale = 2;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"ipad"]];

    width = 76, scale = 1;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"ipad"]];

    width = 76, scale = 2;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"ipad"]];
    
//    width = 83.5, scale = 2;
//    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd.png",width*scale] idiom:@"ipad"]];
    
    NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:[NSString stringWithFormat:@"%.1fx%.1f",83.5,83.5] forKey:@"size"];
    [imageDict setObject:[NSString stringWithFormat:@"AppIcon_%zd.png",83.5*2] forKey:@"filename"];
    [imageDict setObject:[NSString stringWithFormat:@"AppIcon_%zd.png",167] forKey:@"filename"];
    [imageDict setObject:[NSString stringWithFormat:@"%zdx", 2] forKey:@"scale"];
    //    [imageDict setObject:@"iphone" forKey:@"idiom"];
    [imageDict setObject:@"ipad" forKey:@"idiom"];
    [imageInfoArr addObject:imageDict];

    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"ios-marketing" forKey:@"idiom"];
    [imageDict setObject:[NSString stringWithFormat:@"%zdx%zd",1024,1024] forKey:@"size"];
    [imageDict setObject:[NSString stringWithFormat:@"AppIcon_%zd.png",1024] forKey:@"filename"];
    [imageDict setObject:[NSString stringWithFormat:@"%zdx", 1] forKey:@"scale"];
    [imageInfoArr addObject:imageDict];

    width = 60, scale = 2;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd_2.png",width*scale] idiom:@"car"]];
    
    width = 60, scale = 3;
    [imageInfoArr addObject:[self createImageDictWithSize:width scale:scale name:[NSString stringWithFormat:@"AppIcon_%zd_1.png",width*scale] idiom:@"car"]];
    
    //info
    [contentDict setObject:imageInfoArr forKey:@"images"];
    [contentDict setObject:@{@"version":@(1), @"author":@"xcode"} forKey:@"info"];

    //保存到本地
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",destPath,@"Contents.json"];

    NSData *data =    [NSJSONSerialization dataWithJSONObject:contentDict options:NSJSONWritingPrettyPrinted error:nil];

    if ([data isKindOfClass:[NSData class]]) {
        NSError *error = nil;
        BOOL success =[data writeToFile:filePath options:NSDataWritingAtomic error:&error];
        if (success) {
            return;
        }
        else{
        }
    }
}

-(NSDictionary*)createImageDictWithSize:(NSInteger)size scale:(NSInteger)scale name:(NSString*)name idiom:(NSString*)idiom{
   NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:[NSString stringWithFormat:@"%zdx%zd",size,size] forKey:@"size"];
    [imageDict setObject:name forKey:@"filename"];
    [imageDict setObject:[NSString stringWithFormat:@"%zdx", scale] forKey:@"scale"];
//    [imageDict setObject:@"iphone" forKey:@"idiom"];
    [imageDict setObject:idiom forKey:@"idiom"];
    return imageDict;
}


#pragma mark - icon launchimage

-(void)saveIOSLaunchContentsJSONtoFile:(NSString*)destPath{
    NSMutableDictionary *contentDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    //图片信息
    NSMutableArray *imageInfoArr= [[NSMutableArray alloc] initWithCapacity:2];
    
    NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"iphone" forKey:@"idiom"];
    [imageDict setObject:@"2436h" forKey:@"subtype"];
    [imageDict setObject:@"LaunchImage_1125x2436.png" forKey:@"filename"];
    [imageDict setObject:@"11.0" forKey:@"minimum-system-version"];
    [imageDict setObject:@"portrait" forKey:@"orientation"];
    [imageDict setObject:@"3x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
  
  
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"iphone" forKey:@"idiom"];
    [imageDict setObject:@"2436h" forKey:@"subtype"];
    [imageDict setObject:@"11.0" forKey:@"minimum-system-version"];
    [imageDict setObject:@"landscape" forKey:@"orientation"];
    [imageDict setObject:@"3x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"iphone" forKey:@"idiom"];
    [imageDict setObject:@"736h" forKey:@"subtype"];
//    [imageDict setObject:@"shanping_iPhone6 plus.png" forKey:@"filename"];
    [imageDict setObject:@"LaunchImage_1242x2208.png" forKey:@"filename"];
    [imageDict setObject:@"8.0" forKey:@"minimum-system-version"];
    [imageDict setObject:@"portrait" forKey:@"orientation"];
    [imageDict setObject:@"3x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    
    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"landscape" forKey:@"orientation"];
    [imageDict setObject:@"iphone" forKey:@"idiom"];
    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"8.0" forKey:@"minimum-system-version"];
    [imageDict setObject:@"736h" forKey:@"subtype"];
    [imageDict setObject:@"3x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    
    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"iphone" forKey:@"idiom"];
    [imageDict setObject:@"667h" forKey:@"subtype"];
    [imageDict setObject:@"shanping_iPhone6.png" forKey:@"filename"];
    [imageDict setObject:@"LaunchImage_750x1334.png" forKey:@"filename"];
    [imageDict setObject:@"8.0" forKey:@"minimum-system-version"];
    [imageDict setObject:@"portrait" forKey:@"orientation"];
    [imageDict setObject:@"2x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    
    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    [imageDict setObject:@"portrait" forKey:@"orientation"];
    [imageDict setObject:@"iphone" forKey:@"idiom"];
    [imageDict setObject:@"shanping_iPhone4-1.png" forKey:@"filename"];
    [imageDict setObject:@"LaunchImage_640x960_1.png" forKey:@"filename"];

    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"7.0" forKey:@"minimum-system-version"];
    [imageDict setObject:@"2x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    
    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"iphone" forKey:@"idiom"];
    [imageDict setObject:@"retina4" forKey:@"subtype"];
    [imageDict setObject:@"7.0" forKey:@"minimum-system-version"];
    [imageDict setObject:@"shanping_iPhone5.png" forKey:@"filename"];
    [imageDict setObject:@"LaunchImage_640x1136_1.png" forKey:@"filename"];

    [imageDict setObject:@"portrait" forKey:@"orientation"];
    [imageDict setObject:@"2x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    
//=====
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"portrait" forKey:@"orientation"];
    [imageDict setObject:@"ipad" forKey:@"idiom"];
    [imageDict setObject:@"LaunchImage_768x1024.png" forKey:@"filename"];
    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"7.0" forKey:@"minimum-system-version"];
    [imageDict setObject:@"1x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    

    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"landscape" forKey:@"orientation"];
    [imageDict setObject:@"ipad" forKey:@"idiom"];
    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"7.0" forKey:@"minimum-system-version"];
    [imageDict setObject:@"1x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    

    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"portrait" forKey:@"orientation"];
    [imageDict setObject:@"ipad" forKey:@"idiom"];
    [imageDict setObject:@"LaunchImage_1536x2048.png" forKey:@"filename"];

    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"7.0" forKey:@"minimum-system-version"];
    [imageDict setObject:@"2x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    
    
    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"landscape" forKey:@"orientation"];
    [imageDict setObject:@"ipad" forKey:@"idiom"];
    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"7.0" forKey:@"minimum-system-version"];
    [imageDict setObject:@"2x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];


    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"landscape" forKey:@"orientation"];
    [imageDict setObject:@"ipad" forKey:@"idiom"];
    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"7.0" forKey:@"minimum-system-version"];
    [imageDict setObject:@"2x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"portrait" forKey:@"orientation"];
    [imageDict setObject:@"iphone" forKey:@"idiom"];
    [imageDict setObject:@"LaunchImage_320x480.png" forKey:@"filename"];

    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"1x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    
    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"portrait" forKey:@"orientation"];
    [imageDict setObject:@"iphone" forKey:@"idiom"];
    [imageDict setObject:@"shanping_iPhone4.png" forKey:@"filename"];
    [imageDict setObject:@"LaunchImage_640x960.png" forKey:@"filename"];

    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"2x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];


   
    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"portrait" forKey:@"orientation"];
    [imageDict setObject:@"iphone" forKey:@"idiom"];
    [imageDict setObject:@"shanping_iPhone5-1.png" forKey:@"filename"];
    [imageDict setObject:@"LaunchImage_640x1136.png" forKey:@"filename"];

    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"retina4" forKey:@"subtype"];
    [imageDict setObject:@"2x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];

    
    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"portrait" forKey:@"orientation"];
    [imageDict setObject:@"ipad" forKey:@"idiom"];
    [imageDict setObject:@"LaunchImage_768_1004.png" forKey:@"filename"];
    [imageDict setObject:@"LaunchImage_768x1004.png" forKey:@"filename"];
    [imageDict setObject:@"to-status-bar" forKey:@"extent"];
    [imageDict setObject:@"1x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];

    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"portrait" forKey:@"orientation"];
    [imageDict setObject:@"ipad" forKey:@"idiom"];
    [imageDict setObject:@"LaunchImage_768_1024-3.png" forKey:@"filename"];
    [imageDict setObject:@"LaunchImage_768x1024_1.png" forKey:@"filename"];
    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"1x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];

    
    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"landscape" forKey:@"orientation"];
    [imageDict setObject:@"ipad" forKey:@"idiom"];
    [imageDict setObject:@"to-status-bar" forKey:@"extent"];
    [imageDict setObject:@"1x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    

    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"landscape" forKey:@"orientation"];
    [imageDict setObject:@"ipad" forKey:@"idiom"];
    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"1x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];

    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"portrait" forKey:@"orientation"];
    [imageDict setObject:@"ipad" forKey:@"idiom"];
    [imageDict setObject:@"LaunchImage_1536_2008.png" forKey:@"filename"];
    [imageDict setObject:@"LaunchImage_1536x2008.png" forKey:@"filename"];
    [imageDict setObject:@"to-status-bar" forKey:@"extent"];
    [imageDict setObject:@"2x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"portrait" forKey:@"orientation"];
    [imageDict setObject:@"ipad" forKey:@"idiom"];
    [imageDict setObject:@"LaunchImage_1536_2048_2.png" forKey:@"filename"];
    [imageDict setObject:@"LaunchImage_1536x2048_1.png" forKey:@"filename"];
    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"2x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    
    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"landscape" forKey:@"orientation"];
    [imageDict setObject:@"ipad" forKey:@"idiom"];
    [imageDict setObject:@"full-screen" forKey:@"extent"];
    [imageDict setObject:@"2x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    
    imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:@"landscape" forKey:@"orientation"];
    [imageDict setObject:@"ipad" forKey:@"idiom"];
    [imageDict setObject:@"to-status-bar" forKey:@"extent"];
    [imageDict setObject:@"2x" forKey:@"scale"];
    [imageInfoArr addObject:imageDict];
    
    
    //info
    [contentDict setObject:imageInfoArr forKey:@"images"];
    [contentDict setObject:@{@"version":@(1), @"author":@"xcode"} forKey:@"info"];
    
    //保存到本地
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",destPath,@"Contents.json"];
    
    NSData *data =    [NSJSONSerialization dataWithJSONObject:contentDict options:NSJSONWritingPrettyPrinted error:nil];
    
    if ([data isKindOfClass:[NSData class]]) {
        NSError *error = nil;
        BOOL success =[data writeToFile:filePath options:NSDataWritingAtomic error:&error];
        if (success) {
            return;
        }
        else{
        }
    }
}

-(NSDictionary*)createLaunchImageDictWithSize:(NSInteger)size scale:(NSInteger)scale{
    
    NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [imageDict setObject:[NSString stringWithFormat:@"%zdx%zd",size,size] forKey:@"size"];
    [imageDict setObject:[self getImageFileName:size*scale higth:size*scale] forKey:@"filename"];
    [imageDict setObject:[NSString stringWithFormat:@"%zdx", scale] forKey:@"scale"];
    [imageDict setObject:@"iphone" forKey:@"idiom"];
    return imageDict;
}

@end
