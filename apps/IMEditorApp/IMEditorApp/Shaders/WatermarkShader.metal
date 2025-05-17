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
    constexpr sampler textureSampler (
           mag_filter::linear,
           min_filter::linear,
           address::repeat
       );

       float2 uv = in.texCoord;
       float2 centeredUV = uv - 0.5;

       // 旋转整个纹理坐标
       float angle = rotation * 3.1415926 / 180.0;
       float cosA = cos(angle);
       float sinA = sin(angle);
       float2 rotatedUV;
       rotatedUV.x = centeredUV.x * cosA - centeredUV.y * sinA;
       rotatedUV.y = centeredUV.x * sinA + centeredUV.y * cosA;
       float2 finalUV = rotatedUV + 0.5;

       // 计算图像上每个像素的物理位置
       float2 pixelCoord = finalUV * imageSize;

       // 根据 tileSize 平铺
       float2 tiledUV = pixelCoord / tileSize;

       // === 修复变形 ===
       // 目标：保持水印单元是矩形，考虑其自身宽高比
       float watermarkAspect = watermarkSize.x / watermarkSize.y;
       float tileAspect = tileSize.x / tileSize.y;

       // 比例差距修正（在采样前缩放坐标）
       // 如果 tile 是正方形而 watermark 是长方形，就要按比例拉伸 UV
       tiledUV.x /= watermarkAspect / tileAspect;

       float4 color = watermark.sample(textureSampler, tiledUV);
       return float4(color.rgb, color.a);
    
}
