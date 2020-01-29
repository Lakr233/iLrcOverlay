#line 1 "/Users/qaq/Desktop/iLrcOverlay/QQMusicRoutine/QQMusicLyricsProvider/QQMusicLyricsProvider/QQMusicLyricsProvider.xm"


#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>

#include <substrate.h>
#include <notify.h>

OBJC_EXPORT id objc_retainAutoreleaseReturnValue(id obj) __OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_5_0);

@interface MyLyric: NSObject

@property(nonatomic) NSString* text;
@property long long startTime;

@end

@implementation MyLyric

@end


@interface AudioPlayManager

- (double)curTime;

@end

@interface KSSentence

@property(nonatomic) long long startTime;       
@property(retain, nonatomic) NSString *text;    
@property(nonatomic) int sentenceTransType;

@end

@interface KSLyric

@property(retain, nonatomic) NSMutableArray *sentencesArray; 
@property(nonatomic) int lyricFormat;

@end

@interface KSQrcLyricParser

@property(nonatomic) int currentTransType;      
@property(retain, nonatomic) KSLyric *lyric;    

@end


NSMutableArray *myLyrics;
double lstTime=0;
MyLyric *lstLyric=0;



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

@class AudioPlayManager; @class KSQrcLyricParser; 


#line 60 "/Users/qaq/Desktop/iLrcOverlay/QQMusicRoutine/QQMusicLyricsProvider/QQMusicLyricsProvider/QQMusicLyricsProvider.xm"
static void (*_logos_orig$QQMusicHook$AudioPlayManager$updateProgress$)(_LOGOS_SELF_TYPE_NORMAL AudioPlayManager* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$QQMusicHook$AudioPlayManager$updateProgress$(_LOGOS_SELF_TYPE_NORMAL AudioPlayManager* _LOGOS_SELF_CONST, SEL, id); static id (*_logos_orig$QQMusicHook$KSQrcLyricParser$parseContent$transType$)(_LOGOS_SELF_TYPE_NORMAL KSQrcLyricParser* _LOGOS_SELF_CONST, SEL, id, int); static id _logos_method$QQMusicHook$KSQrcLyricParser$parseContent$transType$(_LOGOS_SELF_TYPE_NORMAL KSQrcLyricParser* _LOGOS_SELF_CONST, SEL, id, int); 




static void _logos_method$QQMusicHook$AudioPlayManager$updateProgress$(_LOGOS_SELF_TYPE_NORMAL AudioPlayManager* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    _logos_orig$QQMusicHook$AudioPlayManager$updateProgress$(self, _cmd, arg1);
    double curTime = [self curTime] * 1000;
    double diff = curTime - lstTime;
    
    if (diff < 600 && diff > -1)
        return;
    
    lstTime = curTime;
    id curLyric;
    if ([myLyrics count]) {
        for (id myLyric in myLyrics) {
            if ([myLyric startTime] > curTime)
                break;
            curLyric = myLyric;
        }
    }
    
    if (curLyric != lstLyric) {
        
        lstLyric = curLyric;
        NSString* _lrc = [curLyric text];
         
        
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
}






static id _logos_method$QQMusicHook$KSQrcLyricParser$parseContent$transType$(_LOGOS_SELF_TYPE_NORMAL KSQrcLyricParser* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1, int arg2) {
    
    id r = _logos_orig$QQMusicHook$KSQrcLyricParser$parseContent$transType$(self, _cmd, arg1, arg2);
    
    if (arg2 == 0 && r) {
        [myLyrics removeAllObjects];
        KSLyric* l = r;
        
        NSMutableArray* ma = l.sentencesArray;
        
        
        
        for (id sentence in ma) {
            
            MyLyric* l = [MyLyric alloc];
            [l setText:[sentence text]];
            [l setStartTime:[sentence startTime]];
            
            [myLyrics addObject:l];

        }
        
    }
    return r;
}







static __attribute__((constructor)) void _logosLocalCtor_4ce779b0(int __unused argc, char __unused **argv, char __unused **envp) {
    
    NSLog(@"[Lakr233] QQMusic Lyric Provider Loaded!");
    NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier];
    
    if ([bundleId isEqualToString:@"com.tencent.QQMusic"] || [bundleId isEqualToString:@"com.tencent.QQMusicHD"] ) {
        {Class _logos_class$QQMusicHook$AudioPlayManager = objc_getClass("AudioPlayManager"); MSHookMessageEx(_logos_class$QQMusicHook$AudioPlayManager, @selector(updateProgress:), (IMP)&_logos_method$QQMusicHook$AudioPlayManager$updateProgress$, (IMP*)&_logos_orig$QQMusicHook$AudioPlayManager$updateProgress$);Class _logos_class$QQMusicHook$KSQrcLyricParser = objc_getClass("KSQrcLyricParser"); MSHookMessageEx(_logos_class$QQMusicHook$KSQrcLyricParser, @selector(parseContent:transType:), (IMP)&_logos_method$QQMusicHook$KSQrcLyricParser$parseContent$transType$, (IMP*)&_logos_orig$QQMusicHook$KSQrcLyricParser$parseContent$transType$);}
        myLyrics = [NSMutableArray arrayWithCapacity:100];
    }
    
    
}
