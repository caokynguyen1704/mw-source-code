

#include "Headers/header.hlsl"




struct VS_INPUT
{
    float4 pos        : POSITION;
    float3 normal        : NORMAL;
    float4 color        :COLOR0;
    
#ifdef SYS_SKIN_MAXINFL_ENABLE
    float4 blendweights : BLENDWEIGHT;
    float4 blendindices : BLENDINDICES;
#endif
    float2 uv0            : TEXCOORD0;
#if defined(SELFILLUM_ALL)
	float2 uv1 : TEXCOORD1;
#endif
};

struct VS_OUTPUT_ShadowGen
{
    float4 pos            : POSITION;
    float2 uv0            : TEXCOORD0;
};

VS_OUTPUT_ShadowGen VSMain(VS_INPUT input)
{
    VS_OUTPUT_ShadowGen output;
    
    float3 pos;
    float3 normal;

#ifdef SYS_SKIN_MAXINFL_ENABLE
	DoSkinVertex(input.blendindices, input.blendweights, input.pos, input.normal, pos, normal);
#else
    pos        = input.pos.xyz;
    normal    = input.normal;
#endif

#ifdef LOG_SHADOWMAP
    float4 wpos = mul(float4(pos,1.0), g_WorldViewProj);
    float2 diff = wpos.xy - g_ShadowCenter.xy;
    float t = length(diff);
    float nt = g_ShadowCenter.w * log(g_ShadowCenter.z*t + 1)/t;

    output.pos.xy = g_ShadowCenter.xy + diff*nt;
    output.pos.zw = wpos.zw;
#else
    output.pos = mul(float4(pos,1.0), g_WorldViewProj);
#endif

    output.uv0 = input.uv0;

    return output;
}


TEXTURE2D(g_DiffuseTex);   SAMPLER2D(s_DiffuseSampler);


float4 PSMain(VS_OUTPUT_ShadowGen input) : SV_Target
{
#if MODEL_TRANSPARENT    
	float4 color  = SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,input.uv0);
	color.a *= g_ModelTransparent;
    return float4(0, 0, 0, color.a);
#else 
    return  float4(0, 0, 0, 1);
#endif
	
}
