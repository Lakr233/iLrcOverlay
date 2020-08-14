#line 1 "/Users/qaq/Documents/GitHub/iLrcOverlay/NMRoutine/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider.xm"


#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>

#include <substrate.h>

OBJC_EXPORT id objc_retainAutoreleaseReturnValue(id obj) __OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_5_0);

bool booted = false;
NSArray* bootedLrcCache;

static bool useTranslate = false; 
static bool useWebHook = false;
static NSString* webHookTarget = @"";

static void _reloadSettings() {

    NSString *bundleId = @"wiki.qaq.NMRoutine";
    NSString *plistPath = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", bundleId];
    NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    useTranslate = [settings[@"UseTranslate"] boolValue];
    useWebHook = [settings[@"EnableWebHook"] boolValue];
    webHookTarget = settings[@"WebHookURL"];


    
}

static void updateLyric(id manager, signed index) {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _reloadSettings(); 
    });
    
    NSArray *lyricsArray;
    if (bootedLrcCache) {
        lyricsArray = [bootedLrcCache mutableCopy];
        unsigned long check = [lyricsArray count];
        if (index < 0 || index >= check) {
            bootedLrcCache = NULL;
        }
    }
    
    if (!bootedLrcCache) {
        SEL _laSel = NSSelectorFromString(@"lyricsArray");
        id _laSelVoucher1 = objc_msgSend(manager, _laSel);
        lyricsArray = objc_retainAutoreleaseReturnValue(_laSelVoucher1);
    }
    
    unsigned long check = [lyricsArray count];
    if (index < 0 || index >= check) {
        bootedLrcCache = NULL;
        return;
    }
    
    id lrcObject = [lyricsArray objectAtIndex: index];
    
    NSString *_lrc = NULL;
    if (useTranslate) {
        SEL _selt = NSSelectorFromString(@"translatedLyric");
        id _objcRetVoucher2 = objc_msgSend(lrcObject, _selt);
        NSString *_lrcTranslated = objc_retainAutoreleaseReturnValue(_objcRetVoucher2);
        if ([_lrcTranslated length] > 1)
            _lrc = _lrcTranslated;
    }
    if (!_lrc) {
        SEL _sel = NSSelectorFromString(@"lyric");
        id _objcRetVoucher1 = objc_msgSend(lrcObject, _sel);
        _lrc = objc_retainAutoreleaseReturnValue(_objcRetVoucher1);
    }
    
    
    NSData *data = [_lrc dataUsingEncoding:NSUTF8StringEncoding];
    NSString *stringBase64 = [data base64EncodedStringWithOptions:0];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    NSString* reqUrl = [[NSString alloc] initWithFormat:@"http://127.0.0.1:6996/SETLRC?param=%@", stringBase64];
    [request setURL:[NSURL URLWithString:reqUrl]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue alloc]
                           completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        return;
    }];
    
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
static void (*_logos_orig$_ungrouped$NMPlayerManager$setHighlightedLyricIndex$)(_LOGOS_SELF_TYPE_NORMAL NMPlayerManager* _LOGOS_SELF_CONST, SEL, signed); static void _logos_method$_ungrouped$NMPlayerManager$setHighlightedLyricIndex$(_LOGOS_SELF_TYPE_NORMAL NMPlayerManager* _LOGOS_SELF_CONST, SEL, signed); static void (*_logos_orig$_ungrouped$NMPlayerManager$setLyricsArray$)(_LOGOS_SELF_TYPE_NORMAL NMPlayerManager* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$NMPlayerManager$setLyricsArray$(_LOGOS_SELF_TYPE_NORMAL NMPlayerManager* _LOGOS_SELF_CONST, SEL, id); 

#line 91 "/Users/qaq/Documents/GitHub/iLrcOverlay/NMRoutine/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider.xm"


static void _logos_method$_ungrouped$NMPlayerManager$setHighlightedLyricIndex$(_LOGOS_SELF_TYPE_NORMAL NMPlayerManager* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, signed a3) {
    updateLyric(self, a3);
    return _logos_orig$_ungrouped$NMPlayerManager$setHighlightedLyricIndex$(self, _cmd, a3);
}
    
static void _logos_method$_ungrouped$NMPlayerManager$setLyricsArray$(_LOGOS_SELF_TYPE_NORMAL NMPlayerManager* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id a3) {
    if (!booted && !bootedLrcCache) {
        bootedLrcCache = (NSArray*)a3;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                       sleep(5);
                       booted = true;
                       });
        
    }
    if (booted && bootedLrcCache && bootedLrcCache != (NSArray*)a3) {
        bootedLrcCache = NULL;
    }
    return _logos_orig$_ungrouped$NMPlayerManager$setLyricsArray$(self, _cmd, a3);
}
















static __attribute__((constructor)) void _logosLocalCtor_cbd8b837(int __unused argc, char __unused **argv, char __unused **envp) {
    













    _reloadSettings();






}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$NMPlayerManager = objc_getClass("NMPlayerManager"); { MSHookMessageEx(_logos_class$_ungrouped$NMPlayerManager, @selector(setHighlightedLyricIndex:), (IMP)&_logos_method$_ungrouped$NMPlayerManager$setHighlightedLyricIndex$, (IMP*)&_logos_orig$_ungrouped$NMPlayerManager$setHighlightedLyricIndex$);}{ MSHookMessageEx(_logos_class$_ungrouped$NMPlayerManager, @selector(setLyricsArray:), (IMP)&_logos_method$_ungrouped$NMPlayerManager$setLyricsArray$, (IMP*)&_logos_orig$_ungrouped$NMPlayerManager$setLyricsArray$);}} }
#line 151 "/Users/qaq/Documents/GitHub/iLrcOverlay/NMRoutine/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider.xm"
