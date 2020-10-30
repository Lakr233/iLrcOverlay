// See http://iphonedevwiki.net/index.php/Logos

#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>

#import "./FontLoader/UIFont+WDCustomLoader.h"
#import "./GCDWebServer/GCDWebServer.h"
#import "./GCDWebServer/GCDWebServerDataResponse.h"

#import "LyricConfig.h"
#import "LyricWindow.h"
#import "LyricController.h"

#define TWEAK_ID "wiki.qaq.DesktopLyricOverlay"
#define DEFAULT_FONT_SIZE 12

static NSString *_session = @"";
static LyricWindow *_lyricWindow = nil;
static LyricController *_lyricController = nil;
static LyricConfig *_lyricConfig = nil;

static void UpdateUserDefaults(void) {
    
    if (_lyricConfig) {
        if ([[NSDate date] timeIntervalSinceReferenceDate] - [[_lyricConfig createdAt] timeIntervalSinceReferenceDate] < 5.0) {
            return;
        }
    }
    
    NSDictionary *confDict = [NSDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Preferences/" TWEAK_ID ".plist"];
    _lyricConfig = [[LyricConfig alloc] initWithDictionary:confDict];
    
    [_lyricWindow setHidden:!_lyricConfig.isEnabled];
    [_lyricController.lyricLabel setFont:_lyricConfig.font];
    
}

%hook CAWindowServerDisplay

- (unsigned int)contextIdAtPosition:(CGPoint)arg1 excludingContextIds:(NSArray <NSNumber *> *)arg2 {
    NSMutableArray <NSNumber *> *mArg2 = [arg2 mutableCopy] ?: [NSMutableArray new];
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
    
    UpdateUserDefaults();
    
    if ([_lyricConfig isEnabled]) {
        
        _lyricController = [[UIStoryboard storyboardWithName:@"Lyric" bundle:[NSBundle bundleWithPath:@"/System/Library/CoreServices/SpringBoard.app"]] instantiateInitialViewController];
        
        _lyricWindow = [[LyricWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [_lyricWindow setBackgroundColor:[UIColor clearColor]];
        [_lyricWindow setWindowLevel:UIWindowLevelStatusBar + 1];
        [_lyricWindow setUserInteractionEnabled:NO];
        [_lyricWindow.layer setMasksToBounds:NO];
        [_lyricWindow setRootViewController:_lyricController];
        [_lyricWindow setHidden:NO];
        [_lyricWindow makeKeyAndVisible];
        [@{
            @"LyricContextId": @([_lyricWindow _contextId])
        } writeToFile:@"/tmp/" TWEAK_ID ".plist" atomically:YES];
        
        GCDWebServer *_s = [[GCDWebServer alloc] init];
        [_s addDefaultHandlerForMethod:@"GET"
                          requestClass:[GCDWebServerRequest class]
                          processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
            
            NSMutableString *base64 = [[[[[request URL] absoluteString] componentsSeparatedByString:@"?"] lastObject] mutableCopy];
            [base64 deleteCharactersInRange:NSMakeRange(0, 6)];
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:kNilOptions];
            NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            
            if (!decodedString.length) {
                return [GCDWebServerDataResponse responseWithHTML:@"invalid"];
            }
            
            _session = [[NSUUID UUID] UUIDString];
            __block NSString *cpy = [decodedString mutableCopy];
            __block NSString *currentSession = [_session mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_lyricController.bannerView setHidden:NO];
                [_lyricController.lyricLabel setText:cpy];
                
                // curl http://127.0.0.1:6996/SETLRC\?param\=VEVTVCBERUJVRyBOTyBISURFIDAxMjMg5rWL6K+VIPCfmIIK
                if (![cpy containsString:@"TEST DEBUG NO HIDE 0123 测试 😂"]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if ([currentSession isEqual:_session]) {
                            [_lyricController.bannerView setHidden:YES];
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

