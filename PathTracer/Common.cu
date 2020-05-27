#include <optix.h>
#include <optix_device.h>

#include "Payloads.h"

using namespace optix;

rtDeclareVariable(Payload, payload, rtPayload, );
rtDeclareVariable(float3, backgroundColor, , );
rtDeclareVariable(int, hasEnvmap, , );
rtTextureSampler<float4, 2> envmap;

RT_PROGRAM void miss()
{
    if (hasEnvmap) {
        float theta = atan2f(payload.dir.x, payload.dir.z);
        float phi = M_PIf * 0.5f - acosf(payload.dir.y);
        float u = (theta + M_PIf) * (0.5f * M_1_PIf);
        float v = 0.5f * (1.0f + sin(phi));
        float3 result = make_float3(tex2D(envmap, u, v));
        // Set the result to be the background color if miss
        payload.radiance = result;
    }
    else {
        payload.radiance = backgroundColor;
    }
    payload.done = true;
}

RT_PROGRAM void exception()
{
    // Print any exception for debugging
    const unsigned int code = rtGetExceptionCode();
    rtPrintExceptionDetails();
}

rtDeclareVariable(ShadowPayload, shadowPayload, rtPayload, );
rtDeclareVariable(float1, t, rtIntersectionDistance, );

RT_PROGRAM void anyHit()
{
    shadowPayload.isVisible = false;
    rtTerminateRay();
}