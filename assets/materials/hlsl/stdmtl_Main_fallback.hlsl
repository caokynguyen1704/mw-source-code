
#include "Headers/header.hlsl"



struct VS_INPUT
{
        float4 pos        : POSITION;
        float3 normal        : NORMAL;
        float2 uv0            : TEXCOORD0;
    #if defined(SYS_SKIN_MAXINFL_ENABLE)
        float4 blendweights : BLENDWEIGHT;
        float4 blendindices : BLENDINDICES;
    #endif
};

struct VS_OUTPUT
{
    float4 pos            : POSITION;
};

VS_OUTPUT VSMain(VS_INPUT input)
{
    VS_OUTPUT output;
    
    float3 pos;
    float3 normal;

#if defined(SYS_SKIN_MAXINFL_ENABLE)
	DoSkinVertex(input.blendindices, input.blendweights, input.pos, input.normal, pos, normal);
#else
    pos        = input.pos.xyz;
    normal    = input.normal;
    normal = normalize(normal);
#endif

    output.pos = mul(float4(pos,1.0), g_WorldViewProj);

    return output;
}


float4 PSMain(VS_OUTPUT input):SV_TARGET
{
    return float4(1,0,1,1);
}
