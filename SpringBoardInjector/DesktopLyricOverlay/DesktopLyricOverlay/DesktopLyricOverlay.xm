// See http://iphonedevwiki.net/index.php/Logos

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
    [_sharedLabel setCenter:CGPointMake(width / 2, height / 2)];
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
        
        if (![location isEqualToString:@"/System/Library/Fonts/AppFonts/"] && [NSFileManager.defaultManager fileExistsAtPath:location]) {
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

%hook CAWindowServerDisplay

- (unsigned int)contextIdAtPosition:(CGPoint)arg1 excludingContextIds:(NSArray <NSNumber *> *)arg2 {
    NSMutableArray <NSNumber *> *mArg2 = [arg2 mutableCopy] ?: [NSMutableArray array];
    id lyricWindowContextId = [NSDictionary dictionaryWithContentsOfFile:@"/tmp/" TWEAK_ID ".plist"][@"LyricContextId"];
    if ([lyricWindowContextId isKindOfClass:[NSNumber class]]) {
        [mArg2 addObject:lyricWindowContextId];
    }
    return %orig(arg1, mArg2);
}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
    
    %orig;
    
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
                // curl http://10.44.1.141:6996/SETLRC\?param\=VEVTVCBERUJVRyBOTyBISURFIDAxMjMg5rWL6K+VIPCfmIIK
                if (![cpy containsString:@"TEST DEBUG NO HIDE 0123 测试 😂"]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if ([currentSession isEqual:_session]) {
                            [_sharedLabel setHidden:YES];
                        }
                    });
                }
            });
            
            NSString* ret = [[NSString alloc] initWithFormat:@"ok %@", decodedString];
            return [GCDWebServerDataResponse responseWithHTML:ret];
        }];
        [_s startWithPort:6996 bonjourName:nil];
        
    }
    
}

%end

