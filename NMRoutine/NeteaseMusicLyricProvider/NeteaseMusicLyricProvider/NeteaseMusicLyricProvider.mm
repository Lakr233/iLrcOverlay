#line 1 "/Users/qaq/Documents/GitHub/iLrcOverlay/NMRoutine/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider.xm"


#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>

#import <objc/runtime.h>
#import <objc/message.h>

#include <substrate.h>

OBJC_EXPORT id objc_retainAutoreleaseReturnValue(id obj);




static bool useTranslate = false; 
static bool useWebHook = false;
static NSString* webHookTarget = @"";

static void UpdateUserDefaults() {
    
    
    BOOL isSystem = [NSHomeDirectory() isEqualToString:@"/var/mobile"];
    
    NSDictionary *prefs = nil;
    if (isSystem) {
        CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("wiki.qaq.NMRoutine"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        if (keyList) {
            prefs = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR("wiki.qaq.NMRoutine"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
            if(!prefs) prefs = [NSDictionary new];
            CFRelease(keyList);
        }
    }
    if (!prefs) {
        prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/wiki.qaq.NMRoutine.plist"];
    }
    
    useTranslate = prefs[@"UseTranslate"] ? [prefs[@"UseTranslate"] boolValue] : YES;
    useWebHook = prefs[@"EnableWebHook"] ? [prefs[@"EnableWebHook"] boolValue] : NO;
    webHookTarget = prefs[@"WebHookURL"] ? prefs[@"WebHookURL"] : @"";
    
}

static void updateLyric(id manager, signed index) {
    
    NSArray *lyricsArray;
    if ([manager respondsToSelector:NSSelectorFromString(@"lyricsArray")]) {
        lyricsArray = [manager valueForKey:@"_lyricsArray"];
    } else {
        lyricsArray = [[manager valueForKey:@"_lyricModel"] valueForKey:@"_lyricList"];
    }
    if (!lyricsArray)
        return;
    
    unsigned long check = [lyricsArray count];
    if (index < 0 || index >= check) {
        return;
    }
    
    id lrcObject = [lyricsArray objectAtIndex: index];
    
    NSString *_lrc = NULL;
    if (useTranslate) {
        SEL _selt = NSSelectorFromString(@"translatedLyric");
        NSString *_lrcTranslated = [lrcObject performSelector:_selt];
        if ([_lrcTranslated length] > 1)
            _lrc = _lrcTranslated;
    }
    if (!_lrc) {
        SEL _sel = NSSelectorFromString(@"lyric");
        _lrc = [lrcObject performSelector:_sel];
    }
    
    
    
    NSData *data = [_lrc dataUsingEncoding:NSUTF8StringEncoding];
    NSString *stringBase64 = [data base64EncodedStringWithOptions:0];
    while (true) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        NSString* reqUrl = [[NSString alloc] initWithFormat:@"http://127.0.0.1:6996/SETLRC?param=%@", stringBase64];
        [request setURL:[NSURL URLWithString:reqUrl]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue alloc]
                               completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            return;
        }];
        break;
    }
    
    if (useWebHook && [webHookTarget hasPrefix:@"http"]) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        NSString* reqUrl = [[NSString alloc] initWithFormat:@"%@/SETLRC?param=%@", webHookTarget, stringBase64];

        [request setURL:[NSURL URLWithString:reqUrl]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue alloc]
                               completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            return;
        }];
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

@class NMPlayerManager; 
static void (*_logos_orig$_ungrouped$NMPlayerManager$setHighlightedLyricIndex$)(_LOGOS_SELF_TYPE_NORMAL NMPlayerManager* _LOGOS_SELF_CONST, SEL, signed); static void _logos_method$_ungrouped$NMPlayerManager$setHighlightedLyricIndex$(_LOGOS_SELF_TYPE_NORMAL NMPlayerManager* _LOGOS_SELF_CONST, SEL, signed); 

#line 108 "/Users/qaq/Documents/GitHub/iLrcOverlay/NMRoutine/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider.xm"


static void _logos_method$_ungrouped$NMPlayerManager$setHighlightedLyricIndex$(_LOGOS_SELF_TYPE_NORMAL NMPlayerManager* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, signed a3) {
    updateLyric(self, a3);
    return _logos_orig$_ungrouped$NMPlayerManager$setHighlightedLyricIndex$(self, _cmd, a3);
}
    






























static __attribute__((constructor)) void _logosLocalCtor_79de844b(int __unused argc, char __unused **argv, char __unused **envp) {
    













    UpdateUserDefaults();
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)UpdateUserDefaults, CFSTR("wiki.qaq.NMRoutine-preferencesChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    






}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$NMPlayerManager = objc_getClass("NMPlayerManager"); { MSHookMessageEx(_logos_class$_ungrouped$NMPlayerManager, @selector(setHighlightedLyricIndex:), (IMP)&_logos_method$_ungrouped$NMPlayerManager$setHighlightedLyricIndex$, (IMP*)&_logos_orig$_ungrouped$NMPlayerManager$setHighlightedLyricIndex$);}} }
#line 171 "/Users/qaq/Documents/GitHub/iLrcOverlay/NMRoutine/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider.xm"
