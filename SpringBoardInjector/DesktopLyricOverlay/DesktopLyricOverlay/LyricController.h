//
//  LyricController.h
//  DesktopLyricOverlay
//
//  Created by Darwin on 10/30/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LyricConfig;

@interface LyricController : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet UIView *bannerView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lyricLabel;

+ (instancetype)newWithLyricConfig:(LyricConfig *)config;
- (void)showLyricWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
