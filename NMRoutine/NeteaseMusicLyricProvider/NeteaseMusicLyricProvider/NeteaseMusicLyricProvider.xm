// See http://iphonedevwiki.net/index.php/Logos

#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>

#import <objc/runtime.h>
#import <objc/message.h>

#include <substrate.h>

OBJC_EXPORT id objc_retainAutoreleaseReturnValue(id obj);

//bool booted = false;
//NSArray* bootedLrcCache;

static bool useTranslate = false; // DONT MODIFY THIS
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
        _reloadSettings(); // Bad for performance but works greate
    });
    
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
    
    
    // Web Stuffs
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
//        NSLog(@"[Lakr233] Sending to %@", reqUrl);
        [request setURL:[NSURL URLWithString:reqUrl]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue alloc]
                               completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            return;
        }];
    }
}

%hook NMPlayerManager

-(void)setHighlightedLyricIndex:(signed)a3 {
    updateLyric(self, a3);
    return %orig;
}
    
//-(void)setLyricsArray:(id)a3 {
//    if (!booted && !bootedLrcCache) {
//        bootedLrcCache = (NSArray*)a3;
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                       sleep(5);
//                       booted = true;
//                       });
//        // 真神奇 网易初始化两首歌的歌词
//    }
//    if (booted && bootedLrcCache && bootedLrcCache != (NSArray*)a3) {
//        bootedLrcCache = NULL;
//    }
//    return %orig;
//}

%end

// there is 5 second delay of PreferencesLoader to sync with the file, use this as a temporary solution
//static void toggleTranslateOption() {
//    if (useTranslate == 1) {
//        useTranslate = 0;
//    } else {
//        useTranslate = 1;
//    }
//}

//static void reloadSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
//    _reloadSettings();
//}

%ctor {
    
//    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
//                                    NULL,
//                                    reloadSettings,
//                                    CFSTR("wiki.qaq.NMRoutine-preferencesChanged"),
//                                    NULL,
//                                    CFNotificationSuspensionBehaviorCoalesce);
//
//    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
//                                    NULL,
//                                    toggleTranslateOption,
//                                    CFSTR("wiki.qaq.NMRoutine-preferencesChanged-UseTranslate"),
//                                    NULL,
//                                    CFNotificationSuspensionBehaviorCoalesce);
    _reloadSettings();
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        while (true) {
//            _reloadSettings();
//            sleep(1);
//        }
//    });
}
