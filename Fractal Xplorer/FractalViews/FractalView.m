
#import "FractalView.h"
#import "Fractal.cl.h"

@interface FractalView ()
@property (nonatomic) NSTimeInterval lastFrameTime;
@property (nonatomic) NSMutableArray <NSNumber *> *renderTimes;
@end

@implementation FractalView

static const CGFloat kBaseScale = 100.f; // i.e.; 1 unit in fractal space equals 200 screen points.

- (instancetype)initWithCoder:(NSCoder *)coder;
{
    if (!(self = [super initWithCoder:coder])) { return nil; }
    self.renderingScale = 1;
    [self selectDeviceAtIndex:0];
    if (!self.renderQueue) { return nil; }
    self.renderTimes = NSMutableArray.new;

    [self configureTrackingArea];
    self.fractalConfiguration = FractalConfiguration.new;
    self.fractalConfiguration.delegate = self;
    
    [self collectDevices];
    return self;
}

- (BOOL)isOpaque; { return YES; }

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

- (CGIntegerSize)viewSizeInPixels;
{
    CGSize newSize = CGSizeScale(self.bounds.size, NSScreen.mainScreen.backingScaleFactor * self.renderingScale);
    CGIntegerSize finalSize;
    finalSize.width = newSize.width;
    finalSize.height = newSize.height;
    return finalSize;
}

- (void)generateFractal;
{
    NSDate *startTime = NSDate.new;
    size_t pixelCount = self.viewSizeInPixels.width * self.viewSizeInPixels.height;
    CGContextRef imageContext = CGBitmapContext32BitCreate(CGSizeMake(self.viewSizeInPixels.width, self.viewSizeInPixels.height));
    UInt32 *imagePixelData = CGBitmapContextGetData(imageContext);
    cl_ndrange range = (cl_ndrange){ 2, // work_dim
        {0, 0, 0}, // global_work_offset
        {(size_t)self.viewSizeInPixels.width, (size_t)self.viewSizeInPixels.height, 0}, // global_work_size
        {(size_t)NULL, (size_t)NULL, 0} // local_work_size
    };

    dispatch_sync(self.renderQueue, ^{
        cl_float2 size = (cl_float2){self.fractalConfiguration.complex.real, self.fractalConfiguration.complex.imaginary};
        void *clMemory = gcl_malloc(sizeof(UInt32) * pixelCount, NULL, CL_MEM_WRITE_ONLY);

        fractal_kernel(&range, clMemory, (int)self.fractalConfiguration.maximumIterations,
                      self.realSpan, self.imaginarySpan, size, (int)self.juliaMode, self.orbitCount, (int)self.colorizationOption);

        gcl_memcpy(imagePixelData, clMemory, sizeof(UInt32) * pixelCount);
        gcl_free(clMemory);
    });
    CGImageRef fractalImageRef = CGBitmapContextCreateImage(imageContext);
    CGContextRelease(imageContext);

    self.layer.contents = (__bridge id)fractalImageRef;
    [self.layer setOpaque:YES];
//    self.layer.contentsGravity = kCAGravityResize;
    self.layer.minificationFilter = kCAFilterNearest;
    self.layer.magnificationFilter = kCAFilterNearest;
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
    if (theEvent.modifierFlags & NSEventModifierFlagCommand) {
        [NSCursor.crosshairCursor push];
    } else {
        [NSCursor.openHandCursor push];
    }

    [self.mouseEventDelegate handleMouseEvent:theEvent inView:self];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self.mouseEventDelegate handleMouseEvent:theEvent inView:self];
}

- (void)scrollWheel:(NSEvent *)event;
{
    [self.mouseEventDelegate handleMouseEvent:event inView:self];
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
    [self.mouseEventDelegate handleMouseEvent:theEvent inView:self];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [NSCursor pop];
    [self.mouseEventDelegate handleMouseEvent:theEvent inView:self];
}

- (NSString *)labelText;
{
    [self.renderTimes addObject:@(self.lastFrameTime)];
    if (self.renderTimes.count > 10) {
        [self.renderTimes removeObjectAtIndex:0];
    }
    __block NSTimeInterval average = 0.f;
    [self.renderTimes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        average += obj.doubleValue;
    }];
    average = average / (double)self.renderTimes.count;
    return [NSString stringWithFormat:@"real: %f • %f\nimaginary: %f • %f\ncomplex: %fr, %fi\n%i iterations\nrender time: %0.1fms, average: %0.1fms",
            (float)self.realSpan.lo, (float)self.realSpan.hi,
            (float)self.imaginarySpan.lo, (float)self.imaginarySpan.hi,
            (float)self.fractalConfiguration.complex.real,
            (float)self.fractalConfiguration.complex.imaginary,
              (int)self.fractalConfiguration.maximumIterations, (float)self.lastFrameTime * 1000.f, average * 1000.f];
}

- (void)collectDevices;
{
    char* value;
    size_t valueSize;
    cl_uint platformCount;
    cl_platform_id* platforms;
    cl_uint deviceCount;
    cl_device_id* devices;

    // get all platforms
    clGetPlatformIDs(0, NULL, &platformCount);
    platforms = (cl_platform_id*) malloc(sizeof(cl_platform_id) * platformCount);
    clGetPlatformIDs(platformCount, platforms, NULL);

    // get all devices for platform 0
    clGetDeviceIDs(platforms[0], CL_DEVICE_TYPE_ALL, 0, NULL, &deviceCount);
    devices = (cl_device_id*) malloc(sizeof(cl_device_id) * deviceCount);
    clGetDeviceIDs(platforms[0], CL_DEVICE_TYPE_ALL, deviceCount, devices, NULL);

    NSMutableArray *deviceNames = NSMutableArray.new;
    
    for (int i = 0; i < deviceCount; i++) {

        // print device name
        clGetDeviceInfo(devices[i], CL_DEVICE_NAME, 0, NULL, &valueSize);
        value = (char*) malloc(valueSize);
        clGetDeviceInfo(devices[i], CL_DEVICE_NAME, valueSize, value, NULL);
        NSString *deviceName = [NSString stringWithUTF8String:value];
        [deviceNames addObject:deviceName ?: @"(no device name)"];
        free(value);
    }
    self.availableDeviceNames = deviceNames.copy;
    free(platforms);
    free(devices);
}

- (void)selectDeviceAtIndex:(NSUInteger)index;
{
    cl_uint platformCount;
    cl_platform_id* platforms;
    cl_uint deviceCount;
    cl_device_id* devices;

    clGetPlatformIDs(0, NULL, &platformCount);
    platforms = (cl_platform_id*) malloc(sizeof(cl_platform_id) * platformCount);
    clGetPlatformIDs(platformCount, platforms, NULL);

    // get all devices for platform 0
    clGetDeviceIDs(platforms[0], CL_DEVICE_TYPE_ALL, 0, NULL, &deviceCount);
    devices = (cl_device_id*) malloc(sizeof(cl_device_id) * deviceCount);
    clGetDeviceIDs(platforms[0], CL_DEVICE_TYPE_ALL, deviceCount, devices, NULL);
    
    cl_device_id selected = devices[index];
    self.renderQueue = gcl_create_dispatch_queue(CL_DEVICE_TYPE_USE_ID, selected);
    free(platforms);
    free(devices);
}

@end
