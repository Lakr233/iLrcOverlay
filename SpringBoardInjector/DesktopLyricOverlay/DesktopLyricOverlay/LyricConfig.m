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
        
        BOOL isPad = [UIDevice.currentDevice userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        
        _enabled = dict[@"Enabled"] ? [dict[@"Enabled"] boolValue] : YES;
        _useLandscapeMode = dict[@"UseLandscapeMode"] ? [dict[@"UseLandscapeMode"] boolValue] : NO;
        _placedAtTop = dict[@"PlacedAtTop"] ? [dict[@"PlacedAtTop"] boolValue] : !isPad;
        NSString *fontPath = [@"/System/Library/Fonts/AppFonts/" stringByAppendingPathComponent:(NSString *)(dict[@"FontFileName"] ?: @"SomeFontWontExistsJustFineLol233.bad")];
        _font = [UIFont customFontWithURL:[NSURL fileURLWithPath:fontPath] size:[(NSNumber *)(dict[@"FontSize"] ?: @(14.0)) doubleValue]];
        if (!_font) {
            _font = [UIFont systemFontOfSize:[(NSNumber *)(dict[@"FontSize"] ?: @(14.0)) doubleValue]];
        }
        _createdAt = [NSDate date];
    }
    return self;
}

- (BOOL)isEnabled {
    return _enabled;
}

@end
