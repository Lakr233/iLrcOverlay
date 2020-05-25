//
//  UIView+PassthroughView.m
//  DesktopLyricOverlay
//
//  Created by Lakr Aream on 2020/5/26.
//

#import "PassthroughView.h"

@implementation PassthroughView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *view in self.subviews) {
        if (!view.hidden && [view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
            return YES;
        }
    }
    return NO;
}

@end

@implementation PassthroughWindow

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *view in self.subviews) {
        if (!view.hidden && [view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
            return YES;
        }
    }
    return NO;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return NULL;
}

@end


