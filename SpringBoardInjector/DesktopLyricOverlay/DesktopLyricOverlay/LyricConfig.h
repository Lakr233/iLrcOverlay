//
//  LyricConfig.h
//  DesktopLyricOverlay
//
//  Created by Darwin on 10/30/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LyricConfig : NSObject

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, assign, readonly) BOOL useLandscapeMode;
@property (nonatomic, assign, readonly) BOOL placedAtTop;
@property (nonatomic, strong, readonly) UIFont *font;
@property (nonatomic, strong, readonly) NSDate *createdAt;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
