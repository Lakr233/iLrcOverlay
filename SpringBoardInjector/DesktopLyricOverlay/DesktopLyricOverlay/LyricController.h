//
//  LyricController.h
//  DesktopLyricOverlay
//
//  Created by Darwin on 10/30/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LyricController : UIViewController
@property (unsafe_unretained, nonatomic) IBOutlet UIView *bannerView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lyricLabel;
@end

NS_ASSUME_NONNULL_END
