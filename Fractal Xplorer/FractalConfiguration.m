
#import "FractalConfiguration.h"

@implementation FractalConfiguration

- (instancetype)init;
{
    if (!(self = [super init])) { return nil; }
    
    self.scale = 1;
    self.offset = CGPointMake(0, 0);
    self.maximumIterations = 128;
    self.complex = CGFloatComplexMake(0, 0);
    
    return self;
}

- (void)setScale:(CGFloat)scale;
{
    if (_scale == scale) { return; }
    _scale = (scale < 0.1) ? 0.1 : scale;
    [self.delegate fractalConfigurationDidChange:self];
}

- (void)setOffset:(CGPoint)offset;
{
    if (CGPointEqualToPoint(_offset, offset)) { return; }
    _offset = offset;
    [self.delegate fractalConfigurationDidChange:self];
}

- (void)setMaximumIterations:(NSInteger)maximumIterations;
{
    if (_maximumIterations == maximumIterations) { return; }
    _maximumIterations = (maximumIterations < 2) ? 2 : maximumIterations;
    [self.delegate fractalConfigurationDidChange:self];
}

- (void)setComplex:(CGFloatComplex)complex;
{
    if (CGFloatComplexIsEqual(_complex, complex)) { return; }
    _complex = complex;
    [self.delegate fractalConfigurationDidChange:self];
}

- (CGPoint)actualOffset;
{
    return CGPointMake(self.offset.x * self.scale,
                       self.offset.y * self.scale);
}

- (BOOL)isEqual:(id)object;
{
    if (![object isKindOfClass:self.class]) { return NO; }
    if (object == self) { return YES; }
    FractalConfiguration *castObject = object;
    return  castObject.scale == self.scale &&
            CGPointEqualToPoint(castObject.offset, self.offset) &&
            castObject.maximumIterations == self.maximumIterations &&
            CGFloatComplexIsEqual(castObject.complex, self.complex);
}

@end

