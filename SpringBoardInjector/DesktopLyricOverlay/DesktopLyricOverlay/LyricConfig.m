//
//  LyricConfig.m
//  DesktopLyricOverlay
//
//  Created by Darwin on 10/30/20.
//

#import "LyricConfig.h"
#import "UIFont+WDCustomLoader.h"

@implementation LyricConfig

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _enabled = [dict[@"Enabled"] boolValue];
        _useLandscapeMode = [dict[@"UseLandscapeMode"] boolValue];
        NSString *fontPath = [@"/System/Library/Fonts/AppFonts/" stringByAppendingPathComponent:(NSString *)(dict[@"FontFileName"] ?: @"Hiragino.ttf")];
        _font = [UIFont customFontWithURL:[NSURL fileURLWithPath:fontPath] size:[(NSNumber *)(dict[@"FontSize"] ?: @(14.0)) doubleValue]];
        if (!_font) {
            _font = [UIFont systemFontOfSize:14.0];
        }
        _createdAt = [NSDate date];
    }
    return self;
}

- (BOOL)isEnabled {
    return _enabled;
}

@end
