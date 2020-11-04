//
//  LyricController.m
//  DesktopLyricOverlay
//
//  Created by Darwin on 10/30/20.
//

#import "LyricController.h"
#import "LyricConfig.h"

static NSBundle *SpringBoardBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithPath:@"/System/Library/CoreServices/SpringBoard.app"];
    });
    return bundle;
}

// First, we declare the function. Making it weak-linked
// ensures the preference pane won't crash if the function
// is removed from in a future version of Mac OS X.
extern void _CFBundleFlushBundleCaches(CFBundleRef bundle)
    __attribute__((weak_import));

static BOOL FlushBundleCache(NSBundle *prefBundle) {
    // Before calling the function, we need to check if it exists
    // since it was weak-linked.
    if (_CFBundleFlushBundleCaches != NULL) {
        NSLog(@"Flushing bundle cache with _CFBundleFlushBundleCaches");
        CFBundleRef cfBundle =
           CFBundleCreate(nil, (CFURLRef)[prefBundle bundleURL]);
        _CFBundleFlushBundleCaches(cfBundle);
        CFRelease(cfBundle);
        return YES; // Success
    }
    return NO; // Not available
}

@interface LyricController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) LyricConfig *config;
@end

@implementation LyricController

+ (instancetype)newWithLyricConfig:(LyricConfig *)config {
    FlushBundleCache(SpringBoardBundle());
    LyricController *ctrl = [[UIStoryboard storyboardWithName:@"Lyric" bundle:SpringBoardBundle()] instantiateInitialViewController];
    ctrl.config = config;
    return ctrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    _lyricLabel.font = _config.font;

    if (_config.placedAtTop) {
        _topConstraint.priority = UILayoutPriorityRequired;
        _bottomConstraint.priority = 1;
    } else {
        _topConstraint.priority = 1;
        _bottomConstraint.priority = UILayoutPriorityRequired;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [UIView setAnimationsEnabled:YES];
    }];
    [UIView setAnimationsEnabled:NO];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return _config.useLandscapeMode ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}

- (void)showLyricWithString:(NSString *)string {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideLyric) object:nil];
    [_bannerView setHidden:NO];
    [_lyricLabel setText:string];

    // curl http://127.0.0.1:6996/SETLRC\?param\=VEVTVCBERUJVRyBOTyBISURFIDAxMjMg5rWL6K+VIPCfmIIK
    if ([string containsString:@"TEST DEBUG NO HIDE"]) {
        return;
    }

    [self performSelector:@selector(hideLyric) withObject:nil afterDelay:8.0];
}

- (void)hideLyric {
    [_bannerView setHidden:YES];
}

@end
