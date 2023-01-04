
#include "Headers/header.hlsl"


struct VS_INPUT
{
    float3 pos        : POSITION;
    float2 uv        : TEXCOORD0;
};

struct VS_OUTPUT
{
    float4 Position   : POSITION;   // vertex position 
    float2 TextureUV  : TEXCOORD0;  // vertex texture coords 
};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;

	output.Position = mul(float4(input.pos,1.0), g_WorldViewProj);
	output.TextureUV = input.uv * 0.5;
	return output;
}

TEXTURE2D(g_DiffuseTex);   SAMPLER2D(s_DiffuseSampler);

float4 PSMain(VS_OUTPUT i):SV_Target
{
    // return float4(i.TextureUV.xy,0,1);
    return  SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,i.TextureUV.xy);
}
