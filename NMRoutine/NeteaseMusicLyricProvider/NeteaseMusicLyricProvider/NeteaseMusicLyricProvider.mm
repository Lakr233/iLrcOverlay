#line 1 "/Users/qaq/Desktop/Lrcs/NeteaseMusicRoutine/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider.xm"


#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>

#include <substrate.h>
#include <notify.h>

OBJC_EXPORT id objc_retainAutoreleaseReturnValue(id obj) __OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_5_0);

bool booted = false;
NSArray* bootedLrcCache;

static void updateLyric(id manager, signed index) {
    NSArray *lyricsArray;
    if (bootedLrcCache) {
        lyricsArray = [bootedLrcCache mutableCopy];
    } else {
        SEL _laSel = NSSelectorFromString(@"lyricsArray");
        id _laSelVoucher1 = objc_msgSend(manager, _laSel);
        lyricsArray = objc_retainAutoreleaseReturnValue(_laSelVoucher1);
    }
    id lrcObject = [lyricsArray objectAtIndex: index];
    SEL _sel = NSSelectorFromString(@"lyric");
    id _objcRetVoucher1 = objc_msgSend(lrcObject, _sel);
    NSString *_lrc = objc_retainAutoreleaseReturnValue(_objcRetVoucher1);
    SEL _selt = NSSelectorFromString(@"translatedLyric");
    id _objcRetVoucher2 = objc_msgSend(lrcObject, _selt);
    NSString *_lrcTranslated = objc_retainAutoreleaseReturnValue(_objcRetVoucher2);

    
    
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

#line 49 "/Users/qaq/Desktop/Lrcs/NeteaseMusicRoutine/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider.xm"


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



static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$NMPlayerManager = objc_getClass("NMPlayerManager"); MSHookMessageEx(_logos_class$_ungrouped$NMPlayerManager, @selector(setHighlightedLyricIndex:), (IMP)&_logos_method$_ungrouped$NMPlayerManager$setHighlightedLyricIndex$, (IMP*)&_logos_orig$_ungrouped$NMPlayerManager$setHighlightedLyricIndex$);MSHookMessageEx(_logos_class$_ungrouped$NMPlayerManager, @selector(setLyricsArray:), (IMP)&_logos_method$_ungrouped$NMPlayerManager$setLyricsArray$, (IMP*)&_logos_orig$_ungrouped$NMPlayerManager$setLyricsArray$);} }
#line 73 "/Users/qaq/Desktop/Lrcs/NeteaseMusicRoutine/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider/NeteaseMusicLyricProvider.xm"
