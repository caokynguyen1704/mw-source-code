#include "Headers/header.hlsl"


struct VS_INPUT {
    float4 pos : POSITION;
    float2 uv: TEXCOORD0;
};

struct VS_OUTPUT {
    float4 pos : SV_POSITION;
    float2 uv: TEXCOORD0;
};

VS_OUTPUT VSMain(VS_INPUT input)
{
    VS_OUTPUT o;
    o.pos = mul(float4(input.pos.xyz,1.0),g_WorldViewProj);
    o.uv = input.uv * float2(1.0, -1.0) + float2(0.0, 1.0);  
    return o;
}


TEXTURE2D(g_DiffuseTex);   SAMPLER2D(s_DiffuseSampler);

float4 PSMain(VS_OUTPUT i):SV_Target
{
    float4 outColor= SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,i.uv.xy);
    return outColor;
    // return float4(outColor.a,outColor.a,outColor.a,1);
}