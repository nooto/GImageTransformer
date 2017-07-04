//
//  AppDelegate.m
//  GImageTransformer
//
//  Created by GaoAng on 2017/3/3.
//  Copyright © 2017年 selfWork.cn. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()<NSWindowDelegate>
@property (nonatomic, strong) IBOutlet NSWindow *keyWindow;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [NSApplication sharedApplication].keyWindow.delegate = self;
    
    NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    self.rootController = [sb instantiateControllerWithIdentifier:@"ViewController"];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize{
    NSLog(@"%f %f",frameSize.width, frameSize.height);
    return frameSize;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
