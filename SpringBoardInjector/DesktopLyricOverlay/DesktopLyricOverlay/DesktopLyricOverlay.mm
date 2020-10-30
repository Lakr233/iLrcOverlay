#line 1 "/Users/qaq/Documents/GitHub/iLrcOverlay/SpringBoardInjector/DesktopLyricOverlay/DesktopLyricOverlay/DesktopLyricOverlay.xm"


#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>

#import "./FontLoader/UIFont+WDCustomLoader.h"
#import "./GCDWebServer/GCDWebServer.h"
#import "./GCDWebServer/GCDWebServerDataResponse.h"
#import "LyricWindow.h"

#define TWEAK_ID "wiki.qaq.DesktopLyricOverlay"
#define DEFAULT_FONT_SIZE 12

NSString* _session = @"";

static LyricWindow* _sharedWindow;
static UILabel* _sharedLabel;
static UIFont* _sharedFont;

static bool enabled;
static bool useLandscapeMode;
static NSString* fontFileName;
static CGFloat fontSize = DEFAULT_FONT_SIZE;
static NSDate* lastUpdate;

static void adjustLabel() {
    [_sharedLabel setFont: _sharedFont];
    float height = _sharedFont.lineHeight * 1.2;
    CGSize sbsize = [[UIScreen mainScreen] bounds].size;
    float width = sbsize.width > sbsize.height ? sbsize.width : sbsize.height;
    [_sharedWindow setFrame:CGRectMake(0, 0, width, height)];
    [_sharedLabel setFrame:CGRectMake(0, 0, width, height)];
    [_sharedWindow setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width / 2,
                                         [[UIScreen mainScreen] bounds].size.height - height / 2)];
    [_sharedLabel setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width / 2,
                                         [[UIScreen mainScreen] bounds].size.height - height / 2)];
    
}

static void updateUserDefaults(void) {
    
    NSDate* current = [[NSDate alloc] init];
    double gap = [current timeIntervalSinceDate:lastUpdate];
    if (gap < 5) {
        return;
    }
    lastUpdate = current;
    
    bool requiresAppearanceUpdate = false;
    
    NSString *plistPath = @"/var/mobile/Library/Preferences/" TWEAK_ID ".plist";
    NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    if (settings[@"Enabled"]) {
        enabled = [settings[@"Enabled"] boolValue];
    } else {
        enabled = true;
    }
    if (settings[@"UseLandscapeMode"]) {
        useLandscapeMode = [settings[@"UseLandscapeMode"] boolValue];
    } else {
        useLandscapeMode = false;
    }
    
    float newFontSize;
    if (settings[@"FontSize"]) {
        newFontSize = [settings[@"FontSize"] floatValue];
    }
    if (newFontSize < 2) {
        newFontSize = DEFAULT_FONT_SIZE;
    }
    requiresAppearanceUpdate |= !(fontSize == [settings[@"FontSize"] floatValue]);
    fontSize = newFontSize;
    
    if (fontFileName != settings[@"FontFileName"]) {
        fontFileName = settings[@"FontFileName"];
        NSString* location = [[NSString alloc] initWithFormat:@"/System/Library/Fonts/AppFonts/%@", fontFileName];
        NSURL* target = [NSURL fileURLWithPath:location];
        
        if (![location isEqual:@"/System/Library/Fonts/AppFonts/"] && [NSFileManager.defaultManager fileExistsAtPath:location]) {
            _sharedFont = [UIFont customFontWithURL:target size:fontSize];
            _sharedFont = [_sharedFont fontWithSize:fontSize];
            requiresAppearanceUpdate = true;
        } else {
            _sharedFont = [UIFont systemFontOfSize:fontSize];
        }
    }
    
    if (_sharedLabel && requiresAppearanceUpdate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            adjustLabel();
        });
    }
    
}


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class CAWindowServerDisplay; @class SpringBoard; 
static unsigned int (*_logos_orig$_ungrouped$CAWindowServerDisplay$contextIdAtPosition$excludingContextIds$)(_LOGOS_SELF_TYPE_NORMAL CAWindowServerDisplay* _LOGOS_SELF_CONST, SEL, CGPoint, NSArray <NSNumber *> *); static unsigned int _logos_method$_ungrouped$CAWindowServerDisplay$contextIdAtPosition$excludingContextIds$(_LOGOS_SELF_TYPE_NORMAL CAWindowServerDisplay* _LOGOS_SELF_CONST, SEL, CGPoint, NSArray <NSNumber *> *); static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); 

