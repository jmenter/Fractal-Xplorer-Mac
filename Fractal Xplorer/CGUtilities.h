
#ifndef CGUtilities_h
#define CGUtilities_h

#include <CoreGraphics/CoreGraphics.h>

typedef struct CGFloatComplex {
    CGFloat real;
    CGFloat imaginary;
} CGFloatComplex;

CGFloatComplex CGFloatComplexMake(CGFloat real, CGFloat imaginary);
bool CGFloatComplexIsEqual(CGFloatComplex a, CGFloatComplex b);

CGSize CGSizeScale(CGSize size, CGFloat scale);

CGContextRef CGBitmapContext32BitCreate(CGSize actualSize);
CGContextRef CGBitmapContext32BitCreateScaled(CGSize size, CGFloat scale);

#endif /* CGUtilities_h */
