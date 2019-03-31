
#import "FractalView.h"
#import "Fractal.cl.h"
#import <OpenCL/OpenCL.h>

@interface FractalView ()
@property (nonatomic) NSTimeInterval lastFrameTime;
@end

@implementation FractalView

static const CGFloat kAntiAliasingMultiplier = 1.f;
static const CGFloat kBaseScale = 100.f; // i.e.; 1 unit in fractal space equals 200 screen points.

- (instancetype)initWithCoder:(NSCoder *)coder;
{
    if (!(self = [super initWithCoder:coder])) { return nil; }
    self.preferredDeviceType = CL_DEVICE_TYPE_GPU;
    [self createRenderQueue];
    if (!self.renderQueue) { return nil; }
    
    [self configureTrackingArea];
    self.fractalConfiguration = FractalConfiguration.new;
    self.fractalConfiguration.delegate = self;
    return self;
}

- (void)createRenderQueue;
{
    self.renderQueue = gcl_create_dispatch_queue(self.preferredDeviceType, NULL);
}

- (void)setPreferredDeviceType:(cl_device_type)preferredDeviceType;
{
    if (_preferredDeviceType == preferredDeviceType) { return; }
    _preferredDeviceType = preferredDeviceType;
    [self createRenderQueue];
}

- (CGFloatComplex)complexForPoint:(CGPoint)point;
{
    CGFloat xRatio = point.x / self.bounds.size.width;
    CGFloat yRatio = 1.f - (point.y / self.bounds.size.height);
    
    CGFloat realDiff = self.realSpan.hi - self.realSpan.lo;
    CGFloat imagDiff = self.imaginarySpan.hi - self.imaginarySpan.lo;
    
    return CGFloatComplexMake(self.realSpan.lo + (realDiff * xRatio),
                              self.imaginarySpan.lo + (imagDiff * yRatio));
}

- (void)fractalConfigurationDidChange:(FractalConfiguration *)fractalConfiguration;
{
    [self generateFractal];
}

- (void)setFractalConfiguration:(FractalConfiguration *)fractalConfiguration;
{
    if ([_fractalConfiguration isEqual:fractalConfiguration]) { return; }
    _fractalConfiguration = fractalConfiguration;
    [self generateFractal];
}

- (void)layout;
{
    [super layout];
    [self generateFractal];
}

- (void)configureTrackingArea;
{
    NSTrackingAreaOptions options = NSTrackingMouseMoved | NSTrackingActiveAlways | NSTrackingInVisibleRect | NSTrackingMouseEnteredAndExited;
    [self addTrackingArea:[NSTrackingArea.alloc initWithRect:CGRectZero options:options owner:self userInfo:nil]];
}

- (CGSize)viewSizeInPixels;
{
    return CGSizeScale(self.bounds.size, NSScreen.mainScreen.backingScaleFactor * kAntiAliasingMultiplier);
}

- (void)generateFractal;
{
    NSDate *startTime = NSDate.new;
    size_t pixelCount = self.viewSizeInPixels.width * self.viewSizeInPixels.height;
    CGContextRef imageContext = CGBitmapContext32BitCreate(self.viewSizeInPixels);
    UInt32 *imagePixelData = CGBitmapContextGetData(imageContext);
    cl_ndrange range = (cl_ndrange){ 2, {0, 0, 0},
        {(size_t)self.viewSizeInPixels.width, (size_t)self.viewSizeInPixels.height, 0},
        {(size_t)NULL, (size_t)NULL, 0} };

    dispatch_sync(self.renderQueue, ^{
        cl_float2 size = (cl_float2){self.fractalConfiguration.complex.real, self.fractalConfiguration.complex.imaginary};
        void *clMemory = gcl_malloc(sizeof(UInt32) * pixelCount, NULL, CL_MEM_WRITE_ONLY);

        fractal_kernel(&range, clMemory, (int)self.fractalConfiguration.maximumIterations,
                      self.realSpan, self.imaginarySpan, size, (int)self.juliaMode, self.orbitCount);

        gcl_memcpy(imagePixelData, clMemory, sizeof(UInt32) * pixelCount);
        gcl_free(clMemory);
    });
    CGImageRef fractalImageRef = CGBitmapContextCreateImage(imageContext);
    CGContextRelease(imageContext);
    
    self.layer.contents = (__bridge id)fractalImageRef;
    CGImageRelease(fractalImageRef);
    self.lastFrameTime = -[startTime timeIntervalSinceNow];
}

- (cl_float2)realSpan; // our x axis
{
    return [self spanForMiddleAxis:CGRectGetMidX(self.bounds) offset:self.fractalConfiguration.actualOffset.x];
}

- (cl_float2)imaginarySpan;
{
    return [self spanForMiddleAxis:CGRectGetMidY(self.bounds) offset:self.fractalConfiguration.actualOffset.y];
}

- (cl_float2)spanForMiddleAxis:(CGFloat)middle offset:(CGFloat)offset;
{
    return (cl_float2){-((middle - offset) / self.actualScale), (middle + offset) / self.actualScale};
}

- (CGFloat)actualScale;
{
    return kBaseScale * self.fractalConfiguration.scale;
}

#pragma mark - NSTrackingArea

- (void)resetCursorRects
{
    [self addCursorRect:self.bounds cursor:NSCursor.openHandCursor];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    if (theEvent.modifierFlags & NSEventModifierFlagCommand ) {
        [NSCursor.crosshairCursor push];
    } else {
        [NSCursor.openHandCursor push];
    }

    [self.mouseEventDelegate mouseEvent:theEvent view:self];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self.mouseEventDelegate mouseEvent:theEvent view:self];
}

- (void)scrollWheel:(NSEvent *)event;
{
    [self.mouseEventDelegate mouseEvent:event view:self];
}

- (void)rightMouseUp:(NSEvent *)event;
{
    [self mouseUp:event];
}

- (void)rightMouseDown:(NSEvent *)event;
{
    [self mouseDown:event];
}

- (void)rightMouseDragged:(NSEvent *)event;
{
    [self mouseDragged:event];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self.mouseEventDelegate mouseEvent:theEvent view:self];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [NSCursor pop];
    [self.mouseEventDelegate mouseEvent:theEvent view:self];
}

- (NSString *)labelText;
{
    return [NSString stringWithFormat:@"real: %f • %f\nimaginary: %f • %f\ncomplex: %fr, %fi\n%i iterations • time: %0.3f",
            (float)self.realSpan.lo, (float)self.realSpan.hi,
            (float)self.imaginarySpan.lo, (float)self.imaginarySpan.hi,
            (float)self.fractalConfiguration.complex.real,
            (float)self.fractalConfiguration.complex.imaginary,
              (int)self.fractalConfiguration.maximumIterations, (float)self.lastFrameTime];
}
@end
