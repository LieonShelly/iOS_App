//
//  CropShader.metal
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/24.
//

#include <metal_stdlib>
using namespace metal;


struct CropVerIn {
    float2 ndc [[ attribute(0) ]];
    float2 pad [[ attribute(1) ]];
};

struct CropVerOut {
    float4 position [[ position ]];
    float4 clipPos;
};


vertex CropVerOut cropVertext(CropVerIn in  [[ stage_in ]],
                              constant float4x4 &invM  [[ buffer(1) ]] ) {
    CropVerOut out;
    out.position = float4(in.ndc, 0, 1);
    out.clipPos = float4(in.ndc, 0, 1);
    return out;
}


fragment float4 cropFragment(CropVerOut in [[ stage_in ]],
                             texture2d<float> scrTex  [[ texture(0) ]],
                             constant float4x4 &invM  [[ buffer(1) ]]
) {
    float4 clip = in.clipPos;
    float4 ndc = clip / clip.w;
    float4 worldPos = invM * ndc;
    worldPos /= worldPos.w;
    float2 uv = worldPos.xy * 0.5 + 0.5;
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
    return scrTex.sample(textureSampler, uv);
}
