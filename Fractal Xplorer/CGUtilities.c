
#include "CGUtilities.h"

CGFloatComplex CGFloatComplexMake(CGFloat real, CGFloat imaginary)
{
    CGFloatComplex newComplex;
    newComplex.real = real;
    newComplex.imaginary = imaginary;
    return newComplex;
}

bool CGFloatComplexIsEqual(CGFloatComplex a, CGFloatComplex b)
{
    return a.real == b.real && a.imaginary == b.imaginary;
}

CGSize CGSizeScale(CGSize size, CGFloat scale)
{
    return CGSizeMake(size.width * scale, size.height * scale);
}

CGContextRef CGBitmapContext32BitCreate(CGSize actualSize)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef imageContext = CGBitmapContextCreate(NULL, actualSize.width, actualSize.height, 8, actualSize.width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    CGColorSpaceRelease(colorSpace);
    return imageContext;
}

CGContextRef CGBitmapContext32BitCreateScaled(CGSize size, CGFloat scale)
{
    return CGBitmapContext32BitCreate(CGSizeScale(size, scale));
}


