
#import "HSVAtoARGB.cl"
float difference(float2 input) {
    return input.hi - input.lo;
}

uint argbFloatToUInt(float4 argb)
{
    return ((int)(argb.w * 255) << 24) | ((int)(argb.z * 255) << 16) | ((int)(argb.y * 255) <<  8) | (int)(argb.x * 255);
}

float4 colorizeStripey(float2 z, float2 z2, int iterationCount, int maximumIterations)
{
    float4 hsva = (float4)(0.f, 0.f, 0.f, 1.f);
    if (iterationCount == maximumIterations) {
        float factor = 2 - (z2.x + z2.y);
        hsva.x = (z2.x * 2.f);
        hsva.y = (factor / 2.f);
        hsva.z = (z2.y * 4.f);
    } else {
        float smoothed = iterationCount;
        hsva.x = smoothed * 0.05;
        hsva.y = smoothed * 0.05 * z.x + (iterationCount %2 * 0.2);
        hsva.z = smoothed * 0.05 * z.y + (iterationCount %2 * 0.2);
        if (z.y > 0.f) {
            hsva.y /= 1.25f;
            hsva.z /= 1.25f;
        }
        if (iterationCount %2 == 0) {
            hsva.y /= 1.5f;
            hsva.z /= 1.5f;
        }
    }
    return HSVAtoARGB(hsva);
}

float4 colorizeBasic(float2 z, float2 z2, int iterationCount, int maximumIterations)
{
    float value = (iterationCount == maximumIterations) ? 0.05 : (float)iterationCount / (float)maximumIterations;
    float4 argb = (float4)(1, value * 0.7, value * 0.9, value);
    return argb;
}

float4 colorizeBlackAndWhite(float orbitCount, float altOrbitCount, int iterationCount, int maximumIterations)
{
//    if (iterationCount == maximumIterations) {
//        return (float4)(1, 1, 1, 1);
//    }

    float value = 1.0 / orbitCount;
    value = clamp(value, 0.f, 1.f);
    float hue = 1.0 / altOrbitCount;
    hue = clamp(hue, 0.f, 1.f);
//    value = 0.5;
//    float4 argb = (float4)(1, value, value, value);
    float4 hsva = (float4)(hue, 0.5, value, 1);
    return HSVAtoARGB(hsva);
}

float4 colorizeNew(float2 z, float2 z2, int iterationCount, int maximumIterations)
{
    float newNumber = sqrt(z2.x + z2.y);
    float i = (float)iterationCount;
    float hue = 0.f + 1.f - log(log(fabs(newNumber)));
//    float value = (iterationCount == maximumIterations) ? 1 : 0;
//    float4 argb = (float4)(1, value, value, value);
    float4 hsva = (float4)(hue, 0.8, 1, 1);
    float4 argb = HSVAtoARGB(hsva);
    return argb;
}

float4 colorizeNewer(float2 z, int iterationCount, int maximumIterations)
{
    float cycleCount = (float)iterationCount / 360.f;
    float value = (iterationCount == maximumIterations) ? 0 : (float)iterationCount / (float)maximumIterations;
//    float4 hsva = (float4)(cycleCount, 0.8, value, 1);
    float4 hsva = (float4)(cycleCount, value / 2.f, value, 1.f);
    return HSVAtoARGB(hsva);
}

float4 colorizeWithOrbitCount(float2 z, float orbitCount, int iterationCount, int maximumIterations)
{
    if (iterationCount == maximumIterations) {
        return (float4)(1, 0, 0, 0);
    }
    orbitCount /= maximumIterations;
    float orbitColor = (orbitCount + 1.0) * 127.5;
    float value = 1;// / 255.0;
    float4 argb = (float4)(1, value, value, value);
    return argb;
}
