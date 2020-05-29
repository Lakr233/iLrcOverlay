// See http://iphonedevwiki.net/index.php/Logos

#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>

#include <substrate.h>
#include <notify.h>

OBJC_EXPORT id objc_retainAutoreleaseReturnValue(id obj) __OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_5_0);

// Cuctom
@interface MyLyric: NSObject

@property(nonatomic) NSString* text;
@property long long startTime;

@end

@implementation MyLyric

@end

// Header

@interface AudioPlayManager

@property(retain, nonatomic) id currentSong; // @synthesize currentSong;

+ (id)sharedAudioPlayManager;
- (double)curTime;

@end

@interface KSSentence

@property(nonatomic) long long startTime; // @synthesize startTime=_startTime;
@property(retain, nonatomic) NSString* text; // @synthesize text=_text;
@property(nonatomic) int sentenceTransType;

@end


@interface KSLyric

@property(retain, nonatomic) NSMutableArray* sentencesArray; // @synthesize
@property(nonatomic) int lyricFormat;
@property(retain, nonatomic) NSString* title; // @synthesize title=_title;

@end


@interface SongInfo

- (id)song_Name;

@end

@interface LocalLyricObject

@property(retain, nonatomic) KSLyric* originLyric; // @synthesize originLyric=_originLyric;

@end

//global
NSMutableDictionary* allLyrics;
double lstTime=0;
MyLyric* lstLyric;

//hook
%group QQMusicHook

%hook AudioPlayManager

- (void)updateProgress:(id)arg1 {
    
    %orig;

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

%end // AudioPlayManager

%hook LyricManager

-(id)getLyricObjectFromLocal:(id)arg1 lyricFrom:(unsigned long long)arg2 {

    id r = %orig;

    if (r) {
        KSLyric* l = [r originLyric];
        NSMutableArray* sentencesArray=l.sentencesArray;
        NSString* lyricName=[arg1 song_Name];
        
        NSMutableArray* tempMyLyrics=[NSMutableArray arrayWithCapacity:1024];
        for(id sentence in sentencesArray){
            MyLyric* myLyric=[MyLyric alloc];
            [myLyric setText:[sentence text]];
            [myLyric setStartTime:[sentence startTime]];
            [tempMyLyrics addObject:myLyric];
        }

        [allLyrics setValue:tempMyLyrics forKey:lyricName];
    }

    return r;
    
}

%end // LyricManager

%end // QQMusicHook

%ctor {
    NSLog(@"[Lakr233] QQMusic Lyric Provider Loaded!");
    %init(QQMusicHook);
    allLyrics=[NSMutableDictionary dictionaryWithCapacity:1024];
}
