
#import "ViewController.h"
#import "FractalView.h"

@interface ViewController() <MouseEventDelegate>
@property (nonatomic) IBOutlet FractalView *mandlView;
@property (nonatomic) IBOutlet FractalView *juliaView;
@property (weak) IBOutlet NSTextField *mandelbrotLabel;
@property (weak) IBOutlet NSTextField *juliaLabel;
@end

@implementation ViewController
- (IBAction)sliderSlid:(id)sender;
{
    self.mandlView.orbitCount = [sender floatValue];
    self.juliaView.orbitCount = [sender floatValue];
    [self.mandlView layout];
    [self.juliaView layout];
}

- (void)mouseEvent:(NSEvent *)event view:(NSView *)view;
{
    static CGPoint previousMousePosition;
    if (event.type == NSEventTypeScrollWheel) {
        FractalView *fractalView = (FractalView *)view;
        fractalView.fractalConfiguration.scale *= 1 + (event.deltaY / 10);
    }
    CGPoint delta = CGPointMake(event.locationInWindow.x - previousMousePosition.x, event.locationInWindow.y - previousMousePosition.y);
    if (view == self.juliaView && (event.modifierFlags & NSEventModifierFlagCommand)) {
        CGPoint converted = CGPointMake(event.locationInWindow.x - self.mandlView.bounds.size.width, event.locationInWindow.y);
        self.mandlView.fractalConfiguration.complex = [self.juliaView complexForPoint:converted];
    } else
    if (view == self.mandlView && ((event.modifierFlags & NSEventModifierFlagCapsLock) ||
                                   (event.modifierFlags & NSEventModifierFlagCommand))) {
        
        self.juliaView.fractalConfiguration.complex = [self.mandlView complexForPoint:event.locationInWindow];
   } else
    if (event.type == NSEventTypeRightMouseDragged) {
        CGPoint delta = CGPointMake(event.locationInWindow.x - previousMousePosition.x, event.locationInWindow.y - previousMousePosition.y);
        if ([view isKindOfClass:FractalView.class]) {
            ((FractalView *)view).fractalConfiguration.scale *= 1 + (delta.y / 100);
        }
    }
    else if (event.modifierFlags & NSEventModifierFlagShift && event.type == NSEventTypeLeftMouseDragged) {
        CGPoint delta = CGPointMake(event.locationInWindow.x - previousMousePosition.x, event.locationInWindow.y - previousMousePosition.y);
        FractalView *fractalView = (FractalView *)view;
        fractalView.fractalConfiguration.maximumIterations += delta.y;
    }
    else if (event.type == NSEventTypeLeftMouseDragged) {
        FractalView *fractalView = (FractalView *)view;
        CGPoint offset = fractalView.fractalConfiguration.offset;
        CGPoint newOffset = CGPointMake(offset.x - delta.x / fractalView.fractalConfiguration.scale,
                                        offset.y + delta.y / fractalView.fractalConfiguration.scale);
        fractalView.fractalConfiguration.offset = newOffset;
    }
    previousMousePosition = event.locationInWindow;
    [self configureLabels];
}

-(void)configureLabels;
{
    self.mandelbrotLabel.stringValue = self.mandlView.labelText;
    self.mandelbrotLabel.backgroundColor = nil;
    self.juliaLabel.stringValue = self.juliaView.labelText;
    self.juliaLabel.backgroundColor = nil;
}

@end
