//
//  Shaders.metal
//  IMEditor
//
//  Created by Renjun Li on 2025/4/4.
//

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

vertex VertexOut vertexShader(VertexIn in [[stage_in]], constant Uniforms& uniforms [[buffer(1)]]) {
    VertexOut out;
    out.position = uniforms.transform * in.position;  // 直接传递位置
    out.texCoord = in.texCoord;  // 确保传递纹理坐标
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]], texture2d<float> texture [[texture(0)]]) {
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
    return texture.sample(textureSampler, in.texCoord);
}

