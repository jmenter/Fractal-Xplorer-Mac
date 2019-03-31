
float4 HSVAtoARGB(float4 hsva)
{
    // Get legit values.
    float intPart;
    hsva.x = fabs(modf(hsva.x, &intPart));
    hsva.y = clamp(hsva.y, 0.f, 1.f);
    hsva.z = clamp(hsva.z, 0.f, 1.f);
    hsva.w = clamp(hsva.w, 0.f, 1.f);
    
    // Apply color transformation
    hsva.x *= 6.f;
    int hexa = (int)hsva.x;
    float f = hsva.x - hexa;
    float p = hsva.z * (1.f - hsva.y);
    float q = hsva.z * (1.f - hsva.y * f);
    float t = hsva.z * (1.f - hsva.y * (1.f - f));
    
    // Store in appropriate places
    float4 argb = (float4)(hsva.w, 0.f, 0.f, 0.f);
    switch(hexa) {
        case 0: argb.y = hsva.z; argb.z = t; argb.w = p; break;
        case 1: argb.y = q; argb.z = hsva.z; argb.w = p; break;
        case 2: argb.y = p; argb.z = hsva.z; argb.w = t; break;
        case 3: argb.y = p; argb.z = q; argb.w = hsva.z; break;
        case 4: argb.y = t; argb.z = p; argb.w = hsva.z; break;
        case 5: argb.y = hsva.z; argb.z = p; argb.w = q; break;
    }
    // We're done!
    return argb;
}
