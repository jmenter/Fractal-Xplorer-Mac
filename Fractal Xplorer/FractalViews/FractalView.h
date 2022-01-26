
#import <Cocoa/Cocoa.h>
#import <OpenCL/OpenCL.h>
#import "FractalConfiguration.h"

@protocol MouseEventDelegate <NSObject>
- (void)handleMouseEvent:(NSEvent *)event inView:(NSView *)view;
@end

@interface FractalView : NSView <FractalConfigurationChangeDelegate>

@property (nonatomic) dispatch_queue_t renderQueue;
@property (nonatomic, weak) IBOutlet id<MouseEventDelegate> mouseEventDelegate;
@property (nonatomic) FractalConfiguration *fractalConfiguration;
@property (nonatomic) IBInspectable BOOL juliaMode;
@property (nonatomic) float orbitCount;
@property (nonatomic) NSUInteger colorizationOption;

/** scaling modifier */
@property (nonatomic) CGFloat renderingScale;

@property (nonatomic) NSArray <NSString *> *availableDeviceNames;

- (void)selectDeviceAtIndex:(NSUInteger)index;


- (CGIntegerSize)viewSizeInPixels;
- (cl_float2)realSpan;
- (cl_float2)imaginarySpan;

- (CGFloatComplex)complexForPoint:(CGPoint)point;

- (NSString *)labelText;
@end
