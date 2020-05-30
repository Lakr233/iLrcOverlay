#line 1 "/Users/qaq/Documents/GitHub/iLrcOverlay/QQMusicRoutine/QQMusicLyricsProvider/QQMusicLyricsProvider/QQMusicLyricsProvider.xm"


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

@property(retain, nonatomic) id currentSong; 

+ (id)sharedAudioPlayManager;
- (double)curTime;

@end

@interface KSSentence

@property(nonatomic) long long startTime; 
@property(retain, nonatomic) NSString* text; 
@property(nonatomic) int sentenceTransType;

@end


@interface KSLyric

@property(retain, nonatomic) NSMutableArray* sentencesArray; 
@property(nonatomic) int lyricFormat;
@property(retain, nonatomic) NSString* title; 

@end


@interface SongInfo

- (id)song_Name;

@end

@interface LocalLyricObject

@property(retain, nonatomic) KSLyric* originLyric; 

@end


NSMutableDictionary* allLyrics;
double lstTime=0;
MyLyric* lstLyric;



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

@class AudioPlayManager; @class LyricManager; 


#line 73 "/Users/qaq/Documents/GitHub/iLrcOverlay/QQMusicRoutine/QQMusicLyricsProvider/QQMusicLyricsProvider/QQMusicLyricsProvider.xm"
static void (*_logos_orig$QQMusicHook$AudioPlayManager$updateProgress$)(_LOGOS_SELF_TYPE_NORMAL AudioPlayManager* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$QQMusicHook$AudioPlayManager$updateProgress$(_LOGOS_SELF_TYPE_NORMAL AudioPlayManager* _LOGOS_SELF_CONST, SEL, id); static id (*_logos_orig$QQMusicHook$LyricManager$getLyricObjectFromLocal$lyricFrom$)(_LOGOS_SELF_TYPE_NORMAL LyricManager* _LOGOS_SELF_CONST, SEL, id, unsigned long long); static id _logos_method$QQMusicHook$LyricManager$getLyricObjectFromLocal$lyricFrom$(_LOGOS_SELF_TYPE_NORMAL LyricManager* _LOGOS_SELF_CONST, SEL, id, unsigned long long); static id (*_logos_orig$QQMusicHook$LyricManager$getLyricObjectFromLocal$)(_LOGOS_SELF_TYPE_NORMAL LyricManager* _LOGOS_SELF_CONST, SEL, id); static id _logos_method$QQMusicHook$LyricManager$getLyricObjectFromLocal$(_LOGOS_SELF_TYPE_NORMAL LyricManager* _LOGOS_SELF_CONST, SEL, id); 



static void _logos_method$QQMusicHook$AudioPlayManager$updateProgress$(_LOGOS_SELF_TYPE_NORMAL AudioPlayManager* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    
    _logos_orig$QQMusicHook$AudioPlayManager$updateProgress$(self, _cmd, arg1);

    double curTime = [self curTime] * 1000;
    double diff = curTime - lstTime;
    if (diff < 600 && diff > -1)
        return;
    lstTime = curTime;
    
    NSString* _lrc = 0;
    NSArray* lyricArray = [allLyrics objectForKey:[[self currentSong] song_Name]];
    if (!lyricArray) {
        if (![[lstLyric text] isEqualToString:@" "]) {
            lstLyric = [MyLyric alloc];
            [lstLyric setText:@" "];
            _lrc = [lstLyric text];
        }
    } else {
        MyLyric* curLyric=0;
        if (lyricArray) {
            for(id myLyric in lyricArray){
                if ([myLyric startTime] > curTime) 
                    break;
                curLyric=myLyric;
            }
        }
        if (curLyric && curLyric != lstLyric) {
            lstLyric = curLyric;
            _lrc = [lstLyric text];
        }
    }

    if(_lrc){
        NSData* data = [_lrc dataUsingEncoding:NSUTF8StringEncoding];
        NSString* stringBase64 = [data base64EncodedStringWithOptions:0];
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
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

 



static id _logos_method$QQMusicHook$LyricManager$getLyricObjectFromLocal$lyricFrom$(_LOGOS_SELF_TYPE_NORMAL LyricManager* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1, unsigned long long arg2) {

    id r = _logos_orig$QQMusicHook$LyricManager$getLyricObjectFromLocal$lyricFrom$(self, _cmd, arg1, arg2);

    if (r) {
        KSLyric* l = [r originLyric];
        NSMutableArray* sentencesArray = l.sentencesArray;
        NSString* lyricName = [arg1 song_Name];
        
        NSMutableArray* tempMyLyrics = [NSMutableArray arrayWithCapacity:1024];
        for (id sentence in sentencesArray) {
            MyLyric* myLyric = [MyLyric alloc];
            [myLyric setText:[sentence text]];
            [myLyric setStartTime:[sentence startTime]];
            [tempMyLyrics addObject:myLyric];
        }

        [allLyrics setValue:tempMyLyrics forKey:lyricName];
    }

    return r;
    
}

static id _logos_method$QQMusicHook$LyricManager$getLyricObjectFromLocal$(_LOGOS_SELF_TYPE_NORMAL LyricManager* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {

    id r = _logos_orig$QQMusicHook$LyricManager$getLyricObjectFromLocal$(self, _cmd, arg1);

    if (r) {
        KSLyric* l = [r originLyric];
        NSMutableArray* sentencesArray = l.sentencesArray;
        NSString* lyricName = [arg1 song_Name];
        
        NSMutableArray* tempMyLyrics = [NSMutableArray arrayWithCapacity:1024];
        for (id sentence in sentencesArray) {
            MyLyric* myLyric = [MyLyric alloc];
            [myLyric setText:[sentence text]];
            [myLyric setStartTime:[sentence startTime]];
            [tempMyLyrics addObject:myLyric];
        }

        [allLyrics setValue:tempMyLyrics forKey:lyricName];
    }

    return r;
    
}

 

 

static __attribute__((constructor)) void _logosLocalCtor_992005e9(int __unused argc, char __unused **argv, char __unused **envp) {
    NSLog(@"[Lakr233] QQMusic Lyric Provider Loaded!");
    {Class _logos_class$QQMusicHook$AudioPlayManager = objc_getClass("AudioPlayManager"); MSHookMessageEx(_logos_class$QQMusicHook$AudioPlayManager, @selector(updateProgress:), (IMP)&_logos_method$QQMusicHook$AudioPlayManager$updateProgress$, (IMP*)&_logos_orig$QQMusicHook$AudioPlayManager$updateProgress$);Class _logos_class$QQMusicHook$LyricManager = objc_getClass("LyricManager"); MSHookMessageEx(_logos_class$QQMusicHook$LyricManager, @selector(getLyricObjectFromLocal:lyricFrom:), (IMP)&_logos_method$QQMusicHook$LyricManager$getLyricObjectFromLocal$lyricFrom$, (IMP*)&_logos_orig$QQMusicHook$LyricManager$getLyricObjectFromLocal$lyricFrom$);MSHookMessageEx(_logos_class$QQMusicHook$LyricManager, @selector(getLyricObjectFromLocal:), (IMP)&_logos_method$QQMusicHook$LyricManager$getLyricObjectFromLocal$, (IMP*)&_logos_orig$QQMusicHook$LyricManager$getLyricObjectFromLocal$);}
    allLyrics=[NSMutableDictionary dictionaryWithCapacity:1024];
}