#line 100 "/Users/qaq/Documents/GitHub/iLrcOverlay/SpringBoardInjector/DesktopLyricOverlay/DesktopLyricOverlay/DesktopLyricOverlay.xm"


static unsigned int _logos_method$_ungrouped$CAWindowServerDisplay$contextIdAtPosition$excludingContextIds$(_LOGOS_SELF_TYPE_NORMAL CAWindowServerDisplay* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, CGPoint arg1, NSArray <NSNumber *> * arg2) {
    NSMutableArray <NSNumber *> *mArg2 = [arg2 mutableCopy] ?: [NSMutableArray array];
    id lyricWindowContextId = [NSDictionary dictionaryWithContentsOfFile:@"/tmp/" TWEAK_ID ".plist"][@"LyricContextId"];
    if ([lyricWindowContextId isKindOfClass:[NSNumber class]]) {
        [mArg2 addObject:lyricWindowContextId];
    }
    return _logos_orig$_ungrouped$CAWindowServerDisplay$contextIdAtPosition$excludingContextIds$(self, _cmd, arg1, mArg2);
}





static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    
    _logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, arg1);
    
    updateUserDefaults();
    
    if (enabled) {
        
        _sharedWindow = [[LyricWindow alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _sharedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 22)];
        
        adjustLabel();
        
        NSString* welcome = @"👀";
        
        [_sharedLabel setText:welcome];
        [_sharedLabel setTextColor:[[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:0.888]];
        [_sharedLabel setBackgroundColor:[[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.233]];
        [_sharedLabel setTextAlignment:NSTextAlignmentCenter];
        [_sharedWindow setBackgroundColor:[UIColor clearColor]];
        [_sharedWindow addSubview:_sharedLabel];
        [_sharedWindow setWindowLevel:UIWindowLevelStatusBar + 1];
        _sharedWindow.userInteractionEnabled = NO;
        _sharedWindow.layer.masksToBounds = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if ([_sharedLabel.text isEqualToString:welcome]) {
                [_sharedLabel setHidden:YES];
            }
        });
        
        [_sharedWindow setHidden:NO];
        [_sharedWindow makeKeyAndVisible];
        [@{
            @"LyricContextId": @([_sharedWindow _contextId])
        } writeToFile:@"/tmp/" TWEAK_ID ".plist" atomically:YES];
        
        GCDWebServer *_s = [[GCDWebServer alloc] init];
        [_s addDefaultHandlerForMethod:@"GET"
                          requestClass:[GCDWebServerRequest class]
                          processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
            
            NSMutableString* base64 = [[[[[request URL] absoluteString] componentsSeparatedByString:@"?"] lastObject] mutableCopy];
            [base64 deleteCharactersInRange:NSMakeRange(0, 6)];
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
            NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            
            if ([decodedString isEqual:@""]) {
                return [GCDWebServerDataResponse responseWithHTML:@"Invalid Value"];
            }
            
            updateUserDefaults();
            
            _session = [[NSUUID UUID] UUIDString];
            
            __block NSString* cpy = [decodedString mutableCopy];
            __block NSString* currentSession = [_session mutableCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_sharedLabel setHidden:NO];
                [_sharedLabel setText:cpy];
                if ([cpy isEqualToString:@"TEST DEBUG NO HIDE 0123 测试 😂"]) {
                    return;
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([currentSession isEqual:_session]) {
                        [_sharedLabel setHidden:YES];
                    }
                });
            });
            
            NSString* ret = [[NSString alloc] initWithFormat:@"ok %@", decodedString];
            return [GCDWebServerDataResponse responseWithHTML:ret];
        }];
        [_s startWithPort:6996 bonjourName:nil];
        
    }
    
}



static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$CAWindowServerDisplay = objc_getClass("CAWindowServerDisplay"); { MSHookMessageEx(_logos_class$_ungrouped$CAWindowServerDisplay, @selector(contextIdAtPosition:excludingContextIds:), (IMP)&_logos_method$_ungrouped$CAWindowServerDisplay$contextIdAtPosition$excludingContextIds$, (IMP*)&_logos_orig$_ungrouped$CAWindowServerDisplay$contextIdAtPosition$excludingContextIds$);}Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); { MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);}} }
#line 196 "/Users/qaq/Documents/GitHub/iLrcOverlay/SpringBoardInjector/DesktopLyricOverlay/DesktopLyricOverlay/DesktopLyricOverlay.xm"
