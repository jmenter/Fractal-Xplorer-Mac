
#import <Cocoa/Cocoa.h>
#import <OpenCL/OpenCL.h>
#import "FractalConfiguration.h"

@protocol MouseEventDelegate <NSObject>
- (void)mouseEvent:(NSEvent *)event view:(NSView *)view;
@end

@interface FractalView : NSView <FractalConfigurationChangeDelegate>

@property (nonatomic) dispatch_queue_t renderQueue;
@property (nonatomic) cl_device_type preferredDeviceType;
@property (nonatomic, weak) IBOutlet id<MouseEventDelegate> mouseEventDelegate;
@property (nonatomic) FractalConfiguration *fractalConfiguration;
@property (nonatomic) IBInspectable BOOL juliaMode;
@property (nonatomic) float orbitCount;

- (CGSize)viewSizeInPixels;
- (cl_float2)realSpan;
- (cl_float2)imaginarySpan;

- (CGFloatComplex)complexForPoint:(CGPoint)point;

- (NSString *)labelText;
@end
