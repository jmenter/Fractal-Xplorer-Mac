
#include "Colorization.cl"

__kernel void fractal( __global uint * output, uint maximumIterations,
                      float2 realSpan, float2 imagSpan, float2 complex, uint isJulia, float orbitSeed, uint colorizationOption)
{
    float2 coordinates = (float2)(get_global_id(0), get_global_id(1));
    float2 imageSize = (float2)(get_global_size(0), get_global_size(1));
    float2 spanDiff = (float2)(realSpan.lo + coordinates.x * (difference(realSpan) / imageSize.x),
                               imagSpan.lo + coordinates.y * (difference(imagSpan) / imageSize.y));
    float2 modifier = spanDiff;
    float2 z = complex;
    
    if (isJulia) {
        modifier = complex;
        z = spanDiff;
    }
    float altOrbitCount = 0.5;
    float orbitCount = 0.5;
    float2 z2 = (float2)(0.f, 0.f);
    
    int iterationCount = 0;
    for (iterationCount = 0; (iterationCount < maximumIterations) && (z2.x + z2.y < 4.f); iterationCount++) {
        z2 = z * z;
        z.y = 2.f * z.x * z.y + modifier.y;

        z.x = z2.x - z2.y + modifier.x;
//        orbitCount += sin(z.x + z.y);
        orbitCount += 0.5 + 0.5 * sin((3.f * orbitSeed) * atan2(z.y, z.x));
        altOrbitCount += 0.5 + 0.5 * sin(4.f * orbitSeed * atan2(z.y, z.x));
    }
    
    float4 argb;
    switch (colorizationOption) {
        case 1: {
            argb = colorizeStripey(z, z2, iterationCount, maximumIterations);
        }
        break;
        case 2: {
            argb = colorizeBasic(z, z2, iterationCount, maximumIterations);
        }
        break;
        case 3: {
            argb = colorizeWithOrbitCount(z, orbitCount, iterationCount, maximumIterations);
        }
        break;
        case 4: {
            argb = colorizeNew(z, z2, iterationCount, maximumIterations);
        }
        break;
        case 0:
        default: {
            argb = colorizeBlackAndWhite(orbitCount, altOrbitCount, iterationCount, maximumIterations);
        }
        break;

    }
    
    output[(int)(coordinates.y * imageSize.x + coordinates.x)] = argbFloatToUInt(argb);
}
