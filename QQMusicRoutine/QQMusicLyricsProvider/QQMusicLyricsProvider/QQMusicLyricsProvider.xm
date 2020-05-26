// See http://iphonedevwiki.net/index.php/Logos

#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>

#include <substrate.h>
#include <notify.h>

OBJC_EXPORT id objc_retainAutoreleaseReturnValue(id obj) __OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_5_0);
//Cuctom
@interface MyLyric:NSObject
@property(nonatomic)NSString* text;
@property long long startTime;
@end
@implementation MyLyric
@end

//Header
@interface AudioPlayManager
- (double)curTime;
@end

@interface KSSentence
@property(nonatomic) long long startTime; // @synthesize startTime=_startTime;
@property(retain, nonatomic) NSString *text; // @synthesize text=_text;
@property(nonatomic) int sentenceTransType;
@end


@interface KSLyric
@property(retain, nonatomic) NSMutableArray *sentencesArray; // @synthesize
@property(nonatomic) int lyricFormat;
@end


@interface KSQrcLyricParser
@property(nonatomic) int currentTransType; // @synthesize currentTransType=_currentTransType;
@property(retain, nonatomic) KSLyric *lyric; // @synthesize lyric=_lyric;
@end

//global
NSMutableArray *myLyrics;
double lstTime=0;
MyLyric *lstLyric=0;

//hook
%group QQMusicHook
%hook AudioPlayManager
- (void)updateProgress:(id)arg1 {
    %orig;
    double curTime=[self curTime]*1000;
    double diff=curTime-lstTime;
    // NSLog(@"curTime%lf",curTime);
    if(diff<600&&diff>-1)return;
    // NSLog(@"curTime%lf",curTime);
    lstTime=curTime;
    id curLyric;
    if([myLyrics count]){
        for(id myLyric in myLyrics){
            if([myLyric startTime]>curTime) break;
            curLyric=myLyric;
        }
    }
    if(curLyric!=lstLyric) {
        // NSLog(@"%@",[curLyric text]);
        lstLyric=curLyric;
        NSString*_lrc=[curLyric text];
        
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
}
%end
%hook KSQrcLyricParser
- (id)parseContent:(id)arg1 transType:(int)arg2 {
    // NSLog(@"[*] parseContent:(id) transType:(int)%d start",arg2);
    id r = %orig;
    // NSLog(@" = %@", r);
    if(arg2==0&&r){
        [myLyrics removeAllObjects];
        KSLyric* l=r;
        
        NSMutableArray *ma=l.sentencesArray;
        // KSSentence *s=ma[0];
        // NSLog(@"type: %d",[s sentenceTransType]);
        // NSLog(@"text: %@",[s text]);
        for(id sentence in ma){
            // NSLog(@"%@",[sentence text]);
            MyLyric*l=[MyLyric alloc];
            [l setText:[sentence text]];
            [l setStartTime:[sentence startTime]];
            // NSLog(@"%lld",[sentence startTime]);//ms
            [myLyrics addObject:l];

        }
        // NSLog(@"currentTransType: %d",[self currentTransType]);
    }
    return r;
}
%end
%end //QQMusicHook

//ctor
%ctor{
    NSLog(@"[Lakr233] QQMusic Lyric Provider Loaded!");
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.tencent.QQMusic"]){
        %init(QQMusicHook);
        myLyrics=[NSMutableArray arrayWithCapacity:100];
    }
}
