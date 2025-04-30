//
//  WatermarkShader.metal
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/29.
//

#include <metal_stdlib>
using namespace metal;
#include <metal_stdlib>
using namespace metal;
#include "Vertext.h"

fragment float4 fragment_watermark(VertexOut in [[ stage_in ]],
                                   texture2d<float> watermark [[ texture((0)) ]],
                                   constant float2 &imageSize [[buffer(0)]],
                                   constant float2 &tileSize [[buffer(1)]],
                                   constant float &rotation [[buffer(2)]],
                                   constant float2 &watermarkSize [[buffer(3)]]) {
//    constexpr sampler textureSampler (address::repeat, filter::linear);
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
    float2 uv = in.texCoord;
    
    // 将全屏 UV 转换为像素坐标
    float2 pixelCoord = uv * imageSize;
    
    // 旋转（以屏幕中心为中心）
    float2 center = imageSize * 0.5;
    float2 pos = pixelCoord - center;
    
    float angle = 3.14 * 0 / 180; // e.g. 45°
    float cosA = cos(angle);
    float sinA = sin(angle);
    
    float2 rotated;
    rotated.x = pos.x * cosA - pos.y * sinA;
    rotated.y = pos.x * sinA + pos.y * cosA;

    // 平移回中心
    rotated += center;
    
    // 计算水印纹理重复次数（tile）
    float2 tiledUV = fmod(rotated / tileSize, 1.0);
    
    // ✅ 正确计算水印宽高比例
    float aspect = watermarkSize.x / watermarkSize.y;  // 例如 1280/720 = 1.777
    
    // ✅ 通过缩放保持原比例（此处保持 Y 不变，X 根据比例缩放）
    float2 aspectScale = float2(1.0 / aspect, 1.0);  // 例如 aspectScale.x = 0.5625
    
    // ✅ 居中缩放后再采样
    float2 centeredUV = (tiledUV - 0.5) * aspectScale + 0.5;
    
    if (any(centeredUV < 0.0) || any(centeredUV > 1.0)) {
        return float4(0.0); // 裁掉
    }

    // 采样水印纹理
    float4 color = watermark.sample(textureSampler, tiledUV);
    
    // 控制透明度（可调）
    return float4(color.rgb, color.a * 1);
    
}
