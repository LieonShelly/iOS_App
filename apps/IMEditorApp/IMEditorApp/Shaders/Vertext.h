//
//  Vertext.h
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/29.
//

#ifndef Vertext_h
#define Vertext_h
#include <metal_stdlib>
using namespace metal;

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float4x4 transform;
};

#endif /* Vertext_h */
