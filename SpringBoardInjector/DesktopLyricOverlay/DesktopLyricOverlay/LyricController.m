//
//  LyricController.m
//  DesktopLyricOverlay
//
//  Created by Darwin on 10/30/20.
//

#import "LyricController.h"

@interface LyricController ()

@end

@implementation LyricController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    _lyricLabel.text = @"👀";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([_lyricLabel.text isEqualToString:@"👀"]) {
            [_bannerView setHidden:YES];
        }
    });
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
