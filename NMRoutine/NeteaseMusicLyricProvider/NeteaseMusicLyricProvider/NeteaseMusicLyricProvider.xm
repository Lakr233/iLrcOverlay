// See http://iphonedevwiki.net/index.php/Logos

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
//    NSLog(@"[Lakr233] -> %@\n             %@", _lrc, _lrcTranslated);
    
    // Web Stuffs
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

%hook NMPlayerManager

-(void)setHighlightedLyricIndex:(signed)a3 {
    updateLyric(self, a3);
    return %orig;
}
    
-(void)setLyricsArray:(id)a3 {
    if (!booted && !bootedLrcCache) {
        bootedLrcCache = (NSArray*)a3;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                       sleep(5);
                       booted = true;
                       });
        // 真神奇 网易初始化两首歌的歌词
    }
    if (booted && bootedLrcCache && bootedLrcCache != (NSArray*)a3) {
        bootedLrcCache = NULL;
    }
    return %orig;
}

%end

