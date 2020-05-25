#line 1 "/Users/qaq/Desktop/ilrcoverlay/QQMusicRoutine/QQMusicLyricsProvider/QQMusicLyricsProvider/QQMusicLyricsProvider.xm"


#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>

#include <substrate.h>
#include <notify.h>

OBJC_EXPORT id objc_retainAutoreleaseReturnValue(id obj) __OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_5_0);

static __attribute__((constructor)) void _logosLocalCtor_3d22e308(int __unused argc, char __unused **argv, char __unused **envp) {
    NSLog(@"[Lakr233] QQMusic Lyric Provider Loaded!");
}

